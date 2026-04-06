class Comment {

  final String id;
  final String taskId;
  final String userId;
  final String message;

  Comment({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.message,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {

    return Comment(
      id: json["id"],
      taskId: json["taskId"],
      userId: json["userId"],
      message: json["message"],
    );
  }
}