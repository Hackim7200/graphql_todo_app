import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';

import '../model/TodoModel.dart';

class TodoService {
  const TodoService();
  static const String _graphqlApiName = 'PomodoroPlansGraphQLApi';

  Future<List<Todo>> listTodos({int limit = 50}) async {
    final request = GraphQLRequest<String>(
      apiName: _graphqlApiName,
      document: r'''
        query ListTodos($limit: Int) {
          listTodos(limit: $limit) {
            items { id title isCompleted }
            nextToken
          }
        }
      ''',
      variables: {'limit': limit},
    );

    final response = await Amplify.API.query(request: request).response;
    _throwIfGraphQLErrors(response.errors, operation: 'list');

    final payload = _requireData(response.data);
    final data = jsonDecode(payload)['listTodos'] as Map<String, dynamic>;
    return (data['items'] as List)
        .map((t) => Todo.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  Future<Todo> createTodo(String title) async {
    final request = GraphQLRequest<String>(
      apiName: _graphqlApiName,
      document: r'''
        mutation CreateTodo($input: CreateTodoInput!) {
          createTodo(input: $input) {
            id title isCompleted owner
          }
        }
      ''',
      variables: {
        'input': {'title': title},
      },
    );

    final response = await Amplify.API.mutate(request: request).response;
    _throwIfGraphQLErrors(response.errors, operation: 'create');

    final payload = _requireData(response.data);
    return Todo.fromJson(
      jsonDecode(payload)['createTodo'] as Map<String, dynamic>,
    );
  }

  Future<Todo> updateTodoCompletion(Todo todo) async {
    final request = GraphQLRequest<String>(
      apiName: _graphqlApiName,
      document: r'''
        mutation UpdateTodo($input: UpdateTodoInput!) {
          updateTodo(input: $input) {
            id title isCompleted owner
          }
        }
      ''',
      variables: {
        'input': {'id': todo.id, 'isCompleted': !todo.isCompleted},
      },
    );

    final response = await Amplify.API.mutate(request: request).response;
    _throwIfGraphQLErrors(response.errors, operation: 'update');

    final payload = _requireData(response.data);
    return Todo.fromJson(
      jsonDecode(payload)['updateTodo'] as Map<String, dynamic>,
    );
  }

  Future<void> deleteTodo(String id) async {
    final request = GraphQLRequest<String>(
      apiName: _graphqlApiName,
      document: r'''
        mutation DeleteTodo($id: ID!) {
          deleteTodo(id: $id) { id owner }
        }
      ''',
      variables: {'id': id},
    );

    final response = await Amplify.API.mutate(request: request).response;
    _throwIfGraphQLErrors(response.errors, operation: 'delete');
  }

  Stream<void> onTodoChanged() {
    final request = GraphQLRequest<String>(
      apiName: _graphqlApiName,
      document: r'''
        subscription OnTodoChanged {
          onTodoChanged {
            id
          }
        }
      ''',
    );

    return Amplify.API.subscribe(
      request,
      onEstablished: () => safePrint('Todo subscription established'),
    ).map((response) {
      _throwIfGraphQLErrors(response.errors, operation: 'subscribe to todos');
      _requireData(response.data);
    });
  }

  static String _requireData(String? data) {
    if (data == null || data.isEmpty) {
      throw const TodoServiceException('GraphQL response data was empty.');
    }
    return data;
  }

  static void _throwIfGraphQLErrors(
    List<GraphQLResponseError> errors, {
    required String operation,
  }) {
    if (errors.isNotEmpty) {
      throw TodoServiceException(
        'Failed to $operation todo(s): ${errors.map((e) => e.message).join(', ')}',
      );
    }
  }
}

class TodoServiceException implements Exception {
  const TodoServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
