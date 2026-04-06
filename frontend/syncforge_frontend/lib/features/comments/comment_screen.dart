import 'package:flutter/material.dart';
import 'comment_service.dart';
import 'comment_model.dart';

class CommentScreen extends StatefulWidget {

  final String taskId;

  const CommentScreen({super.key, required this.taskId});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {

  late Future<List<Comment>> commentsFuture;

  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() {
    commentsFuture = CommentService.getComments(widget.taskId);
  }

  Future<void> sendComment() async {

    if (controller.text.trim().isEmpty) return;

    await CommentService.addComment(
      widget.taskId,
      controller.text.trim(),
    );

    controller.clear();

    setState(() {
      _loadComments();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Task Comments"),
      ),

      body: Column(
        children: [

          Expanded(
            child: FutureBuilder<List<Comment>>(
              future: commentsFuture,

              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Failed to load comments"),
                  );
                }

                final list = snapshot.data ?? [];

                if (list.isEmpty) {
                  return const Center(
                    child: Text("No comments yet"),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: list.length,

                  itemBuilder: (context, index) {

                    final c = list[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),

                      child: ListTile(
                        title: Text(c.message),
                        subtitle: Text("User: ${c.userId}"),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey),
              ),
            ),

            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Write a comment...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.blue,
                  onPressed: sendComment,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}