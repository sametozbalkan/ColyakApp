import 'dart:typed_data';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  final Map<String, Uint8List?> _imageBytesMap = {};

  factory CacheManager() {
    return _instance;
  }

  CacheManager._internal();

  Future<Uint8List?> getImageBytes(String imageUrl) async {
    if (_imageBytesMap.containsKey(imageUrl)) {
      return _imageBytesMap[imageUrl];
    } else {
      try {
        FileInfo? fileInfo =
            await DefaultCacheManager().getFileFromCache(imageUrl);
        if (fileInfo != null) {
          _imageBytesMap[imageUrl] = await fileInfo.file.readAsBytes();
          return _imageBytesMap[imageUrl];
        } else {
          var response = await DefaultCacheManager().getSingleFile(imageUrl);
          _imageBytesMap[imageUrl] = await response.readAsBytes();
          return _imageBytesMap[imageUrl];
        }
      } catch (e) {
        return null;
      }
    }
  }

  Future<void> cleanDefaultCacheManager() async {
    DefaultCacheManager().emptyCache();
  }
}
