import 'package:flutter/material.dart';
import 'package:colyakapp/cachemanager/CacheManager.dart';

class SettingsViewModel extends ChangeNotifier {
  bool _isClearingCache = false;

  bool get isClearingCache => _isClearingCache;

  Future<void> clearCache() async {
    _isClearingCache = true;
    notifyListeners();

    await CacheManager().cleanDefaultCacheManager();

    _isClearingCache = false;
    notifyListeners();
  }
}
