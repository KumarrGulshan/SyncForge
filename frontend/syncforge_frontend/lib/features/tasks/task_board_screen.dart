import 'package:flutter/material.dart';
import 'task_service.dart';
import 'task_model.dart';
import '../../core/storage/token_storage.dart';
import '../../core/websocket/socket_service.dart';
import '../../core/utils/text_formatter.dart';
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
    final userId = await TokenStorage.getUserId();

    if (token == null) return;

    socket.connect(
      token: token,
      projectId: widget.projectId,
      userId: userId!,
      onProjectEvent: (event) {

        print("Realtime update: $event");

        setState(() {
          _loadTasks();
        });

      },
      onNotification: (notification) {
        print("Notification: $notification");
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

            child: Row(
              children: [

                _buildColumn("TODO", todo),
                _buildColumn("IN_PROGRESS", progress),
                _buildColumn("DONE", done),

              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildColumn(String status, List<Task> tasks) {

    String title = TextFormatter.toTitleCase(status.replaceAll("_", " "));

    return Container(
      width: 320,
      height: MediaQuery.of(context).size.height - 120,

      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),

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

              /// COLUMN HEADER
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),

                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),

                child: Text(
                  "$title (${tasks.length})",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              /// TASK LIST
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,

                  itemBuilder: (context, index) {

                    final task = tasks[index];

                    return LongPressDraggable<Task>(

                      data: task,

                      feedback: Material(
                        color: Colors.transparent,
                        child: SizedBox(
                          width: 260,
                          child: _taskCard(task),
                        ),
                      ),

                      childWhenDragging: Opacity(
                        opacity: 0.35,
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

      borderRadius: BorderRadius.circular(14),

      onTap: () {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CommentScreen(taskId: task.id),
          ),
        );

      },

      child: Card(

        elevation: 6,
        shadowColor: Colors.black26,
        margin: const EdgeInsets.only(bottom: 14),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      TextFormatter.toTitleCase(task.title),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                ],
              ),

              const SizedBox(height: 8),

              if (task.description.isNotEmpty)
                Text(
                  TextFormatter.toTitleCase(task.description),
                  style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .color,
                    fontSize: 13,
                  ),
                ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      TextFormatter.toTitleCase(
                          task.status.replaceAll("_", " ")),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),

                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 16,
                    color: Colors.grey,
                  )

                ],
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

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