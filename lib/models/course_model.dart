// lib/models/course_model.dart

/// Represents a Course resource from the JSONPlaceholder /posts endpoint.
///
/// We treat each "post" as a Course where:
///   - id    -> Course ID
///   - title -> Course Title
///   - body  -> Course Description
class CourseModel {
  final int id;
  final String title;
  final String body;

  const CourseModel({
    required this.id,
    required this.title,
    required this.body,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
      };

  CourseModel copyWith({int? id, String? title, String? body}) => CourseModel(
        id: id ?? this.id,
        title: title ?? this.title,
        body: body ?? this.body,
      );
}