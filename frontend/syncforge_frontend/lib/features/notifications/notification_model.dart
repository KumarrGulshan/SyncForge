class AppNotification {

  final String id;
  final String message;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.message,
    required this.isRead,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {

    return AppNotification(
      id: json["id"],
      message: json["message"],
      isRead: json["isRead"],
    );
  }
}