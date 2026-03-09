import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

@singleton
class AudioCacheService {
  final Dio _dio = Dio();

  String _generateFileName(String url) {
    final bytes = utf8.encode(url);
    final digest = sha256.convert(bytes);
    final ext = url.split('.').last.split('?').first;
    return '${digest.toString()}.$ext';
  }

  Future<String?> getCachedAudioPath(String url) async {
    if (url.isEmpty) return null;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${dir.path}/audio_cache');

      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }

      final fileName = _generateFileName(url);
      final file = File('${audioDir.path}/$fileName');

      if (await file.exists()) {
        return file.path;
      }

      // Download if not exists
      await _dio.download(url, file.path);
      return file.path;
    } catch (e) {
      // Return null if download fails (e.g., offline)
      // This allows the caller to handle offline scenario appropriately
      return null;
    }
  }

  Future<void> prefetchAudios(List<String> urls) async {
    for (final url in urls) {
      if (url.isNotEmpty) {
        await getCachedAudioPath(url);
      }
    }
  }
}
