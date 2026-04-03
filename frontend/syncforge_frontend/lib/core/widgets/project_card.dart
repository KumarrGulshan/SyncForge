import 'package:flutter/material.dart';
import '../../features/projects/project_model.dart';
import '../../features/tasks/task_board_screen.dart';

class ProjectCard extends StatelessWidget {

  final Project project;

  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

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

      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8),

        child: Padding(
          padding: const EdgeInsets.all(16),

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
      ),
    );
  }
}