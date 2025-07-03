import 'package:kuqery/src/query.dart';
import 'package:kuqery/src/query_cache.dart';
import 'package:logger/logger.dart';

final log = Logger(
  level: Level.all,
  filter: ProductionFilter(),
  printer: PrettyPrinter(), // Optional: makes output nice
);

class QueryClient {
  final QueryCache cache;

  QueryClient({required this.cache});

  Query<Record, TData, TError>
  query<T extends Query<Record, TData, TError>, TData, TError>(
    T query, {
    Duration? staleTime,
    bool? refetchOnNavigation,
    int? refetchInterval,
  }) {
    if (staleTime != null) {
      query.staleTime = staleTime;
    }

    final entry = cache.get(query.key);

    if (entry != null && entry is Query<Record, TData, TError>) {
      if (!entry.isStale || entry.state.status == QueryStatus.fetching) {
        log.i("message: Using cached query for key: ${query.key}");
        return query;
      }

      entry.execute();

      return entry;
    }
    log.i(
      "message: No cached query found for key: ${query.key} - executing query and caching it.",
    );

    cache.set(query);

    query.execute();

    return query;
  }
}
