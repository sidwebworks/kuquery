import 'package:kuqery/kuquery.dart';

import 'queries.dart';

main() async {
  final client = QueryClient(cache: QueryCache());

  final one = client.query(getTodos);
  final two = client.query(getTodos);
  final three = client.query(getTodos);

  one.state.stream.listen((data) {
    print("One: ${data.length}");
  });

  print((await one.data).length);
  print((await two.data).length);

  await Future.delayed(const Duration(seconds: 10));
  print((await three.data).length);
}
