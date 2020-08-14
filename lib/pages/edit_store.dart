import 'dart:io';
import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shoufeng_order/tools/menu_builder.dart';
import 'package:http/http.dart' as http;

class EditStorePage extends StatefulWidget {
  final String storeName;
  final String phoneNumber;

  const EditStorePage({Key key, this.storeName, this.phoneNumber})
      : super(key: key);

  @override
  _EditStorePageState createState() => _EditStorePageState();
}

class _EditStorePageState extends State<EditStorePage> {
  File image;
  File originalImage;
  final picker = ImagePicker();
  List<String> storeData = [];
  List<ClassObj> objList = [];
  final TextEditingController storeNameController = new TextEditingController();
  final TextEditingController phoneNumberController =
      new TextEditingController();
  final fireStore = Firestore.instance;

  Future<List<ClassObj>> menuData;

  Future<File> originalIMG;

  int itemNumber = 0;
  int classNumber = 0;

  Future getImage() async {
    FocusScope.of(context).unfocus();
    print(storeNameController.text);
    print(phoneNumberController.text);
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      image = File(pickedFile.path);
    });
  }

  void uploadIMG(String storeName) async {
    if (image != null) {
      await FirebaseStorage.instance
          .ref()
          .child(storeName)
          .putFile(image)
          .onComplete;
    }
  }

  Future<File> getOriginalIMG() async {
    String url = await FirebaseStorage.instance
        .ref()
        .child(widget.storeName)
        .getDownloadURL();
    var rng = new Random();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = new File('$tempPath' + (rng.nextInt(100)).toString() + '.jpg');
    http.Response response = await http.get(url);
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  bool detectAllBlank() {
    bool result = false;
    for (var item in objList) {
      if (hasBlank(item.classController.text)) {
        result = true;
      }
      for (var item in item.itemPriceControllerList) {
        if (hasBlank(item.text)) {
          result = true;
        }
      }
      for (var item in item.itemNameControllerList) {
        if (hasBlank(item.text)) {
          result = true;
        }
      }
    }
    return result;
  }

  bool detectSameClass() {
    bool result = false;
    if (!detectAllBlank()) {
      List<String> classList = [];
      for (var item in objList) {
        List<String> itemList = [];
        classList.add(item.classController.text);
        for (var itemName in item.itemNameControllerList) {
          itemList.add(itemName.text);
        }
        for (var itemA in itemList) {
          int i = 0;
          for (var itemB in itemList) {
            if (itemA == itemB) i++;
          }
          if (i >= 2) {
            result = true;
            break;
          }
        }
      }
      for (var itemA in classList) {
        int i = 0;
        for (var itemB in classList) {
          if (itemA == itemB) i++;
        }
        if (i >= 2) {
          result = true;
          break;
        }
      }
    }
    return result;
  }

  void replaceAllData() async {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    pr.style(
        message: 'Uploading...',
        messageTextStyle: TextStyle(fontFamily: 'LilitaOne', fontSize: 20));

    if (detectAllBlank()) {
      BotToast.showCustomText(
        toastBuilder: (_) => Align(
          alignment: Alignment(0, 0.8),
          child: Card(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '不能有空白或空格！',
                style: TextStyle(
                  fontFamily: 'Yuanti',
                  fontSize: 24,
                  color: Color.fromRGBO(18, 18, 18, 1),
                ),
              ),
            ),
          ),
        ),
        duration: Duration(seconds: 3),
        onlyOne: true,
        clickClose: true,
        ignoreContentClick: true,
      );
    } else {
      if (detectSameClass()) {
        BotToast.showCustomText(
          toastBuilder: (_) => Align(
            alignment: Alignment(0, 0.8),
            child: Card(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '名稱不能相同！',
                  style: TextStyle(
                    fontFamily: 'Yuanti',
                    fontSize: 24,
                    color: Color.fromRGBO(18, 18, 18, 1),
                  ),
                ),
              ),
            ),
          ),
          duration: Duration(seconds: 3),
          onlyOne: true,
          clickClose: true,
          ignoreContentClick: true,
        );
      } else {
        await pr.show();
        //先刪除
        await fireStore
            .collection(widget.storeName)
            .getDocuments()
            .then((snapshot) {
          for (DocumentSnapshot doc in snapshot.documents) {
            doc.reference.delete();
          }
        });
        await fireStore
            .collection('StoreList')
            .document('Stores')
            .updateData({widget.storeName: FieldValue.delete()});

        if (widget.storeName != storeData[0] && image == null) {
          //若只改名不改照片,下載原照片並重新上傳成新照片(改名)
          await FirebaseStorage.instance
              .ref()
              .child(widget.storeName)
              .delete()
              .whenComplete(() {
            FirebaseStorage.instance
                .ref()
                .child(storeData[0])
                .putFile(originalImage);
          });
        }

        //再重建
        await fireStore //storeList
            .collection('StoreList')
            .document('Stores')
            .setData({storeData[0]: storeData[1]}, merge: true);
        for (var doc in objList) {
          for (int i = 0; i < doc.itemList.length; i++) {
            await fireStore
                .collection(storeData[0])
                .document(doc.classController.text)
                .setData({
              doc.itemNameControllerList[i].text:
                  int.parse(doc.itemPriceControllerList[i].text)
            }, merge: true);
          }
        }
        uploadIMG(storeData[0]);
        await pr.hide().whenComplete(() {
          BotToast.showCustomText(
            toastBuilder: (_) => Align(
              alignment: Alignment(0, 0.8),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '上傳成功！',
                    style: TextStyle(
                      fontFamily: 'Yuanti',
                      fontSize: 24,
                      color: Color.fromRGBO(18, 18, 18, 1),
                    ),
                  ),
                ),
              ),
            ),
            duration: Duration(seconds: 3),
            onlyOne: true,
            clickClose: true,
            ignoreContentClick: true,
          );
        });
        Navigator.pop(context);
      }
    }
  }

  List<Widget> buildShowList() {
    List<Widget> showList = [];
    for (int i = 0; i < objList.length; i++) {
      showList.add(objList[i].container);
      for (var item in objList[i].itemList) {
        showList.add(item.container);
      }
    }
    return showList;
  }

  void addClassDynamic() {
    ClassObj obj = new ClassObj();
    obj.num = classNumber;
    classNumber++;
    obj.container = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: Colors.brown,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: GestureDetector(
                    onTap: () {
                      objList.removeWhere((item) => item.num == obj.num);
                      setState(() {});
                    },
                    child: Icon(
                      Icons.cancel,
                      color: Colors.grey,
                    ),
                  ),
                  width: MediaQuery.of(context).size.width / 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 17,
                ),
                Text(
                  '類別：',
                  style: TextStyle(
                      fontFamily: 'Yuanti', fontSize: 20, color: Colors.white),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 3,
                  child: TextField(
                    decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white))),
                    style: TextStyle(color: Color.fromRGBO(27, 180, 82, 1)),
                    controller: obj.classController,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 10,
                ),
                GestureDetector(
                  onTap: () {
                    TextEditingController name = new TextEditingController();
                    TextEditingController price = new TextEditingController();
                    ItemObj itemObj = new ItemObj();
                    setState(() {
                      itemObj.container = Container(
                        width: MediaQuery.of(context).size.width / 3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              child: GestureDetector(
                                onTap: () {
                                  print('bbb');
                                  obj.itemList.removeWhere(
                                      (item) => item.num == itemObj.num);
                                  setState(() {});
                                },
                                child: Icon(
                                  Icons.cancel,
                                  color: Colors.grey,
                                ),
                              ),
                              width: MediaQuery.of(context).size.width / 10,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 23,
                            ),
                            Text(
                              '品項：',
                              style: TextStyle(
                                  fontFamily: 'Yuanti',
                                  fontSize: 20,
                                  color: Colors.white),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width / 3,
                              child: TextField(
                                decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    border: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white))),
                                style: TextStyle(
                                    color: Color.fromRGBO(27, 180, 82, 1)),
                                controller: name,
                              ),
                            ),
                            Text(
                              '價錢：',
                              style: TextStyle(
                                  fontFamily: 'Yuanti',
                                  fontSize: 20,
                                  color: Colors.white),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width / 10,
                              child: TextField(
                                onChanged: (input) {
                                  if (!isNumeric(input)) {
                                    print(input);
                                    price.clear();
                                    BotToast.showCustomText(
                                      toastBuilder: (_) => Align(
                                        alignment: Alignment(0, 0.8),
                                        child: Card(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: Text(
                                              '只能輸入數字..',
                                              style: TextStyle(
                                                fontFamily: 'Yuanti',
                                                fontSize: 24,
                                                color: Color.fromRGBO(
                                                    18, 18, 18, 1),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      duration: Duration(seconds: 3),
                                      onlyOne: true,
                                      clickClose: true,
                                      ignoreContentClick: true,
                                    );
                                  }
                                },
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    border: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white))),
                                style: TextStyle(
                                    color: Color.fromRGBO(27, 180, 82, 1)),
                                controller: price,
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 17,
                            ),
                          ],
                        ),
                      );
                      itemObj.num = itemNumber;
                      itemNumber++;
                      obj.itemList.add(itemObj);
                    });
                    obj.itemNameControllerList.add(name);
                    obj.itemPriceControllerList.add(price);
                  },
                  child: Icon(
                    Icons.add_circle,
                    color: Colors.cyanAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    objList.add(obj);
    setState(() {});
  }

  Future<List<ClassObj>> getMenuData() async {
    List<ClassObj> objList = [];

    final menu = await fireStore.collection(widget.storeName).getDocuments();
    //menu is one of documents (漢堡 飲料etc)

    for (var doc in menu.documents) {
      //menu.data return a Map which include all of items(key : value)
      ClassObj obj = new ClassObj();
      obj.num = classNumber;
      classNumber++;
      obj.container = Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          color: Colors.brown,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: GestureDetector(
                      onTap: () {
                        objList.removeWhere((item) => item.num == obj.num);
                        setState(() {});
                      },
                      child: Icon(
                        Icons.cancel,
                        color: Colors.grey,
                      ),
                    ),
                    width: MediaQuery.of(context).size.width / 10,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 17,
                  ),
                  Text(
                    '類別：',
                    style: TextStyle(
                        fontFamily: 'Yuanti',
                        fontSize: 20,
                        color: Colors.white),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 3,
                    child: TextField(
                      decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white))),
                      style: TextStyle(color: Color.fromRGBO(27, 180, 82, 1)),
                      controller: obj.classController,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      TextEditingController name = new TextEditingController();
                      TextEditingController price = new TextEditingController();
                      ItemObj itemObj = new ItemObj();
                      setState(() {
                        itemObj.container = Container(
                          width: MediaQuery.of(context).size.width / 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: GestureDetector(
                                  onTap: () {
                                    print('aaa');
                                    obj.itemList.removeWhere(
                                        (item) => item.num == itemObj.num);
                                    setState(() {});
                                  },
                                  child: Icon(
                                    Icons.cancel,
                                    color: Colors.grey,
                                  ),
                                ),
                                width: MediaQuery.of(context).size.width / 10,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 23,
                              ),
                              Text(
                                '品項：',
                                style: TextStyle(
                                    fontFamily: 'Yuanti',
                                    fontSize: 20,
                                    color: Colors.white),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 3,
                                child: TextField(
                                  decoration: InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      border: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white))),
                                  style: TextStyle(
                                      color: Color.fromRGBO(27, 180, 82, 1)),
                                  controller: name,
                                ),
                              ),
                              Text(
                                '價錢：',
                                style: TextStyle(
                                    fontFamily: 'Yuanti',
                                    fontSize: 20,
                                    color: Colors.white),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 10,
                                child: TextField(
                                  onChanged: (input) {
                                    if (!isNumeric(input)) {
                                      print(input);
                                      price.clear();
                                      BotToast.showCustomText(
                                        toastBuilder: (_) => Align(
                                          alignment: Alignment(0, 0.8),
                                          child: Card(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8),
                                              child: Text(
                                                '只能輸入數字..',
                                                style: TextStyle(
                                                  fontFamily: 'Yuanti',
                                                  fontSize: 24,
                                                  color: Color.fromRGBO(
                                                      18, 18, 18, 1),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        duration: Duration(seconds: 3),
                                        onlyOne: true,
                                        clickClose: true,
                                        ignoreContentClick: true,
                                      );
                                    }
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      border: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white))),
                                  style: TextStyle(
                                      color: Color.fromRGBO(27, 180, 82, 1)),
                                  controller: price,
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 17,
                              ),
                            ],
                          ),
                        );
                        itemObj.num = itemNumber;
                        itemNumber++;
                        obj.itemList.add(itemObj);
                      });
                      obj.itemNameControllerList.add(name);
                      obj.itemPriceControllerList.add(price);
                    },
                    child: Icon(
                      Icons.add_circle,
                      color: Colors.cyanAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      obj.classController.text = doc.documentID;
      doc.data.forEach((k, v) {
        TextEditingController name = new TextEditingController();
        TextEditingController price = new TextEditingController();
        ItemObj itemObj = new ItemObj();
        name.text = k;
        price.text = v.toString();
        itemObj.container = Container(
          width: MediaQuery.of(context).size.width / 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                child: GestureDetector(
                  onTap: () {
                    print('ccc');
                    obj.itemList.removeWhere((item) => item.num == itemObj.num);
                    setState(() {});
                  },
                  child: Icon(
                    Icons.cancel,
                    color: Colors.grey,
                  ),
                ),
                width: MediaQuery.of(context).size.width / 10,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 23,
              ),
              Text(
                '品項：',
                style: TextStyle(
                    fontFamily: 'Yuanti', fontSize: 20, color: Colors.white),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 3,
                child: TextField(
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white))),
                  style: TextStyle(color: Color.fromRGBO(27, 180, 82, 1)),
                  controller: name,
                ),
              ),
              Text(
                '價錢：',
                style: TextStyle(
                    fontFamily: 'Yuanti', fontSize: 20, color: Colors.white),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 10,
                child: TextField(
                  onChanged: (input) {
                    if (!isNumeric(input)) {
                      print(input);
                      price.clear();
                      BotToast.showCustomText(
                        toastBuilder: (_) => Align(
                          alignment: Alignment(0, 0.8),
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '只能輸入數字..',
                                style: TextStyle(
                                  fontFamily: 'Yuanti',
                                  fontSize: 24,
                                  color: Color.fromRGBO(18, 18, 18, 1),
                                ),
                              ),
                            ),
                          ),
                        ),
                        duration: Duration(seconds: 3),
                        onlyOne: true,
                        clickClose: true,
                        ignoreContentClick: true,
                      );
                    }
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white))),
                  style: TextStyle(color: Color.fromRGBO(27, 180, 82, 1)),
                  controller: price,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 17,
              ),
            ],
          ),
        );
        itemObj.num = itemNumber;
        itemNumber++;
        obj.itemList.add(itemObj);
        obj.itemNameControllerList.add(name);
        obj.itemPriceControllerList.add(price);
      });
      objList.add(obj);
    }

    return objList;
  }

  @override
  void initState() {
    menuData = getMenuData();
    originalIMG = getOriginalIMG();
    storeData.add(widget.storeName);
    storeData.add(widget.phoneNumber);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          size: 50,
        ),
        foregroundColor: Color.fromRGBO(27, 180, 82, 1),
        backgroundColor: Colors.brown,
        onPressed: addClassDynamic,
      ),
      backgroundColor: Color.fromRGBO(18, 18, 18, 1),
      body: FutureBuilder<List<ClassObj>>(
        future: menuData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            objList = snapshot.data;
            storeNameController.text = storeData[0];
            phoneNumberController.text = storeData[1];
            buildShowList();

            return Container(
              child: SafeArea(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: Navigator.of(context).pop,
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 35,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          '店名:',
                          style: TextStyle(
                              fontFamily: 'Yuanti',
                              fontSize: 25,
                              color: Colors.white),
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width / 2,
                            child: TextField(
                              onChanged: (input) {
                                storeData[0] = input;
                              },
                              decoration: InputDecoration(
                                hintText: '(點此輸入)',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                              ),
                              controller: storeNameController,
                            )),
                      ],
                    ),
                    FutureBuilder<File>(
                      future: getOriginalIMG(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          originalImage = snapshot.data;
                        }
                        return Row(
                          children: <Widget>[
                            Text(
                              '照片: ',
                              style: TextStyle(
                                  fontFamily: 'Yuanti',
                                  fontSize: 25,
                                  color: Colors.white),
                            ),
                            image != null
                                ? Text(
                                    'OK !',
                                    style: TextStyle(
                                        fontFamily: 'LilitaOne',
                                        fontSize: 25,
                                        color: Color.fromRGBO(27, 180, 82, 1)),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      getImage();
                                    },
                                    child: Container(
                                      child: Text(
                                        '(點此上傳,不更改則不傳)',
                                        style: TextStyle(
                                            fontFamily: 'Yuanti',
                                            fontSize: 25,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                          ],
                        );
                      },
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          '電話:',
                          style: TextStyle(
                              fontFamily: 'Yuanti',
                              fontSize: 25,
                              color: Colors.white),
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width / 2,
                            child: TextField(
                              onChanged: (input) {
                                storeData[1] = input;
                              },
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '(點此輸入)',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                              ),
                              controller: phoneNumberController,
                            )),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 77,
                    ),
                    Expanded(
                        //parent
                        child: ListView.builder(
                      itemCount: buildShowList().length,
                      itemBuilder: (_, index) => buildShowList()[index],
                    )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: BouncingWidget(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              replaceAllData();
                            },
                            child: Container(
                              child: Center(
                                  child: Text(
                                'Upload',
                                style: TextStyle(
                                    fontFamily: 'LilitaOne', fontSize: 29),
                              )),
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(29, 185, 84, 1),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6))),
                              height: MediaQuery.of(context).size.height / 20,
                              width: MediaQuery.of(context).size.width / 2,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          } else {
            return Center(
              child: SpinKitThreeBounce(
                color: Colors.white,
              ),
            );
          }
        },
      ),
    );
  }
}

class ClassObj {
  int num = 0;
  List<ItemObj> itemList = [];
  List<TextEditingController> itemNameControllerList = [];
  List<TextEditingController> itemPriceControllerList = [];
  TextEditingController classController = new TextEditingController();
  Widget container;
}

class ItemObj {
  Widget container;
  int num;
}
