class TaskFile {

  final String id;
  final String fileName;
  final String fileType;

  TaskFile({
    required this.id,
    required this.fileName,
    required this.fileType,
  });

  factory TaskFile.fromJson(Map<String, dynamic> json) {

    return TaskFile(
      id: json["id"],
      fileName: json["fileName"],
      fileType: json["fileType"],
    );
  }
}