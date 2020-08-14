import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:keyboard_actions/keyboard_actions_config.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shoufeng_order/tools/menu_builder.dart';

class NewStorePage extends StatefulWidget {
  @override
  _NewStorePageState createState() => _NewStorePageState();
}

class _NewStorePageState extends State<NewStorePage> {
  int itemNumber = 0;
  int classNumber = 0;
  File image;
  final picker = ImagePicker();
  bool isOk = false;
  List<String> storeData = [];
  List<ClassObj> objList = [];
  final TextEditingController storeNameController = new TextEditingController();
  final TextEditingController phoneNumberController =
      new TextEditingController();
  final fireStore = Firestore.instance;

  final FocusNode _nodeText1 = FocusNode();

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: Color.fromRGBO(88, 88, 88, 1),
      nextFocus: false,
      actions: [
        KeyboardAction(
          focusNode: _nodeText1,
        ),
      ],
    );
  }

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
        classList.add(item.classController.text);
      }
      for (var itemA in classList) {
        int i = 0;
        for (var itemB in classList) {
          if (itemA == itemB) i++;
        }
        if (i == 2) {
          result = true;
          break;
        }
      }
    }
    return result;
  }

  void uploadAllData() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isOk
          ? FloatingActionButton(
              child: Icon(
                Icons.add,
                size: 50,
              ),
              foregroundColor: Color.fromRGBO(27, 180, 82, 1),
              backgroundColor: Colors.brown,
              onPressed: addClassDynamic,
            )
          : null,
      backgroundColor: Color.fromRGBO(18, 18, 18, 1),
      body: Container(
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
                      child: isOk
                          ? Text(
                              storeData[0],
                              style: TextStyle(
                                  fontFamily: 'Yuanti',
                                  fontSize: 25,
                                  color: Color.fromRGBO(27, 180, 82, 1)),
                            )
                          : TextField(
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
              Row(
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
                              '(點此上傳)',
                              style: TextStyle(
                                  fontFamily: 'Yuanti',
                                  fontSize: 25,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                ],
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
                      child: isOk
                          ? Text(
                              storeData[1],
                              style: TextStyle(
                                  fontFamily: 'Yuanti',
                                  fontSize: 25,
                                  color: Color.fromRGBO(27, 180, 82, 1)),
                            )
                          : TextField(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Visibility(
                    visible: !isOk,
                    child: GestureDetector(
                      onTap: () {
                        if (storeNameController.text.isNotEmpty &&
                            isNumeric(phoneNumberController.text) &&
                            image != null) {
                          storeData.add(storeNameController.text);
                          storeData.add(phoneNumberController.text);
                          isOk = true;
                        } else if (image == null) {
                          BotToast.showCustomText(
                            toastBuilder: (_) => Align(
                              alignment: Alignment(0, 0.8),
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    '照片呢..',
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
                          BotToast.showCustomText(
                            toastBuilder: (_) => Align(
                              alignment: Alignment(0, 0.8),
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    '輸入格式錯誤..',
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

                        setState(() {});
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                          color: Color.fromRGBO(29, 185, 84, 1),
                        ),
                        child: Text(
                          'OK',
                          style: TextStyle(
                              color: Color.fromRGBO(18, 18, 18, 1),
                              fontSize: 35,
                              fontFamily: 'LilitaOne'),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
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
              Visibility(
                visible: isOk,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: BouncingWidget(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          uploadAllData();
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
                ),
              )
            ],
          ),
        ),
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
