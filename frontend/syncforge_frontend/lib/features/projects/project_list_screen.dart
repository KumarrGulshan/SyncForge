import 'package:flutter/material.dart';
import 'project_service.dart';
import 'project_model.dart';
import '../../core/widgets/project_card.dart';

class ProjectListScreen extends StatefulWidget {
  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {

  late Future<List<Project>> projects;

  @override
  void initState() {
    super.initState();
    projects = ProjectService.getProjects();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("SyncForge Projects"),
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
              return ProjectCard(project: list[index]);
            },
          );
        },
      ),
    );
  }
}