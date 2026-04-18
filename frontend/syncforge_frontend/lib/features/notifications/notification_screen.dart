import 'package:flutter/material.dart';
import 'notification_model.dart';
import 'notification_service.dart';

class NotificationScreen extends StatefulWidget {

  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  late Future<List<AppNotification>> notifications;

  @override
  void initState() {
    super.initState();
    notifications = NotificationService.getNotifications();
  }

  Future<void> refresh() async {
    setState(() {
      notifications = NotificationService.getNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Notifications"),
      ),

      body: FutureBuilder<List<AppNotification>>(

        future: notifications,

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "🔔 No notifications yet\nActivity updates will appear here.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final list = snapshot.data!;

          return RefreshIndicator(

            onRefresh: refresh,

            child: ListView.builder(

              padding: const EdgeInsets.all(16),

              itemCount: list.length,

              itemBuilder: (context, index) {

                final n = list[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),

                  child: Card(

                    elevation: 4,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: ListTile(

                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),

                      leading: CircleAvatar(
                        backgroundColor: n.isRead
                            ? Colors.grey.shade300
                            : Theme.of(context).colorScheme.secondary,

                        child: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                        ),
                      ),

                      title: Text(
                        n.message,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),

                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          n.createdAt,
                          style: TextStyle(
                            color: n.isRead
                                ? Colors.grey
                                : Theme.of(context).colorScheme.primary,
                            fontWeight: n.isRead
                                ? FontWeight.normal
                                : FontWeight.w600,
                          ),
                        ),
                      ),

                      trailing: n.isRead
                          ? const Icon(
                              Icons.done,
                              size: 18,
                              color: Colors.grey,
                            )
                          : const Icon(
                              Icons.fiber_new,
                              size: 20,
                              color: Colors.redAccent,
                            ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}