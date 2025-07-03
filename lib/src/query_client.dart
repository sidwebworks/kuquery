import 'package:kuqery/src/query.dart';

class QueryClient {
  QueryClient({QueryCache? queryCache});

  Query<dynamic, TData, TError>
  query<T extends Query<dynamic, TData, TError>, TData, TError>(
    T query, {
    Duration? staleTime,
    bool? refetchOnNavigation,
    int? refetchInterval,
  }) {
    if (staleTime != null && query.staleTime != null) {
      query.staleTime = staleTime;
    }

    query.execute();

    return query;
  }
}
