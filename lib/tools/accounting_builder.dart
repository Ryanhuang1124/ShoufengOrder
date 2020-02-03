import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'menu_builder.dart';

class FinalOrder {
  String userName;
  List<String> keys;
  List<String> value;
  List<String> count;
  List<String> note;
  List<String> notePrice;
  FinalOrder() {
    keys = [];
    value = [];
    count = [];
    note = [];
    notePrice = [];
  }
}

class OrderState {
  String changes;
  String state;
  String paid = '';
}

class FinalOrderWidgets {
  List<Widget> widgets = [];
}

class IntegrateOrderObj {
  List<String> key = [];
  List<String> count = [];
  List<List<String>> note = [];
}

String stateBuilder(String inputPrice, double totalPrice) {
  double thisInputPrice = 0;
  thisInputPrice = double.parse(inputPrice);
  if (thisInputPrice < totalPrice) {
    return '-1';
  } else {
    return (thisInputPrice - totalPrice) == 0 ? '結清' : '找錢';
  }
}

String changesBuilder(String inputPrice, double totalPrice) {
  double thisInputPrice = 0;
  thisInputPrice = double.parse(inputPrice);
  if (thisInputPrice < totalPrice) {
    return '0';
  } else {
    return (thisInputPrice - totalPrice).round().toString();
  }
}

void uploadFinalOrder(fireStore, List<MenuValue> list) async {
  String userName;
  SharedPreferences pref = await SharedPreferences.getInstance();
  userName = pref.getString('userName');
  print(userName);

  if (userName != null) {
    for (int i = 0; i < list.length; i++) {
      List<String> temp = [];
      temp.add(list[i].keys);
      temp.add(list[i].value.toString());
      temp.add(list[i].notePrice);
      temp.add(list[i].note);
      temp.add(list[i].count.toString());
      await fireStore
          .collection('Members')
          .document(userName)
          .setData({i.toString(): temp}, merge: true);
    }
  }
}

void clearOrderCache(fireStore) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  String userName = pref.getString('userName');

  if (userName != null) {
    fireStore.collection('Members').document(userName).delete();
  }
}

void uploadDefaultOrderState(fireStore, List<MenuValue> list) async {
  String userName;
  SharedPreferences pref = await SharedPreferences.getInstance();
  userName = pref.getString('userName');
  await fireStore
      .collection('FinalState')
      .document(userName)
      .setData({'changes': '0', 'state': '未付', 'paid': '0'}, merge: false);
}

void uploadOrderState(fireStore, String userName, String state, String changes,
    String paid) async {
  String thisChanges;

  if (state == '結清') {
    thisChanges = '0';
  } else {
    thisChanges = changes;
  }

  print(paid);

  await fireStore.collection('FinalState').document(userName).setData(
      {'changes': thisChanges, 'state': state, 'paid': paid},
      merge: false);
}

void changeOrderState(
    fireStore, String userName, String state, String changes) async {
  String thisChanges;

  if (state == '結清') {
    thisChanges = '0';
  } else {
    thisChanges = changes;
  }

  await fireStore.collection('FinalState').document(userName).setData({
    'changes': thisChanges,
    'state': state,
  }, merge: true);
}

IntegrateOrderObj integrateBuilder(objListTemp) {
  List<String> keysList = [];
  List<String> countList = [];
  List<String> noteList = [];
  IntegrateOrderObj obj = new IntegrateOrderObj();
  String temp;

  if (objListTemp != null) {
    for (var user in objListTemp) {
      for (var keys in user.keys) {
        keysList.add(keys);
      }
      for (var count in user.count) {
        countList.add(count);
      }
      for (var note in user.note) {
        noteList.add(note);
      }
    }
    for (int i = 0; i < keysList.length; i++) {
      temp = keysList[i];
      List<String> tempList = new List<String>();
      if (!obj.key.contains(temp)) {
        //不重複
        obj.key.add(temp);
        obj.count.add(countList[i]);
        tempList.add(noteList[i]);
        obj.note.add(tempList);
      } else {
        //重複
        int element = obj.key.indexOf(temp);
        obj.count[element] =
            (int.parse(obj.count[element]) + int.parse(countList[i]))
                .toString();
        obj.note[element].add(noteList[i]);
      }
    }
  }

  return obj;
}

int sumOfTotalPriceCalculator(List<double> totalPriceList) {
  double sum = 0;

  for (var item in totalPriceList) {
    sum = sum + item;
  }
  return sum.round();
}
