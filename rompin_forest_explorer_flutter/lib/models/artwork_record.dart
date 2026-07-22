import 'package:cloud_firestore/cloud_firestore.dart';

class ArtworkRecord {
  const ArtworkRecord({
    this.id,
    required this.ownerId,
    required this.participantId,
    required this.sessionId,
    required this.title,
    required this.artworkStoragePath,
    this.artworkDownloadURL,
    this.sourceImageIds = const [],
    required this.artworkType,
    required this.createdAt,
    required this.updatedAt,
  });

  final String? id;
  final String ownerId;
  final String participantId;
  final String sessionId;
  final String title;
  final String artworkStoragePath;
  final String? artworkDownloadURL;
  final List<String> sourceImageIds;
  final String artworkType;
  final DateTime createdAt;
  final DateTime updatedAt;

  // ── Firestore helpers ──────────────────────────────────────────────────

  factory ArtworkRecord.fromMap(Map<String, dynamic> map, {String? id}) {
    return ArtworkRecord(
      id: id ?? map['id'] as String?,
      ownerId: map['ownerId'] as String? ?? '',
      participantId: map['participantId'] as String? ?? '',
      sessionId: map['sessionId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      artworkStoragePath: map['artworkStoragePath'] as String? ?? '',
      artworkDownloadURL: map['artworkDownloadURL'] as String?,
      sourceImageIds: map['sourceImageIds'] != null
          ? List<String>.from(map['sourceImageIds'] as List)
          : const [],
      artworkType: map['artworkType'] as String? ?? '',
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'participantId': participantId,
      'sessionId': sessionId,
      'title': title,
      'artworkStoragePath': artworkStoragePath,
      'artworkDownloadURL': artworkDownloadURL,
      'sourceImageIds': sourceImageIds,
      'artworkType': artworkType,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'title': title,
      'artworkStoragePath': artworkStoragePath,
      'artworkDownloadURL': artworkDownloadURL,
      'sourceImageIds': sourceImageIds,
      'artworkType': artworkType,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // ── copyWith ───────────────────────────────────────────────────────────

  ArtworkRecord copyWith({
    String? id,
    String? ownerId,
    String? participantId,
    String? sessionId,
    String? title,
    String? artworkStoragePath,
    String? artworkDownloadURL,
    List<String>? sourceImageIds,
    String? artworkType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ArtworkRecord(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      participantId: participantId ?? this.participantId,
      sessionId: sessionId ?? this.sessionId,
      title: title ?? this.title,
      artworkStoragePath: artworkStoragePath ?? this.artworkStoragePath,
      artworkDownloadURL: artworkDownloadURL ?? this.artworkDownloadURL,
      sourceImageIds: sourceImageIds ?? this.sourceImageIds,
      artworkType: artworkType ?? this.artworkType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArtworkRecord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          sessionId == other.sessionId &&
          title == other.title;

  @override
  int get hashCode => Object.hash(id, sessionId, title);

  @override
  String toString() =>
      'ArtworkRecord(id: $id, title: $title, artworkType: $artworkType)';
}
