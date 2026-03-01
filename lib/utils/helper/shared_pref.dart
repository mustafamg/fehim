import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefrencesHelper {
  static SharedPreferences? sharedPreferences;
  static Future<void> setUpShared() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<bool> saveString({required String key, required String value}) async {
    return await sharedPreferences!.setString(key, value);
  }

  static String? getString({required String key}) {
    return sharedPreferences!.getString(key);
  }

  static Future<bool> remove({required String key}) {
    return sharedPreferences!.remove(key);
  }
}
