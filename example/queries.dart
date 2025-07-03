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

final getMedicines = Query<List<dynamic>, List<Todo>, DioException>(
  [
    'medicines',
    '123',
    {"page": 1},
  ],
  queryFn: (key) async {
    final res = await dio.get<List>(
      'https://jsonplaceholder.typicode.com/todos',
      options: Options(headers: {"content-type": "application/json"}),
    );

    final data = res.data!.map((item) => Todo.fromJSON(item)).toList();

    return data;
  },
);
