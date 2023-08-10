import 'package:shared_preferences/shared_preferences.dart';

//==========================================================================================================================================================

class CacheHelper {
  static late SharedPreferences sharedPre;


  static init() async {
    sharedPre = await SharedPreferences.getInstance();
  }

//==========================================================================================================================================================


  static Future<bool> putData({
    required String key,
    required bool value,
  }) async{
    return await sharedPre.setBool(key, value);
  }

//==========================================================================================================================================================


  static dynamic getData({
    required String key,
  }) {
    return sharedPre.get(key);
  }


//==========================================================================================================================================================
static Future<bool> saveData({
    required String key,
    required dynamic value,
  }) async {
    if (value is String) return await sharedPre.setString(key, value);
    if (value is int) return await sharedPre.setInt(key, value);
    if (value is bool) return await sharedPre.setBool(key, value);

    return await sharedPre.setDouble(key, value);
  }

//================================================================================================================================


  static Future<bool> removeData({
    required String key,
  }) async
  {
    return await sharedPre.remove(key);
  }

//================================================================================================================================




}

//==========================================================================================================================================================

