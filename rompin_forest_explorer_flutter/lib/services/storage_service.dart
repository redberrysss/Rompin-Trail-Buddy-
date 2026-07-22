import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final StorageService instance = StorageService._();
  StorageService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(String path, File file) async {
    final ref = _storage.ref().child(path);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> deleteFile(String path) async {
    final ref = _storage.ref().child(path);
    await ref.delete();
  }

  Future<void> deleteUserFiles(String userId) async {
    await _deleteFolder(_storage.ref().child('users/$userId'));
  }

  Future<void> _deleteFolder(Reference folder) async {
    final result = await folder.listAll();
    for (final prefix in result.prefixes) {
      await _deleteFolder(prefix);
    }
    for (final item in result.items) {
      await item.delete();
    }
  }

  Future<String> getDownloadURL(String path) async {
    final ref = _storage.ref().child(path);
    return await ref.getDownloadURL();
  }

  Future<String?> resolveImageUrl(String? value) async {
    final candidate = value?.trim() ?? '';
    if (candidate.isEmpty) return null;

    final uri = Uri.tryParse(candidate);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return candidate;
    }
    if (candidate.startsWith('file://') ||
        candidate.startsWith('/') ||
        RegExp(r'^[A-Za-z]:[\\/]').hasMatch(candidate)) {
      debugPrint(
        '[StorageService] Ignoring device-local image path: $candidate',
      );
      return null;
    }

    try {
      final reference = candidate.startsWith('gs://')
          ? _storage.refFromURL(candidate)
          : _storage.ref().child(candidate);
      return await reference.getDownloadURL();
    } on FirebaseException catch (error, stackTrace) {
      debugPrint(
        '[StorageService] Unable to resolve image "$candidate": '
        '${error.code} ${error.message}',
      );
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }
}
