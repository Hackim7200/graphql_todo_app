class Todo {
  const Todo({
    required this.id,
    required this.title,
    required this.isCompleted,
    this.owner,
  });

  final String id;
  final String title;
  final bool isCompleted;
  final String? owner;

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: (json['title'] as String?) ?? '',
      isCompleted: (json['isCompleted'] as bool?) ?? false,
      owner: json['owner'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      if (owner != null) 'owner': owner,
    };
  }
}
