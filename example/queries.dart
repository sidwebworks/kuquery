import 'package:dio/dio.dart';
import 'package:kuqery/kuquery.dart';

class Todo {
  int userId;
  int id;
  String title;
  bool completed;

  Todo({
    required this.userId,
    required this.id,
    required this.title,
    required this.completed,
  });

  static Todo fromJSON(Map<String, dynamic> data) {
    return Todo(
      userId: data["userId"],
      id: data["id"],
      title: data["title"],
      completed: data["completed"],
    );
  }
}

final dio = Dio();

final getTodos = defineQuery(
  key: ('todos',),
  staleTime: const Duration(seconds: 30),
  queryFn: (key) async {
    await Future.delayed(const Duration(seconds: 3)); // Simulate network delay
    final res = await dio.get<List>(
      'https://jsonplaceholder.typicode.com/todos',
      options: Options(headers: {"content-type": "application/json"}),
    );

    final data = res.data!.map((item) => Todo.fromJSON(item)).toList();

    return data;
  },
);
