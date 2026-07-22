class StudentActivityProgress {
  const StudentActivityProgress({
    required this.activityNumber,
    required this.progress,
    required this.isCompleted,
  });

  final int activityNumber;
  final double progress;
  final bool isCompleted;

  factory StudentActivityProgress.fromMap(Map<String, dynamic> data) {
    final progress = (data['progress'] as num?)?.toDouble() ?? 0;
    return StudentActivityProgress(
      activityNumber: (data['activityNumber'] as num?)?.toInt() ?? 0,
      progress: progress.clamp(0.0, 1.0),
      isCompleted: data['isCompleted'] == true || progress >= 1,
    );
  }
}
