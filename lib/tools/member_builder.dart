import 'package:cloud_firestore/cloud_firestore.dart';
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

Future<bool> getWaveState() async {
  bool waveState = false;
  SharedPreferences pref = await SharedPreferences.getInstance();

  waveState =
      pref.getBool('waveState') != null ? pref.getBool('waveState') : true;

  return waveState;
}

void setBottleState(bool state) async {
  SharedPreferences pref = await SharedPreferences.getInstance();

  pref.setBool('bottleState', state);
}

void setWaveState(bool state) async {
  SharedPreferences pref = await SharedPreferences.getInstance();

  pref.setBool('waveState', state);
}

void uploadDeveloperAdvices(String userName, String content) async {
  DateTime now = DateTime.now();

  String date = now.year.toString() +
      '/' +
      now.month.toString() +
      '/' +
      now.day.toString();

  final fireStore = Firestore.instance;
  await fireStore
      .collection('Advices')
      .document(userName)
      .setData({date: content}, merge: true);
}
