import 'package:flutter/material.dart';
import 'task_service.dart';
import 'task_model.dart';
import '../../core/storage/token_storage.dart';
import '../../core/websocket/socket_service.dart';
import '../comments/comment_screen.dart';

class TaskBoardScreen extends StatefulWidget {
  final String projectId;

  const TaskBoardScreen({super.key, required this.projectId});

  @override
  State<TaskBoardScreen> createState() => _TaskBoardScreenState();
}

class _TaskBoardScreenState extends State<TaskBoardScreen> {

  late Future<List<Task>> _tasksFuture;
  final SocketService socket = SocketService();

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _connectSocket();
  }

  void _loadTasks() {
    _tasksFuture = TaskService.getTasks(widget.projectId);
  }

  Future<void> _connectSocket() async {

    final token = await TokenStorage.getToken();
    if (token == null) return;

    socket.connect(
      projectId: widget.projectId,
      token: token,
      onMessage: (message) {

        print("Realtime update received: $message");

        setState(() {
          _loadTasks();
        });
      },
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }

  List<Task> _filter(List<Task> tasks, String status) {
    return tasks.where((t) => t.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Task Board"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTaskDialog,
        child: const Icon(Icons.add),
      ),

      body: FutureBuilder<List<Task>>(

        future: _tasksFuture,

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No tasks found"));
          }

          final tasks = snapshot.data!;

          final todo = _filter(tasks, "TODO");
          final progress = _filter(tasks, "IN_PROGRESS");
          final done = _filter(tasks, "DONE");

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            child: SizedBox(
              height: MediaQuery.of(context).size.height,

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _buildColumn("TODO", todo),
                  _buildColumn("IN_PROGRESS", progress),
                  _buildColumn("DONE", done),

                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColumn(String status, List<Task> tasks) {

    String title = status.replaceAll("_", " ");

    return Container(
      width: 280,
      margin: const EdgeInsets.all(12),

      child: DragTarget<Task>(

        onAccept: (task) async {

          if (task.status != status) {

            await TaskService.updateStatus(
              widget.projectId,
              task.id,
              status,
            );

            setState(() {
              _loadTasks();
            });
          }
        },

        builder: (context, candidateData, rejectedData) {

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,

                  itemBuilder: (context, index) {

                    final task = tasks[index];

                    return LongPressDraggable<Task>(

                      data: task,

                      feedback: Material(
                        color: Colors.transparent,
                        child: _taskCard(task),
                      ),

                      childWhenDragging: Opacity(
                        opacity: 0.4,
                        child: _taskCard(task),
                      ),

                      child: _taskCard(task),
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _taskCard(Task task) {

    return InkWell(

      onTap: () {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CommentScreen(taskId: task.id),
          ),
        );

      },

      child: Card(
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 12),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),

        child: Padding(
          padding: const EdgeInsets.all(14),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 6),

              if (task.description.isNotEmpty)
                Text(
                  task.description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateTaskDialog() {

    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,

      builder: (context) {

        return AlertDialog(
          title: const Text("Create Task"),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Task Title",
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

                await TaskService.createTask(
                  widget.projectId,
                  titleController.text,
                  descController.text,
                );

                Navigator.pop(context);

                setState(() {
                  _loadTasks();
                });
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }
}