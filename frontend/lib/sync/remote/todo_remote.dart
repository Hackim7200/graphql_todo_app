/// Handles GraphQL calls to push and pull todo records from the backend.
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';

class TodoRemote {
  const TodoRemote();

  static const String _graphqlApiName = 'PomodoroPlansGraphQLApi';

  Future<void> upsertTodo(Map<String, dynamic> todo) async {
    final request = GraphQLRequest<String>(
      apiName: _graphqlApiName,
      document: r'''
        mutation UpsertTodo($input: UpdateTodoInput!) {
          updateTodo(input: $input) { id }
        }
      ''',
      variables: {'input': todo},
    );

    final response = await Amplify.API.mutate(request: request).response;
    _throwIfGraphQLErrors(response.errors, operation: 'upsert todo');
    _requireData(response.data);
  }

  Future<List<Map<String, dynamic>>> getTodosSince(DateTime? since) async {
    final updatedAfter = (since ?? DateTime.fromMillisecondsSinceEpoch(0))
        .toUtc()
        .toIso8601String();

    final request = GraphQLRequest<String>(
      apiName: _graphqlApiName,
      document: r'''
        query ListTodosSince($updatedAfter: AWSDateTime!) {
          listTodos(updatedAfter: $updatedAfter) {
            items {
              id
              title
              completed
              version
              updatedAt
              createdAt
              isDeleted
              syncStatus
            }
          }
        }
      ''',
      variables: {'updatedAfter': updatedAfter},
    );

    final response = await Amplify.API.query(request: request).response;
    _throwIfGraphQLErrors(response.errors, operation: 'list todos');
    final payload = _requireData(response.data);
    final decoded = jsonDecode(payload) as Map<String, dynamic>;
    final root = decoded['listTodos'] as Map<String, dynamic>? ?? const {};
    final items = root['items'] as List<dynamic>? ?? const [];
    return items.whereType<Map<String, dynamic>>().toList();
  }

  static String _requireData(String? data) {
    if (data == null || data.isEmpty) {
      throw Exception('GraphQL response data was empty.');
    }
    return data;
  }

  static void _throwIfGraphQLErrors(
    List<GraphQLResponseError> errors, {
    required String operation,
  }) {
    if (errors.isNotEmpty) {
      throw Exception(
        'Failed to $operation: ${errors.map((e) => e.message).join(', ')}',
      );
    }
  }
}
