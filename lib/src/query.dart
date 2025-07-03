import 'dart:async';
import 'dart:developer';
import 'dart:math';

// Typedefs
typedef QueryFn<TKey extends Record, TData> = Future<TData> Function(TKey);

// Status Enum
enum QueryStatus { stale, fresh, fetching, loading, error }

// Query State
class QueryState<TData, TError> {
  final StreamController<TData> _controller = StreamController.broadcast();
  Stream<TData> get stream => _controller.stream;

  TData? data;
  TError? error;
  DateTime? lastFetchedAt;
  QueryStatus? status;

  QueryState({this.error, this.lastFetchedAt, this.status});

  void setData(TData data) {
    _controller.add(data);
    this.data = data;
  }

  void dispose() {
    _controller.close();
  }
}

class Query<TKey extends Record, TData, TError> {
  final TKey key;
  final QueryFn<TKey, TData> fn;

  final state = QueryState<TData, TError>();
  final enabled = false;

  Completer<TData>? _completor;

  Duration? staleTime;

  Query(this.key, {required this.fn}) {
    state.status = QueryStatus.stale;
    state.lastFetchedAt = null;
  }

  bool get isStale {
    if (state.status == QueryStatus.stale) {
      return true;
    }

    if (state.lastFetchedAt == null || staleTime == null) {
      return true; // If never fetched or no stale time set, consider it stale
    }

    final now = DateTime.now();

    return now.difference(state.lastFetchedAt!).compareTo(staleTime!) > 0;
  }

  Future<TData> get data {
    return _completor?.future ?? execute();
  }

  Future<TData> execute() {
    if (state.status == QueryStatus.fetching) return _completor!.future;

    state.status = QueryStatus.fetching;

    _completor = Completer<TData>();
    state.status = QueryStatus.fetching;

    print('Executing query for key: $key');

    fn(key)
        .then((value) {
          print('Finished executing query for key: $key');
          state.setData(value);
          state.lastFetchedAt = DateTime.now();
          state.status = QueryStatus.fresh;
          _completor?.complete(value);
        })
        .catchError((e) {
          state.error = e as TError;
          state.status = QueryStatus.error;
          _completor?.completeError(state.error!);
        });

    return _completor!.future;
  }

  void invalidate() {
    state.status = QueryStatus.stale;
    state.lastFetchedAt = null;
    _completor = null;
  }
}

Query<TKey, TData, TError> defineQuery<TKey extends Record, TData, TError>({
  required TKey key,
  required QueryFn<TKey, TData> queryFn,
  Duration? staleTime,
}) {
  final query = Query<TKey, TData, TError>(key, fn: queryFn);

  if (staleTime != null) {
    query.staleTime = staleTime;
  }

  return query;
}
