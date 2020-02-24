import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoufeng_order/tools/menu_builder.dart';

void prefFavList(MenuValue obj, String storeName) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  if (pref.getStringList(storeName) == null) {
    List<String> temp = List<String>();
    temp.add(obj.keys);
    temp.add(obj.notePrice);
    temp.add(obj.note);
    temp.add(obj.count.toString());

    pref.setStringList(storeName, temp);
  } else {
    bool isRepeat = false;
    List<String> temp = pref.getStringList(storeName);
    for (int i = 0; i < temp.length; i++) {
      if (i % 4 == 0 &&
          temp[i] == obj.keys &&
          temp[i + 1] == obj.notePrice &&
          temp[i + 2] == obj.note) {
        temp[i + 3] = (int.parse(temp[i + 3]) + obj.count).toString();
        isRepeat = true;
      }
    } //是否重複？old count+=new count:做下面
    if (!isRepeat) {
      temp.add(obj.keys);
      temp.add(obj.notePrice);
      temp.add(obj.note);
      temp.add(obj.count.toString());
    }
    pref.setStringList(storeName, temp);
  }
}

void prefFavList2(MenuValue obj, String storeName) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  if (pref.getStringList(storeName) == null) {
    List<String> temp = List<String>();
    temp.add(obj.keys);
    temp.add(obj.notePrice);
    temp.add(obj.note);
    temp.add(obj.count.toString());

    pref.setStringList(storeName, temp);
  } else {
    bool isRepeat = false;
    List<String> temp = pref.getStringList(storeName);
    for (int i = 0; i < temp.length; i++) {
      if (i % 4 == 0 &&
          temp[i] == obj.keys &&
          temp[i + 1] == obj.notePrice &&
          temp[i + 2] == obj.note) {
        temp[i + 3] = (int.parse(temp[i + 3]) + obj.count).toString();
        isRepeat = true;
      }
    } //是否重複？old count+=new count:做下面
    if (!isRepeat) {
      temp.add(obj.keys);
      temp.add(obj.notePrice);
      temp.add(obj.note);
      temp.add(obj.count.toString());
    }
    pref.setStringList(storeName, temp);
  }
}

List<MenuValue> makeFavToObjList(List<String> temp) {
  List<MenuValue> objTemp = [];

  if (temp != null) {
    for (int i = 0; i < temp.length; i++) {
      if (i % 4 == 0) {
        MenuValue obj = new MenuValue(null, temp[i], null);
        obj.notePrice = temp[i + 1];
        obj.note = temp[i + 2];
        obj.count = int.parse(temp[i + 3]);
        objTemp.add(obj);
      }
    }
  }
  return objTemp != null ? objTemp : null;
}
