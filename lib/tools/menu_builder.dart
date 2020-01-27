import 'package:firebase_storage/firebase_storage.dart';

class MenuValue {
  String docID;
  String keys;
  int value;
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
  print('storeName:$imanomise');
//  fetch storeName

  final menu = await fireStore.collection(imanomise).getDocuments();
  //menu is one of document (漢堡 飲料etc)
  for (var menu in menu.documents) {
    //menu.data return a Map which include all of items(key : value)
    menu.data.forEach((k, v) {
      menuList.add(new MenuValue(menu.documentID, k, v));
    });
  }
  print('menu get');
  return menuList;
}

Future<List<String>> getStore(fireStore) async {
  List<String> storeList = new List<String>();

  final stores =
      await fireStore.collection('StoreList').document('Stores').get();

  stores.data.forEach((k, v) {
    storeList.add(k);
  });

  print('storeList get');
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

  final fireStorageRef = FirebaseStorage.instance.ref().child('$misenamai.jpg');
  if (fireStorageRef != null) {
    url = await fireStorageRef.getDownloadURL();
  }

  imanomise.add(misenamai);
  imanomise.add(url);

  return imanomise;
}

void uploadImanomise(fireStore, storeName) async {
  await fireStore
      .collection('StoreList')
      .document('imanomise')
      .setData({'imanomise': storeName}, merge: false);
}

void uploadFinalOrder() {}

bool isNumeric(String s) {
  if (s == null) {
    return false;
  } else {
    return double.tryParse(s) != null;
  }
} //數字檢查器
