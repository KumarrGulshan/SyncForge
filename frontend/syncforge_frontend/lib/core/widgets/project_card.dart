import 'package:flutter/material.dart';
import '../../features/projects/project_model.dart';
import '../../features/projects/project_service.dart';
import '../../features/tasks/task_board_screen.dart';
import '../utils/text_formatter.dart';

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
              labelText: "Enter user email",
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

      onMemberAdded();

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
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),

      child: InkWell(

        borderRadius: BorderRadius.circular(16),

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
            children: [

              /// Project Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primary,

                child: Text(
                  TextFormatter.toTitleCase(project.name)[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              /// Project Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      TextFormatter.toTitleCase(project.name),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      TextFormatter.toTitleCase(project.description),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [

                        const Icon(
                          Icons.group,
                          size: 16,
                          color: Colors.grey,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          "Members: ${project.members.length}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),

                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              /// Add Member Button
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.person_add),
                  tooltip: "Add Member",
                  onPressed: () {
                    _showAddMemberDialog(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}