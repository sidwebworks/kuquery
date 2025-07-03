import 'dart:async';

typedef QueryKey = List<dynamic>;

typedef QueryFn<TKey extends QueryKey, TData> = Future<TData> Function(TKey);

enum QueryStatus { stale, fresh, fetching, loading, error }

class QueryState<TData, TError> {
  final StreamController<TData?> _controller = StreamController.broadcast();
  Stream<TData?> get stream => _controller.stream;
  TData? data;

  TError? error;
  DateTime? lastFetchedAt;
  QueryStatus? status;

  QueryState({this.error, this.lastFetchedAt, this.status});

  void setData(TData? data) {
    _controller.add(data);
    this.data = data;
  }

  void dispose() {
    _controller.close();
  }
}

class Query<TKey extends QueryKey, TData, TError> {
  Duration? staleTime;

  late QueryFn<TKey, TData> fn;
  late TKey _key;

  final state = QueryState<TData, TError>();
  bool enabled = false;

  Query(TKey key, {QueryFn<TKey, TData>? queryFn}) {
    if (key.isEmpty) {
      throw ArgumentError('Query key cannot be empty');
    }

    if (queryFn == null) {
      throw ArgumentError('Query Function cannot be null');
    }

    _key = key;
    fn = queryFn;
  }

  bool get isStale {
    if (staleTime == null || state.lastFetchedAt == null) return true;
    return DateTime.now().difference(state.lastFetchedAt!) > staleTime!;
  }

  List<String> key() {
    // Serialize the key
    return _key.map((e) => e.toString()).toList();
  }

  Future<TData> execute() async {
    try {
      state.status = QueryStatus.fetching;

      final value = await fn(_key);

      state.setData(value);
      state.lastFetchedAt = DateTime.now();
      state.status = QueryStatus.fresh;

      return value;
    } catch (e) {
      state.error = e as TError;
      state.status = QueryStatus.error;
      state.setData(null);
      rethrow;
    }
  }
}

class QueryCache {
  Map<String, Query> entries = {};

  QueryCache();

  set(Query query) {
    final key = query.key().toString();

    entries.putIfAbsent(key, () => query);
  }

  Query get(String key) {
    final query = entries[key];

    if (query == null) {
      throw ArgumentError('Query with key $key not found in cache');
    }

    return query;
  }
}
