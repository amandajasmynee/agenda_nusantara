class TaskModel {
  final int? id;
  final String title;
  final String description;
  final String dueDate;
  final String category;
  final int isDone;
  final String? completedDate;

  TaskModel({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.category,
    this.isDone = 0,
    this.completedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate,
      'category': category,
      'is_done': isDone,
      'completed_date': completedDate,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      dueDate: map['due_date'] as String,
      category: map['category'] as String,
      isDone: map['is_done'] as int,
      completedDate: map['completed_date'] as String?,
    );
  }

  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    String? dueDate,
    String? category,
    int? isDone,
    String? completedDate,
    bool clearCompletedDate = false,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      isDone: isDone ?? this.isDone,
      completedDate:
          clearCompletedDate ? null : (completedDate ?? this.completedDate),
    );
  }
}