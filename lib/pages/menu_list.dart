import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shoufeng_order/tools/accounting_builder.dart';
import 'package:shoufeng_order/tools/favorite_builder.dart';
import 'package:shoufeng_order/tools/menu_builder.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:easy_dialog/easy_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class MenuList extends StatefulWidget {
  @override
  _MenuListState createState() => _MenuListState();
}

class _MenuListState extends State<MenuList> {
  final TextEditingController noteController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  Future<List<MenuValue>> menuObjList;
  Future<List<String>> storeList;
  Future<List<String>> imanoMise;
  final fireStore = Firestore.instance;

  void shopCart() {
    slideDialog.showSlideDialog(
      backgroundColor: Color.fromRGBO(18, 18, 18, 1),
      transitionDuration: Duration(milliseconds: 700),
      context: context,
      child: FutureBuilder<List<MenuValue>>(
        future: menuObjList,
        builder: (context, snapshot) {
          List<MenuValue> temp = [];
          List<Widget> widtemp = [];

          if (snapshot.hasData) {
            for (var item in snapshot.data) {
              if (item.count > 0) {
                temp.add(item);
              }
            }
            for (var item in temp) {
              widtemp.add(
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[
                      Text(
                        item.count.toString(), //count
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width / 12.25,
                            fontFamily: 'LilitaOne'),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 13.06,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.elliptical(10, 10),
                            ),
                            color: Color.fromRGBO(29, 185, 84, 1),
                          ),
                          child: Column(
                            children: <Widget>[
                              Text(
                                '${item.keys}    ${isNumeric(item.notePrice) ? item.notePrice : item.value}',
                                style: TextStyle(
                                    color: Color.fromRGBO(18, 18, 18, 1),
                                    fontSize:
                                        MediaQuery.of(context).size.width /
                                            13.06,
                                    fontFamily: 'Yuanti'),
                              ),
                              Visibility(
                                visible: item.note == '' ? false : true,
                                child: Text(
                                  item.note,
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              19.6,
                                      color: Color.fromRGBO(18, 18, 18, 1),
                                      fontFamily: 'Yuanti'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }
          return Expanded(
            child: Container(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.shopping_cart,
                          color: Colors.red,
                          size: MediaQuery.of(context).size.width / 13,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 78.4,
                        ),
                        Text(
                          '購物車',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Yuanti',
                              fontSize:
                                  MediaQuery.of(context).size.width / 17.81),
                        ),
                        Expanded(child: SizedBox()),
                        ButtonTheme(
                          minWidth: MediaQuery.of(context).size.width / 6.53,
                          height: MediaQuery.of(context).size.height / 26.56,
                          buttonColor: Color.fromRGBO(29, 185, 84, 1),
                          child: RaisedButton(
                            onPressed: () {
                              EasyDialog(
                                  cardColor: Color.fromRGBO(18, 18, 18, 1),
                                  cornerRadius: 15.0,
                                  fogOpacity: 0.1,
                                  width:
                                      MediaQuery.of(context).size.width / 1.568,
                                  height:
                                      MediaQuery.of(context).size.height / 4.25,
                                  contentPadding: EdgeInsets.only(
                                    top: MediaQuery.of(context).size.height /
                                        70.83,
                                  ), // Needed for the button design
                                  contentList: [
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(left: 15.0)),
                                          Text(
                                            "提醒",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Yuanti',
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    23.05),
                                            textScaleFactor: 1.3,
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsets.only(left: 15.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        child: Text(
                                          '確定清空購物車？',
                                          style: TextStyle(
                                              fontFamily: 'Yuanti',
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  17.81,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.greenAccent,
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(10.0),
                                                ),
                                              ),
                                              child: FlatButton(
                                                child: Text(
                                                  "Cancel",
                                                  textScaleFactor: 1.6,
                                                  style: TextStyle(
                                                      fontFamily: 'LilitaOne',
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              24.5),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 1,
                                          ),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.greenAccent,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    bottomRight:
                                                        Radius.circular(10.0),
                                                  )),
                                              child: FlatButton(
                                                child: Text(
                                                  "OK",
                                                  textScaleFactor: 1.6,
                                                  style: TextStyle(
                                                      fontFamily: 'LilitaOne',
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              23.05),
                                                ),
                                                onPressed: () {
                                                  setState(() {});
                                                  menuObjList =
                                                      getMenu(fireStore);
                                                  BotToast.showCustomText(
                                                    toastBuilder: (_) => Align(
                                                      alignment:
                                                          Alignment(0, 0.8),
                                                      child: Card(
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      8),
                                                          child: Text(
                                                            '已清空購物車',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Yuanti',
                                                              fontSize: 24,
                                                              color: Color
                                                                  .fromRGBO(
                                                                      18,
                                                                      18,
                                                                      18,
                                                                      1),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    duration:
                                                        Duration(seconds: 3),
                                                    onlyOne: true,
                                                    clickClose: true,
                                                    ignoreContentClick: true,
                                                  );
                                                  Navigator.popUntil(
                                                    context,
                                                    ModalRoute.withName(
                                                        '/menulist'),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]).show(context);
                            },
                            shape: StadiumBorder(),
                            child: Icon(Icons.delete_forever),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 15,
                        ),
                        ButtonTheme(
                          minWidth: MediaQuery.of(context).size.width / 6.53,
                          height: MediaQuery.of(context).size.height / 26.56,
                          buttonColor: Color.fromRGBO(29, 185, 84, 1),
                          child: RaisedButton(
                            onPressed: () {
                              EasyDialog(
                                  //
                                  cardColor: Color.fromRGBO(18, 18, 18, 1),
                                  cornerRadius: 15.0,
                                  fogOpacity: 0.1,
                                  width:
                                      MediaQuery.of(context).size.width / 1.568,
                                  height:
                                      MediaQuery.of(context).size.height / 4.25,
                                  contentPadding: EdgeInsets.only(
                                    top: MediaQuery.of(context).size.height /
                                        70.83,
                                  ), // Needed for the button design
                                  contentList: [
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(left: 15.0)),
                                          Text(
                                            "提醒",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Yuanti',
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    23.05),
                                            textScaleFactor: 1.3,
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsets.only(left: 15.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        child: Text(
                                          '確定提交？',
                                          style: TextStyle(
                                              fontFamily: 'Yuanti',
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  17.81,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.greenAccent,
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(10.0),
                                                ),
                                              ),
                                              child: FlatButton(
                                                child: Text(
                                                  "Cancel",
                                                  textScaleFactor: 1.6,
                                                  style: TextStyle(
                                                      fontFamily: 'LilitaOne',
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              24.5),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 1,
                                          ),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.greenAccent,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    bottomRight:
                                                        Radius.circular(10.0),
                                                  )),
                                              child: FlatButton(
                                                child: Text(
                                                  "OK",
                                                  textScaleFactor: 1.6,
                                                  style: TextStyle(
                                                      fontFamily: 'LilitaOne',
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              23.05),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    clearOrderCache(fireStore);
                                                    uploadFinalOrder(
                                                        fireStore, temp);
                                                    uploadDefaultOrderState(
                                                        fireStore, temp);
                                                    menuObjList =
                                                        getMenu(fireStore);
                                                    Navigator.popUntil(
                                                      context,
                                                      ModalRoute.withName(
                                                          '/menulist'),
                                                    );
                                                    Navigator.pushNamed(
                                                        context, '/accounting');
                                                  });
                                                  BotToast.showCustomText(
                                                    toastBuilder: (_) => Align(
                                                      alignment:
                                                          Alignment(0, 0.8),
                                                      child: Card(
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      8),
                                                          child: Text(
                                                            '提交成功！',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Yuanti',
                                                              fontSize: 24,
                                                              color: Color
                                                                  .fromRGBO(
                                                                      18,
                                                                      18,
                                                                      18,
                                                                      1),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    duration:
                                                        Duration(seconds: 3),
                                                    onlyOne: true,
                                                    clickClose: true,
                                                    ignoreContentClick: true,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]).show(context);
                            },
                            shape: StadiumBorder(),
                            child: Icon(Icons.arrow_forward),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 30,
                    ),
                    Expanded(
                      child: temp.length > 0
                          ? Container(
                              child: ListView(
                                shrinkWrap: true,
                                children: widtemp,
                              ),
                            )
                          : Container(
                              child: Text(
                                '這裡什麼都沒有..',
                                style: TextStyle(
                                    fontFamily: 'Yuanti',
                                    fontSize:
                                        MediaQuery.of(context).size.width /
                                            17.81,
                                    color: Colors.white),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void favDialog() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String storeName;
    slideDialog.showSlideDialog(
      backgroundColor: Color.fromRGBO(18, 18, 18, 1),
      transitionDuration: Duration(milliseconds: 700),
      context: context,
      child: Expanded(
        child: Container(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: MediaQuery.of(context).size.width / 13,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 78.4,
                    ),
                    Text(
                      '喜愛列表',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Yuanti',
                          fontSize: MediaQuery.of(context).size.width / 17.81),
                    ),
                    Expanded(child: SizedBox()),
                    ButtonTheme(
                      minWidth: MediaQuery.of(context).size.width / 6.53,
                      height: MediaQuery.of(context).size.height / 26.56,
                      buttonColor: Color.fromRGBO(29, 185, 84, 1),
                      child: RaisedButton(
                        onPressed: () {
                          EasyDialog(
                              cardColor: Color.fromRGBO(18, 18, 18, 1),
                              cornerRadius: 15.0,
                              fogOpacity: 0.1,
                              width: MediaQuery.of(context).size.width / 1.568,
                              height: MediaQuery.of(context).size.height / 4.25,
                              contentPadding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height / 70.83,
                              ), // Needed for the button design
                              contentList: [
                                Expanded(
                                  flex: 1,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Padding(
                                          padding: EdgeInsets.only(left: 15.0)),
                                      Text(
                                        "提醒",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Yuanti',
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                23.05),
                                        textScaleFactor: 1.3,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 15.0),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      '確定清空喜愛列表？',
                                      style: TextStyle(
                                          fontFamily: 'Yuanti',
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              17.81,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.greenAccent,
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(10.0),
                                            ),
                                          ),
                                          child: FlatButton(
                                            child: Text(
                                              "Cancel",
                                              textScaleFactor: 1.6,
                                              style: TextStyle(
                                                  fontFamily: 'LilitaOne',
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          24.5),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 1,
                                      ),
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.greenAccent,
                                              borderRadius: BorderRadius.only(
                                                bottomRight:
                                                    Radius.circular(10.0),
                                              )),
                                          child: FlatButton(
                                            child: Text(
                                              "OK",
                                              textScaleFactor: 1.6,
                                              style: TextStyle(
                                                  fontFamily: 'LilitaOne',
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          23.05),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                print(storeName);
                                                pref.remove(storeName);
                                                Navigator.popUntil(
                                                  context,
                                                  ModalRoute.withName(
                                                      '/menulist'),
                                                );
                                              });
                                              BotToast.showCustomText(
                                                toastBuilder: (_) => Align(
                                                  alignment: Alignment(0, 0.8),
                                                  child: Card(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 8),
                                                      child: Text(
                                                        '已清空喜愛列表',
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
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]).show(context);
                        },
                        shape: StadiumBorder(),
                        child: Icon(Icons.delete_forever),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 15,
                    ),
                    ButtonTheme(
                      minWidth: MediaQuery.of(context).size.width / 6.53,
                      height: MediaQuery.of(context).size.height / 26.56,
                      buttonColor: Color.fromRGBO(29, 185, 84, 1),
                      child: FutureBuilder<List<String>>(
                        future: imanoMise,
                        builder: (context, snapshot) {
                          List<String> temp;
                          List<MenuValue> objTemp;
                          if (snapshot.hasData) {
                            storeName = snapshot.data[0];
                            temp = pref.getStringList(storeName);
                            objTemp = makeFavToObjList(temp);
                          }
                          return RaisedButton(
                            onPressed: () {
                              if (objTemp.length != 0) {
                                EasyDialog(
                                    cardColor: Color.fromRGBO(18, 18, 18, 1),
                                    cornerRadius: 15.0,
                                    fogOpacity: 0.1,
                                    width: MediaQuery.of(context).size.width /
                                        1.568,
                                    height: MediaQuery.of(context).size.height /
                                        4.25,
                                    contentPadding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height /
                                          70.83,
                                    ), // Needed for the button design
                                    contentList: [
                                      Expanded(
                                        flex: 1,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Padding(
                                                padding: EdgeInsets.only(
                                                    left: 15.0)),
                                            Text(
                                              "提醒",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Yuanti',
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          23.05),
                                              textScaleFactor: 1.3,
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(left: 15.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: Text(
                                            '確定提交？',
                                            style: TextStyle(
                                                fontFamily: 'Yuanti',
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    17.81,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.greenAccent,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(10.0),
                                                  ),
                                                ),
                                                child: FlatButton(
                                                  child: Text(
                                                    "Cancel",
                                                    textScaleFactor: 1.6,
                                                    style: TextStyle(
                                                        fontFamily: 'LilitaOne',
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            24.5),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 1,
                                            ),
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.greenAccent,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      bottomRight:
                                                          Radius.circular(10.0),
                                                    )),
                                                child: FlatButton(
                                                  child: Text(
                                                    "OK",
                                                    textScaleFactor: 1.6,
                                                    style: TextStyle(
                                                        fontFamily: 'LilitaOne',
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            23.05),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      clearOrderCache(
                                                          fireStore);
                                                      uploadFinalOrder(
                                                          fireStore, objTemp);
                                                      uploadDefaultOrderState(
                                                          fireStore, objTemp);
                                                      menuObjList =
                                                          getMenu(fireStore);
                                                      Navigator.popUntil(
                                                        context,
                                                        ModalRoute.withName(
                                                            '/menulist'),
                                                      );
                                                      Navigator.pushNamed(
                                                          context,
                                                          '/accounting');
                                                    });
                                                    BotToast.showCustomText(
                                                      toastBuilder: (_) =>
                                                          Align(
                                                        alignment:
                                                            Alignment(0, 0.8),
                                                        child: Card(
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        8),
                                                            child: Text(
                                                              '提交成功！',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Yuanti',
                                                                fontSize: 24,
                                                                color: Color
                                                                    .fromRGBO(
                                                                        18,
                                                                        18,
                                                                        18,
                                                                        1),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      duration:
                                                          Duration(seconds: 3),
                                                      onlyOne: true,
                                                      clickClose: true,
                                                      ignoreContentClick: true,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]).show(context);
                              } else {
                                BotToast.showCustomText(
                                  toastBuilder: (_) => Align(
                                    alignment: Alignment(0, 0.8),
                                    child: Card(
                                      child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Text(
                                            '喜愛列表好像是空的哦..',
                                            style: TextStyle(
                                              fontFamily: 'Yuanti',
                                              fontSize: 24,
                                              color:
                                                  Color.fromRGBO(18, 18, 18, 1),
                                            ),
                                          )),
                                    ),
                                  ),
                                  duration: Duration(seconds: 3),
                                  onlyOne: true,
                                  clickClose: true,
                                  ignoreContentClick: true,
                                );
                              }
                            },
                            shape: StadiumBorder(),
                            child: Icon(Icons.arrow_forward),
                          );
                        },
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 30,
                ),
                FutureBuilder<List<String>>(
                  future: imanoMise,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      storeName = snapshot.data[0];
                      List<String> temp = pref.getStringList(storeName);
                      List<Widget> widtemp = new List<Widget>();
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (temp == null) {
                          return Container(
                            child: Text(
                              '這裡什麼都沒有..',
                              style: TextStyle(
                                  fontFamily: 'Yuanti',
                                  fontSize:
                                      MediaQuery.of(context).size.width / 17.81,
                                  color: Colors.white),
                            ),
                          );
                        }
                        for (int i = 0; i < (temp.length); i++) {
                          if (i % 4 == 0) {
                            widtemp.add(
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      temp[i + 3], //count
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              12.25,
                                          fontFamily: 'LilitaOne'),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          13.06,
                                    ),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.elliptical(10, 10),
                                          ),
                                          color: Color.fromRGBO(29, 185, 84, 1),
                                        ),
                                        child: Column(
                                          children: <Widget>[
                                            Text(
                                              '${temp[i]}    ${temp[i + 1]}',
                                              style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      18, 18, 18, 1),
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          13.06,
                                                  fontFamily: 'Yuanti'),
                                            ),
                                            Visibility(
                                              visible: temp[i + 2] == ''
                                                  ? false
                                                  : true,
                                              child: Text(
                                                temp[i + 2],
                                                style: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            19.6,
                                                    color: Color.fromRGBO(
                                                        18, 18, 18, 1),
                                                    fontFamily: 'Yuanti'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        }
                        return Expanded(
                          child: Container(
                            child: ListView(
                              shrinkWrap: true,
                              children: widtemp,
                            ),
                          ),
                        );
                      }
                    }
                    return Container(
                      child: Text('waiting'),
                      height: MediaQuery.of(context).size.height / 8.5,
                      width: MediaQuery.of(context).size.width / 3.92,
                      color: Color.fromRGBO(18, 18, 18, 1),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showDialog() {
    slideDialog.showSlideDialog(
      context: context,
      backgroundColor: Color.fromRGBO(18, 18, 18, 1),
      transitionDuration: Duration(milliseconds: 700),
      child: Expanded(
        child: Container(
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width / 19.6),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.dashboard,
                      color: Colors.red,
                      size: MediaQuery.of(context).size.width / 13.06,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 78.4,
                    ),
                    Text(
                      '更換店鋪',
                      style: TextStyle(
                          fontFamily: 'Yuanti',
                          fontSize: MediaQuery.of(context).size.width / 17.81,
                          color: Colors.white),
                    ),
                    Expanded(child: SizedBox()),
                    FutureBuilder<List<String>>(
                      future: storeList,
                      builder: (context, snapshot) {
                        int rng;
                        if (snapshot.hasData) {
                          return BouncingWidget(
                            onPressed: () {
                              setState(() {
                                rng = Random().nextInt(snapshot.data.length);
                                uploadImanomise(fireStore, snapshot.data[rng]);
                                imanoMise = getImanomise(fireStore);
                                menuObjList = getMenu(fireStore);
                              });
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width / 80),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '隨機選取',
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width / 30,
                                    fontFamily: 'Yuanti',
                                    color: Colors.white),
                              ),
                            ),
                          );
                        } else {
                          return SpinKitThreeBounce(
                            color: Colors.white,
                          );
                        }
                      },
                    )
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 30,
                ),
                DragTarget<String>(
                  onWillAccept: (data) {
                    return data != null;
                  },
                  onAccept: (data) {
                    setState(() {
                      uploadImanomise(fireStore, data);
                      imanoMise = getImanomise(fireStore);
                      menuObjList = getMenu(fireStore);
                    });
                    print('$data:accept');
                  },
                  builder: (context, a, b) {
                    return Container(
                      height: MediaQuery.of(context).size.height / 9.7571,
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Drag  to  here',
                              style: TextStyle(
                                  color: Color.fromRGBO(18, 18, 18, 1),
                                  fontSize:
                                      MediaQuery.of(context).size.width / 12.25,
                                  fontFamily: 'LilitaOne'),
                            ),
                            FutureBuilder<List<String>>(
                              future: imanoMise,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return Text(
                                      snapshot.data[0],
                                      style: TextStyle(
                                          fontFamily: 'Yuanti',
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              17.81),
                                    );
                                  } else {
                                    return Text(
                                      '上傳中..',
                                      style: TextStyle(
                                          fontFamily: 'Yuanti',
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              17.81),
                                    );
                                  }
                                } else {
                                  return Text(
                                    '找不到資料..',
                                    style: TextStyle(
                                        fontFamily: 'Yuanti',
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                17.81),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(29, 185, 84, 0.75),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 28.33,
                ),
                FutureBuilder<List<String>>(
                  future: storeList,
                  builder: (context, snapshot) {
                    List<Widget> storeList = List<Widget>();
                    if (snapshot.hasData) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        for (var store in snapshot.data) {
                          storeList.add(LongPressDraggable<String>(
                            maxSimultaneousDrags: 1,
                            childWhenDragging: Container(),
                            data: store,
                            feedback: Material(
                              borderRadius:
                                  BorderRadius.all(Radius.elliptical(10, 9)),
                              color: Color.fromRGBO(29, 185, 84, 1),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                        Radius.elliptical(10, 9)),
                                    color: Color.fromRGBO(29, 185, 84, 1)),
                                child: Center(
                                    child: Text(
                                  store,
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              13.06,
                                      fontFamily: 'Yuanti'),
                                )),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width / 39.2),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                        Radius.elliptical(10, 9)),
                                    color: Color.fromRGBO(29, 185, 84, 1)),
                                child: Center(
                                    child: Text(
                                  store,
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              15.07,
                                      fontFamily: 'Yuanti'),
                                )),
                              ),
                            ),
                          ));
                        }
                        return Expanded(
                          child: Container(
                            child: GridView.count(
                              shrinkWrap: true,
                              childAspectRatio: 2,
                              crossAxisCount: 2,
                              children: storeList,
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
                    }
                    return Container();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget setTitle(docID) {
    return Container(
      child: Text(
        '$docID',
        style:
            TextStyle(fontFamily: 'Yuanti', fontSize: 30, color: Colors.white),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    imanoMise = getImanomise(fireStore);
    menuObjList = getMenu(fireStore);
    storeList = getStore(fireStore);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 18, 18, 1),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: EdgeInsets.only(top: 0, bottom: 50),
                sliver: SliverAppBar(
                  backgroundColor: Color.fromRGBO(18, 18, 18, 1),
                  actions: <Widget>[
                    GestureDetector(
                      onTap: () {
                        setState(() {});
                        favDialog();
                      },
                      child: Container(
                        child: Image.asset(
                          'images/heart.png',
                          scale: 7,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 19.6,
                    ),
                    Hero(
                      tag: 'bottle_order',
                      child: GestureDetector(
                        onTap: () {
                          setState(() {});
                          showDialog();
                        },
                        child: Container(
                          child: Image.asset(
                            'images/message_in_a_bottle.png',
                            scale: 7,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 39.2,
                    ),
                  ],
                  pinned: true,
                  expandedHeight: MediaQuery.of(context).size.width / 0.905,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Transform.translate(
                      offset: Offset(0, -18),
                      child: FutureBuilder<List<String>>(
                        future: imanoMise,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return Text(
                                snapshot.data[0],
                                style: TextStyle(
                                  fontFamily: 'Yuanti',
                                  fontSize:
                                      MediaQuery.of(context).size.width / 13.06,
                                ),
                              );
                            } else {
                              return Text(
                                '讀取中..',
                                style: TextStyle(
                                  fontFamily: 'Yuanti',
                                  fontSize:
                                      MediaQuery.of(context).size.width / 19.6,
                                ),
                              );
                            }
                          } else {
                            return Text(
                              '讀取中..',
                              style: TextStyle(
                                fontFamily: 'Yuanti',
                                fontSize:
                                    MediaQuery.of(context).size.width / 19.6,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    background: FutureBuilder<List<String>>(
                      //背景圖片
                      future: imanoMise,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Container(
                              child: Image.network(
                                snapshot.data[1],
                                fit: BoxFit.cover,
                              ),
                            );
                          }
                          return Center(
                            child: SpinKitThreeBounce(
                              color: Colors.white,
                            ),
                          );
                        } else {
                          return Center(
                              child: SpinKitThreeBounce(
                            color: Colors.white,
                          ));
                        }
                      },
                    ),
                    stretchModes: <StretchMode>[
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                      StretchMode.fadeTitle,
                    ],
                  ),
                  bottom: PreferredSize(
                    child: Transform.translate(
                      offset: Offset(0, 15),
                      child: GestureDetector(
                        onTap: () {
                          shopCart();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width / 3,
                          height: MediaQuery.of(context).size.height / 17,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            color: Color.fromRGBO(29, 185, 84, 1),
                          ),
                          child: Center(
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                  fontFamily: 'LilitaOne',
                                  fontSize: MediaQuery.of(context).size.width /
                                      13.06),
                            ),
                          ),
                        ),
                      ),
                    ),
                    preferredSize: Size.fromHeight(
                        MediaQuery.of(context).size.height / 33),
                  ),
                ),
              ),
              FutureBuilder<List<MenuValue>>(
                future: menuObjList,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      List<Widget> menuContain = [];
                      String docID = '';
                      for (var item in snapshot.data) {
                        //建widgets list
                        if (item.docID == docID) {
                          menuContain.add(
                            Padding(
                              padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height /
                                      56.66),
                              child: Row(children: <Widget>[
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 26.1,
                                ),
                                Visibility(
                                  visible: item.isShow,
                                  child: Container(
                                    child: Text(
                                      '${item.count}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              12.25,
                                          fontFamily: 'LilitaOne'),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width /
                                                13.06,
                                        right:
                                            MediaQuery.of(context).size.width /
                                                13.06),
                                    child: BouncingWidget(
                                      scaleFactor: 1.0,
                                      child: Container(
                                        child: Center(
                                          child: Column(
                                            children: <Widget>[
                                              Text(
                                                '${item.keys}  ${isNumeric(item.notePrice) ? item.notePrice : item.value} ',
                                                style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        18, 18, 18, 1),
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            13.06,
                                                    fontFamily: 'Yuanti'),
                                              ),
                                              Visibility(
                                                visible: item.isShow,
                                                child: Text(
                                                  '${item.note}',
                                                  style: TextStyle(
                                                      fontFamily: 'Yuanti',
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              19.6),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                            color:
                                                Color.fromRGBO(29, 185, 84, 1),
                                            borderRadius: BorderRadius.all(
                                                Radius.elliptical(10, 10))),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          item.count++;
                                          if (item.count > 0) {
                                            item.isShow = true;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: item.isShow,
                                  child: IconButton(
                                    color: Color.fromRGBO(29, 185, 84, 1),
                                    icon: Icon(Icons.assignment),
                                    iconSize:
                                        MediaQuery.of(context).size.width /
                                            12.25,
                                    onPressed: () {
                                      EasyDialog(
                                          cardColor:
                                              Color.fromRGBO(18, 18, 18, 1),
                                          cornerRadius: 15.0,
                                          fogOpacity: 0.1,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.264,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              2.8,
                                          contentPadding: EdgeInsets.only(
                                              top: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  32.6), // Needed for the button design
                                          contentList: [
                                            Expanded(
                                              flex: 1,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          left: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              26.133)),
                                                  Text(
                                                    "備註",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontFamily: 'Yuanti',
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            23.05),
                                                    textScaleFactor: 1.3,
                                                  ),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          left: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              26.133)),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                                flex: 2,
                                                child: Padding(
                                                  padding: EdgeInsets.all(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          39.2),
                                                  child: TextFormField(
                                                    controller: noteController,
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                    maxLines: 1,
                                                    decoration: InputDecoration(
                                                      hintStyle: TextStyle(
                                                          color: Colors.grey),
                                                      hintText:
                                                          "點此填寫備註(飲料加大..etc)",
                                                      border: InputBorder.none,
                                                    ),
                                                  ),
                                                )),
                                            Expanded(
                                              flex: 1,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          left: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              26.133)),
                                                  Text(
                                                    "調整價錢",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontFamily: 'Yuanti',
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            23.05),
                                                    textScaleFactor: 1.3,
                                                  ),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          left: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              26.133)),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                                flex: 2,
                                                child: Padding(
                                                  padding: EdgeInsets.all(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          39.2),
                                                  child: TextFormField(
                                                    onChanged: (text) {
                                                      if (!isNumeric(text)) {
                                                        //數字檢查
                                                        BotToast.showCustomText(
                                                          toastBuilder: (_) =>
                                                              Align(
                                                            alignment:
                                                                Alignment(
                                                                    0, 0.8),
                                                            child: Card(
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            8),
                                                                child: Text(
                                                                  '只能輸入數字哦..',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Yuanti',
                                                                    fontSize:
                                                                        24,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          duration: Duration(
                                                              seconds: 3),
                                                          onlyOne: true,
                                                          clickClose: true,
                                                          ignoreContentClick:
                                                              true,
                                                        );
                                                        priceController.clear();
                                                      }
                                                    },
                                                    keyboardType:
                                                        TextInputType.number,
                                                    controller: priceController,
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                    maxLines: 1,
                                                    decoration: InputDecoration(
                                                      hintStyle: TextStyle(
                                                          color: Colors.grey),
                                                      hintText:
                                                          '輸入調整"後"的價錢(ex: 20)',
                                                      border: InputBorder.none,
                                                    ),
                                                  ),
                                                )),
                                            Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Colors.greenAccent,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          bottomLeft: Radius.circular(
                                                              MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  39.2),
                                                        )),
                                                    child: FutureBuilder<
                                                        List<String>>(
                                                      future: imanoMise,
                                                      builder:
                                                          (context, snapshot) {
                                                        return FlatButton(
                                                          onPressed: () {
                                                            MenuValue temp =
                                                                MenuValue(
                                                                    item.docID,
                                                                    item.keys,
                                                                    item.value);
                                                            temp.count =
                                                                item.count;
                                                            temp.notePrice = isNumeric(
                                                                    priceController
                                                                        .text)
                                                                ? priceController
                                                                    .text
                                                                : item.value
                                                                    .toString();
                                                            temp.note =
                                                                noteController
                                                                    .text;
                                                            prefFavList(
                                                                temp,
                                                                snapshot
                                                                    .data[0]);

                                                            setState(() {
                                                              item.note =
                                                                  noteController
                                                                      .text;
                                                              item.notePrice =
                                                                  priceController
                                                                      .text;
                                                              noteController
                                                                  .clear();
                                                              priceController
                                                                  .clear();
                                                            });
                                                            BotToast
                                                                .showCustomText(
                                                              toastBuilder:
                                                                  (_) => Align(
                                                                alignment:
                                                                    Alignment(
                                                                        0, 0.8),
                                                                child: Card(
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsets
                                                                        .symmetric(
                                                                            horizontal:
                                                                                8),
                                                                    child: Text(
                                                                      '喜愛列表新增成功',
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              'Yuanti',
                                                                          fontSize:
                                                                              24,
                                                                          color: Color.fromRGBO(
                                                                              18,
                                                                              18,
                                                                              18,
                                                                              1)),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              duration:
                                                                  Duration(
                                                                      seconds:
                                                                          3),
                                                              onlyOne: true,
                                                              clickClose: true,
                                                              ignoreContentClick:
                                                                  true,
                                                            );

                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Text(
                                                            "Favorite",
                                                            textScaleFactor:
                                                                1.6,
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'LilitaOne',
                                                                fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    23.05),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 2),
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Colors.greenAccent,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        10.0))),
                                                    child: FlatButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          //OK button
                                                          if (noteController
                                                                  .text !=
                                                              null) {
                                                            item.note =
                                                                noteController
                                                                    .text;
                                                          }
                                                          if (isNumeric(
                                                              priceController
                                                                  .text)) {
                                                            item.notePrice =
                                                                priceController
                                                                    .text;
                                                          }
                                                          noteController
                                                              .clear();
                                                          priceController
                                                              .clear();
                                                          Navigator.of(context)
                                                              .pop();
                                                        });
                                                      },
                                                      child: Text(
                                                        "OK",
                                                        textScaleFactor: 1.6,
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'LilitaOne',
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                23.05),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ]).show(context);
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 78.4,
                                ),
                                Visibility(
                                  visible: item.isShow,
                                  child: IconButton(
                                    color: Color.fromRGBO(29, 185, 84, 1),
                                    icon: Icon(Icons.remove_circle),
                                    iconSize:
                                        MediaQuery.of(context).size.width /
                                            12.25,
                                    onPressed: () {
                                      setState(() {
                                        item.notePrice = null;
                                        item.note = '';
                                        if (item.count > 0) {
                                          item.count = 0;
                                        }
                                        if (item.count == 0) {
                                          item.isShow = false;
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ]),
                            ),
                          );
                        } else {
                          docID = item.docID;
                          menuContain.add(setTitle(docID));
                          menuContain.add(
                            Padding(
                              padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height /
                                      56.66),
                              child: Row(children: <Widget>[
                                SizedBox(
                                  width: MediaQuery.of(context).size.width /
                                      26.133,
                                ),
                                Visibility(
                                  visible: item.isShow,
                                  child: Container(
                                    child: Text(
                                      '${item.count}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              12.25,
                                          fontFamily: 'LilitaOne'),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width /
                                                13.06,
                                        right:
                                            MediaQuery.of(context).size.width /
                                                13.06),
                                    child: BouncingWidget(
                                      scaleFactor: 1.0,
                                      child: Container(
                                        child: Center(
                                          child: Column(
                                            children: <Widget>[
                                              Text(
                                                '${item.keys}  ${isNumeric(item.notePrice) ? item.notePrice : item.value} ',
                                                style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        18, 18, 18, 1),
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            13.06,
                                                    fontFamily: 'Yuanti'),
                                              ),
                                              Visibility(
                                                visible: item.isShow,
                                                child: Text('${item.note}'),
                                              ),
                                            ],
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                            color:
                                                Color.fromRGBO(29, 185, 84, 1),
                                            borderRadius: BorderRadius.all(
                                                Radius.elliptical(10, 10))),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          item.count++;
                                          if (item.count > 0) {
                                            item.isShow = true;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: item.isShow,
                                  child: IconButton(
                                    color: Color.fromRGBO(29, 185, 84, 1),
                                    icon: Icon(Icons.assignment),
                                    iconSize:
                                        MediaQuery.of(context).size.width /
                                            12.25,
                                    onPressed: () {
                                      setState(() {
                                        EasyDialog(
                                            cardColor:
                                                Color.fromRGBO(18, 18, 18, 1),
                                            cornerRadius: 15.0,
                                            fogOpacity: 0.1,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.264,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                2.8,
                                            contentPadding: EdgeInsets.only(
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    70.833), // Needed for the button design
                                            contentList: [
                                              Expanded(
                                                flex: 1,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Padding(
                                                        padding: EdgeInsets.only(
                                                            left: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                26.133)),
                                                    Text(
                                                      "備註",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontFamily: 'Yuanti',
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              23.05),
                                                      textScaleFactor: 1.3,
                                                    ),
                                                    Padding(
                                                        padding: EdgeInsets.only(
                                                            left: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                26.133)),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                  flex: 2,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            39.2),
                                                    child: TextFormField(
                                                      controller:
                                                          noteController,
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                      maxLines: 1,
                                                      decoration:
                                                          InputDecoration(
                                                        hintStyle: TextStyle(
                                                            color: Colors.grey),
                                                        hintText:
                                                            "點此填寫備註(飲料加大..etc)",
                                                        border:
                                                            InputBorder.none,
                                                      ),
                                                    ),
                                                  )),
                                              Expanded(
                                                flex: 1,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Padding(
                                                        padding: EdgeInsets.only(
                                                            left: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                26.133)),
                                                    Text(
                                                      "調整價錢",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontFamily: 'Yuanti',
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              23.05),
                                                      textScaleFactor: 1.3,
                                                    ),
                                                    Padding(
                                                        padding: EdgeInsets.only(
                                                            left: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                26.133)),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                  flex: 2,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            39.2),
                                                    child: TextFormField(
                                                      onChanged: (text) {
                                                        if (!isNumeric(text)) {
                                                          //數字檢查
                                                          BotToast
                                                              .showCustomText(
                                                            toastBuilder: (_) =>
                                                                Align(
                                                              alignment:
                                                                  Alignment(
                                                                      0, 0.8),
                                                              child: Card(
                                                                child: Padding(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              8),
                                                                  child: Text(
                                                                    '只能輸入數字哦..',
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Yuanti',
                                                                      fontSize:
                                                                          24,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            duration: Duration(
                                                                seconds: 3),
                                                            onlyOne: true,
                                                            clickClose: true,
                                                            ignoreContentClick:
                                                                true,
                                                          );
                                                          priceController
                                                              .clear();
                                                        }
                                                      },
                                                      keyboardType:
                                                          TextInputType.number,
                                                      controller:
                                                          priceController,
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                      maxLines: 1,
                                                      decoration:
                                                          InputDecoration(
                                                        hintStyle: TextStyle(
                                                            color: Colors.grey),
                                                        hintText:
                                                            '輸入調整"後"的價錢(ex: 20)',
                                                        border:
                                                            InputBorder.none,
                                                      ),
                                                    ),
                                                  )),
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: Colors
                                                              .greenAccent,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10.0),
                                                          )),
                                                      child: FutureBuilder<
                                                          List<String>>(
                                                        future: imanoMise,
                                                        builder: (context,
                                                            snapshot) {
                                                          return FlatButton(
                                                            onPressed: () {
                                                              MenuValue temp =
                                                                  MenuValue(
                                                                      item.docID,
                                                                      item.keys,
                                                                      item.value);
                                                              temp.count =
                                                                  item.count;
                                                              temp.notePrice = isNumeric(
                                                                      priceController
                                                                          .text)
                                                                  ? priceController
                                                                      .text
                                                                  : item.value
                                                                      .toString();
                                                              temp.note =
                                                                  noteController
                                                                      .text;
                                                              prefFavList(
                                                                  temp,
                                                                  snapshot
                                                                      .data[0]);

                                                              setState(() {
                                                                item.note =
                                                                    noteController
                                                                        .text;
                                                                item.notePrice =
                                                                    priceController
                                                                        .text;
                                                                noteController
                                                                    .clear();
                                                                priceController
                                                                    .clear();
                                                              });
                                                              BotToast
                                                                  .showCustomText(
                                                                toastBuilder:
                                                                    (_) =>
                                                                        Align(
                                                                  alignment:
                                                                      Alignment(
                                                                          0,
                                                                          0.8),
                                                                  child: Card(
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              8),
                                                                      child:
                                                                          Text(
                                                                        '喜愛列表新增成功',
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Yuanti',
                                                                            fontSize:
                                                                                24,
                                                                            color: Color.fromRGBO(
                                                                                18,
                                                                                18,
                                                                                18,
                                                                                1)),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            3),
                                                                onlyOne: true,
                                                                clickClose:
                                                                    true,
                                                                ignoreContentClick:
                                                                    true,
                                                              );
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Text(
                                                              "Favorite",
                                                              textScaleFactor:
                                                                  1.6,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'LilitaOne',
                                                                  fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      23.05),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 2),
                                                  Expanded(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: Colors
                                                              .greenAccent,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          10.0))),
                                                      child: FlatButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            item.note =
                                                                noteController
                                                                    .text;
                                                            item.notePrice =
                                                                priceController
                                                                    .text;
                                                            noteController
                                                                .clear();
                                                            priceController
                                                                .clear();
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          });
                                                        },
                                                        child: Text(
                                                          "OK",
                                                          textScaleFactor: 1.6,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'LilitaOne',
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  23.05),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ]).show(context);
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 78.4,
                                ),
                                Visibility(
                                  visible: item.isShow,
                                  child: IconButton(
                                    color: Color.fromRGBO(29, 185, 84, 1),
                                    icon: Icon(Icons.remove_circle),
                                    iconSize:
                                        MediaQuery.of(context).size.width /
                                            12.25,
                                    onPressed: () {
                                      setState(() {
                                        item.notePrice = null;
                                        item.note = '';
                                        if (item.count > 0) {
                                          item.count = 0;
                                        }
                                        if (item.count == 0) {
                                          item.isShow = false;
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ]),
                            ),
                          );
                        }
                      }
                      menuContain.add(SizedBox(
                        height: MediaQuery.of(context).size.height / 18,
                      ));
                      //底層間隔
                      return SliverList(
                        delegate: SliverChildListDelegate(menuContain),
                      );
                    } else {
                      return SliverList(
                        delegate: SliverChildListDelegate([
                          Container(
                            height: MediaQuery.of(context).size.height / 21.25,
                          ),
                          Center(
                            child: SpinKitThreeBounce(
                              color: Colors.white,
                            ),
                          )
                        ]),
                      );
                    }
                  }
                  return SliverList(
                    delegate: SliverChildListDelegate([
                      Container(
                        height: MediaQuery.of(context).size.height / 21.25,
                      ),
                      Center(
                        child: SpinKitThreeBounce(
                          color: Colors.white,
                        ),
                      )
                    ]),
                  );
                },
              ),
            ],
          ),
          FutureBuilder<List<MenuValue>>(
            future: menuObjList,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                int allCount = 0;
                double allPrice = 0;
                for (var item in snapshot.data) {
                  allCount = allCount + item.count;
                  if (item.count > 0) {
                    allPrice = allPrice +
                        (item.count *
                            (isNumeric(item.notePrice)
                                ? double.parse(item.notePrice)
                                : item.value));
                  }
                }
                return Container(
                  height: MediaQuery.of(context).size.height / 18,
                  width: MediaQuery.of(context).size.width,
                  color: Color.fromRGBO(18, 18, 18, 1),
                  child: Center(
                    child: Text(
                      '共 $allCount 品項 , ${allPrice.round()} 元',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Yuanti',
                        fontSize: MediaQuery.of(context).size.height / 25,
                      ),
                    ),
                  ),
                );
              }
              return Container(
                height: MediaQuery.of(context).size.height / 18,
                width: MediaQuery.of(context).size.width,
                color: Color.fromRGBO(18, 18, 18, 1),
                child: Center(
                  child: SpinKitThreeBounce(
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
