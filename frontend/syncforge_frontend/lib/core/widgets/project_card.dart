import 'package:flutter/material.dart';
import '../../features/projects/project_model.dart';
import '../../features/projects/project_service.dart';
import '../../features/tasks/task_board_screen.dart';

class ProjectCard extends StatelessWidget {

  final Project project;
  final VoidCallback onMemberAdded;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onMemberAdded,
  });

  Future<void> _showAddMemberDialog(BuildContext context) async {

    final userIdController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {

        return AlertDialog(
          title: const Text("Add Project Member"),

          content: TextField(
            controller: userIdController,
            decoration: const InputDecoration(
              labelText: "User ID / Email",
            ),
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {

                final userId = userIdController.text.trim();

                if (userId.isEmpty) return;

                await ProjectService.addMember(
                  project.id,
                  userId,
                );

                Navigator.pop(context, true);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );

    if (result == true) {

      onMemberAdded();   // 🔥 refresh project list

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Member added successfully"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),

      child: InkWell(

        onTap: () {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskBoardScreen(
                projectId: project.id,
              ),
            ),
          );

        },

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      project.description,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: const Icon(Icons.person_add),
                tooltip: "Add Member",
                onPressed: () {
                  _showAddMemberDialog(context);
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}