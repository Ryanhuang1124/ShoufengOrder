import 'package:shared_preferences/shared_preferences.dart';

Future<String> getUserName() async {
  String userName;
  SharedPreferences pref = await SharedPreferences.getInstance();

  userName = pref.getString('userName');

  return userName != null ? userName : 'Unknow';
}

Future<bool> getBottleState() async {
  bool bottleState = false;
  SharedPreferences pref = await SharedPreferences.getInstance();

  bottleState =
      pref.getBool('bottleState') != null ? pref.getBool('bottleState') : false;

  return bottleState;
}

void setBottleState(bool state) async {
  SharedPreferences pref = await SharedPreferences.getInstance();

  pref.setBool('bottleState', state);
}
