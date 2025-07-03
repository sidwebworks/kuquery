import 'package:kuqery/kuquery.dart';

import 'queries.dart';

main() async {
  final client = QueryClient();

  final query = client.query(
    getMedicines,
    staleTime: Duration(seconds: 60),
    refetchOnNavigation: true,
  );

  query.state.stream.listen((data) {
    print(data);
    print(query.state.data);
  });
}
