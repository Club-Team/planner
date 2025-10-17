class Completion {
  int? id;
  int taskId;
  String dateIso; // date string yyyy-mm-dd only

  Completion({this.id, required this.taskId, required this.dateIso});

  Map<String, dynamic> toMap() => {
        'id': id,
        'taskId': taskId,
        'dateIso': dateIso,
      };

  factory Completion.fromMap(Map<String, dynamic> m) => Completion(
        id: m['id'] as int?,
        taskId: m['taskId'] as int,
        dateIso: m['dateIso'] as String,
      );
}
