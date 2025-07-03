import 'package:kuqery/kuquery.dart';

class QueryCache {
  final Map<String, Query> _entries = {};

  void set(Query query) {
    _entries[query.key.toString()] = query;
  }

  Query? get(Record key) {
    final query = _entries[key.toString()];

    if (query == null) {
      return null;
    }

    return query;
  }
}
