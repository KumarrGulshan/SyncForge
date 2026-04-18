class AppNotification {

  final String id;
  final String message;
  final bool isRead;
  final String createdAt;

  AppNotification({
    required this.id,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {

    return AppNotification(
      id: json["id"],
      message: json["message"],
      isRead: json["read"] ?? false,
      createdAt: json["createdAt"],
    );
  }
}