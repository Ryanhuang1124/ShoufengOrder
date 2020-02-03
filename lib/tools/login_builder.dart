import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  String id = '';
  String name = '';

  UserData(String id, String name) {
    this.id = id;
    this.name = name;
  }
}

Future<bool> getUserBottleSetting() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isToggle = false;
  isToggle = prefs.getBool('isToggle');
  if (isToggle != null) {
    return isToggle;
  } else {
    return false;
  }
}

void setUserBottleSetting(bool isLogin) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('isToggle', isLogin);
}

Future<bool> getUserIsLogin() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLogin = false;
  isLogin = prefs.getBool('isLogin');
  if (isLogin != null) {
    return isLogin;
  } else {
    return false;
  }
}

void setUserCache(bool isLogin, String userName) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('isLogin', isLogin);
  prefs.setString('userName', userName);
}

Future<List<UserData>> getMemberID(fireStore) async {
  List<UserData> temp = [];
  final stores = await fireStore.collection('MemberData').document('ID').get();

  stores.data.forEach((k, v) {
    temp.add(UserData(v, k));
  });

  return temp;
}
