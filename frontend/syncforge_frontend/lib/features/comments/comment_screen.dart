import 'package:flutter/material.dart';
import 'comment_service.dart';
import 'comment_model.dart';
import 'package:file_picker/file_picker.dart';
import '../files/file_service.dart';
import '../files/file_model.dart';

class CommentScreen extends StatefulWidget {

  final String taskId;

  const CommentScreen({super.key, required this.taskId});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {

  late Future<List<Comment>> commentsFuture;
  late Future<List<TaskFile>> filesFuture;

  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    commentsFuture = CommentService.getComments(widget.taskId);
    filesFuture = FileService.getFiles(widget.taskId);
  }

  Future<void> sendComment() async {

    if (controller.text.trim().isEmpty) return;

    await CommentService.addComment(
      widget.taskId,
      controller.text.trim(),
    );

    controller.clear();

    setState(() {
      _loadData();
    });
  }

  Future<void> pickFile() async {

  try {

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf'],
      withData: false,
    );

    if (result == null) return;

    final file = result.files.first;

    if (file.path == null) {
      print("File path is null");
      return;
    }

    // Print debug info
    print("FILE NAME: ${file.name}");
    print("FILE PATH: ${file.path}");
    print("FILE SIZE: ${file.size}");

    // Backend limit = 5MB
    const maxSize = 5 * 1024 * 1024;

    if (file.size > maxSize) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("File exceeds 5MB limit"),
        ),
      );

      return;
    }

    // Upload file
    await FileService.uploadFile(widget.taskId, file);

    // Reload comments + attachments
    setState(() {
      _loadData();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${file.name} uploaded successfully"),
      ),
    );

  } catch (e) {

    print("UPLOAD ERROR: $e");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("File upload failed"),
      ),
    );

  }
}


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Task Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: pickFile,
          )
        ],
      ),

      body: Column(
        children: [

          /// ATTACHMENTS
          FutureBuilder<List<TaskFile>>(
            future: filesFuture,
            builder: (context, snapshot) {

              if (!snapshot.hasData) {
                return const SizedBox();
              }

              final files = snapshot.data!;

              if (files.isEmpty) {
                return const SizedBox();
              }

              return Container(
                padding: const EdgeInsets.all(10),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Attachments",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    ...files.map((f) {

                      return Card(
                        child: ListTile(

                          leading: const Icon(Icons.attach_file),

                          title: Text(f.fileName),

                          trailing: IconButton(
                            icon: const Icon(Icons.download),

                            onPressed: () async {

                              await FileService.downloadFile(
                                widget.taskId,
                                f.id,
                                f.fileName,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${f.fileName} downloaded"),
                                ),
                              );
                            },
                          ),
                        ),
                      );

                    }).toList()
                  ],
                ),
              );
            },
          ),

          /// COMMENTS
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

          /// COMMENT INPUT
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