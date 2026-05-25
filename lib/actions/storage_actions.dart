// ローカル保存系。
// UIDSL の storage.save / storage.load アクションから呼び出される。

import 'package:shared_preferences/shared_preferences.dart';

class StorageActions {
  static Future<void> save(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String)  { await prefs.setString(key, value); return; }
    if (value is int)     { await prefs.setInt(key, value);    return; }
    if (value is double)  { await prefs.setDouble(key, value); return; }
    if (value is bool)    { await prefs.setBool(key, value);   return; }
    await prefs.setString(key, value.toString());
  }

  static Future<dynamic> load(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }

  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
