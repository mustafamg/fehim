import 'package:shared_preferences/shared_preferences.dart';
class SharedPrefrencesHelper {
  static SharedPreferences? sharedPreferences;
  static setUpShared() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }
  
  static Future<bool> saveString({key, value}) async {
    return await sharedPreferences!.setString(key, value);
  }
  
  static String? getString({key}) {
    return sharedPreferences!.getString(key);
  }
  
  static Future<bool> remove({key}) {
    return sharedPreferences!.remove(key);
  }
}
