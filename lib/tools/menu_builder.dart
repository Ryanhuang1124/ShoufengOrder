import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math';

class MenuValue {
  String docID;
  String keys;
  String value;
  int count = 0;
  bool isShow = false;
  String note = '';
  String notePrice;
  MenuValue(docID, keys, value) {
    this.docID = docID;
    this.keys = keys;
    this.value = value;
  }
}

Future<List<MenuValue>> getMenu(fireStore) async {
  String imanomise = '';
  List<MenuValue> menuList = new List<MenuValue>();

  final mise =
      await fireStore.collection('StoreList').document('imanomise').get();

  mise.data.forEach((k, v) {
    imanomise = v;
  });
//  fetch storeName

  final menu = await fireStore.collection(imanomise).getDocuments();
  //menu is one of documents (漢堡 飲料etc)
  for (var menu in menu.documents) {
    //menu.data return a Map which include all of items(key : value)
    menu.data.forEach((k, v) {
      String vs = v.toString();
      menuList.add(new MenuValue(menu.documentID, k, vs));
    });
  }
  return menuList;
}

Future<List<MenuValue>> getMenu2(fireStore) async {
  String imanomise2 = '';
  List<MenuValue> menuList = new List<MenuValue>();

  final mise =
      await fireStore.collection('StoreList').document('imanomise2').get();

  mise.data.forEach((k, v) {
    imanomise2 = v;
  });
//  fetch storeName

  final menu = await fireStore.collection(imanomise2).getDocuments();
  //menu is one of documents (漢堡 飲料etc)
  for (var menu in menu.documents) {
    //menu.data return a Map which include all of items(key : value)
    menu.data.forEach((k, v) {
      String vs = v.toString();
      menuList.add(new MenuValue(menu.documentID, k, vs));
    });
  }
  return menuList;
}

Future<List<String>> getStore(fireStore) async {
  List<String> storeList = new List<String>();

  final stores =
      await fireStore.collection('StoreList').document('Stores').get();

  stores.data.forEach((k, v) {
    storeList.add(k);
  });

  return storeList;
}

Future<List<String>> getImanomise(fireStore) async {
  String misenamai = '';
  String url;
  List<String> imanomise = new List<String>();
  final mise =
      await fireStore.collection('StoreList').document('imanomise').get();

  await mise.data.forEach((k, v) {
    misenamai = v;
  });

  final fireStorageRef = FirebaseStorage.instance.ref().child('$misenamai');
  if (fireStorageRef != null) {
    url = await fireStorageRef.getDownloadURL();
  }

  imanomise.add(misenamai);
  imanomise.add(url);

  return imanomise;
}

Future<List<String>> getImanomise2(fireStore) async {
  String misenamai2 = '';
  String url;
  List<String> imanomise2 = new List<String>();
  final mise =
      await fireStore.collection('StoreList').document('imanomise2').get();

  await mise.data.forEach((k, v) {
    misenamai2 = v;
  });

  final fireStorageRef = FirebaseStorage.instance.ref().child('$misenamai2');
  if (fireStorageRef != null) {
    url = await fireStorageRef.getDownloadURL();
  }

  imanomise2.add(misenamai2);
  imanomise2.add(url);

  return imanomise2;
}

void uploadImanomise(fireStore, storeName) async {
  await fireStore
      .collection('StoreList')
      .document('imanomise')
      .setData({'imanomise': storeName}, merge: false);
}

void uploadImanomise2(fireStore, storeName) async {
  await fireStore
      .collection('StoreList')
      .document('imanomise2')
      .setData({'imanomise2': storeName}, merge: false);
}

void resetImanomise1(fireStore) async {
  print('aaa');
  await fireStore
      .collection('StoreList')
      .document('imanomise')
      .setData({'imanomise': '請選擇'}, merge: false);
}

void resetImanomise2(fireStore) async {
  await fireStore
      .collection('StoreList')
      .document('imanomise2')
      .setData({'imanomise2': '請選擇'}, merge: false);
}

bool isNumeric(String s) {
  if (s == null) {
    return false;
  } else {
    return double.tryParse(s) != null;
  }
} //數字檢查器

bool hasBlank(String s) {
  return s == null || s.trim() == '' || s.isEmpty ? true : false;
}
//空格檢查器
