enum StudentDiscoveryType { observation, sensory, treasure, artwork }

class StudentDiscovery {
  const StudentDiscovery({
    required this.id,
    required this.participantId,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.createdAt,
    required this.imageValue,
    required this.imageUrl,
    required this.source,
  });

  final String id;
  final String participantId;
  final String title;
  final String subtitle;
  final StudentDiscoveryType type;
  final DateTime? createdAt;
  final String imageValue;
  final String? imageUrl;
  final String source;
}

class StudentDiscoveryResult {
  const StudentDiscoveryResult({
    required this.items,
    required this.sourceErrors,
  });

  final List<StudentDiscovery> items;
  final List<String> sourceErrors;
}
