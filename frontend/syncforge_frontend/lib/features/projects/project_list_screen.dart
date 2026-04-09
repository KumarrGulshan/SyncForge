import 'package:flutter/material.dart';
import 'project_service.dart';
import 'project_model.dart';
import '../../core/widgets/project_card.dart';
import '../../core/storage/token_storage.dart';
import '../../core/websocket/socket_service.dart';
import '../notifications/notification_model.dart';
import '../notifications/notification_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {

  late Future<List<Project>> projects;

  final SocketService socket = SocketService();

  List<AppNotification> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadProjects();
    _connectNotifications();
  }

  void _loadProjects() {
    projects = ProjectService.getProjects();
  }

  Future<void> _connectNotifications() async {

    final token = await TokenStorage.getToken();
    final userId = await TokenStorage.getUserId();

    if(token == null || userId == null) return;

    socket.connect(
    token: token,
     projectId: "",
    userId: userId,
    onProjectEvent: (event) {},
    onNotification: (notification) {

      print("Notification received: $notification");

      setState(() {
       notifications.insert(
         0,
         AppNotification.fromJson(notification),
        );
      });

    },
   );
  }

  void _showCreateProjectDialog() {

    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(
          title: const Text("Create Project"),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Project Name",
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: "Description",
                ),
              ),
            ],
          ),

          actions: [

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {

                await ProjectService.createProject(
                  nameController.text.trim(),
                  descController.text.trim(),
                );

                Navigator.pop(context);

                setState(() {
                  _loadProjects();
                });

              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("SyncForge Projects"),

        actions: [

          Stack(
            children: [

              IconButton(
                icon: const Icon(Icons.notifications),

                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NotificationScreen(
                        notifications: notifications,
                      ),
                    ),
                  );

                },
              ),

              if(notifications.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      notifications.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                )

            ],
          )

        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateProjectDialog,
        child: const Icon(Icons.add),
      ),

      body: FutureBuilder<List<Project>>(

        future: projects,

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No projects found"));
          }

          final list = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,

            itemBuilder: (context, index) {

              return ProjectCard(
                project: list[index],

                onMemberAdded: () {
                  setState(() {
                    _loadProjects();
                  });
                },
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }
}