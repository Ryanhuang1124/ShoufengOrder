import 'package:bot_toast/bot_toast.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_dialog/easy_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cupertino_tabbar/cupertino_tabbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoufeng_order/tools/accounting_builder.dart';
import 'package:shoufeng_order/tools/member_builder.dart';
import 'package:shoufeng_order/tools/menu_builder.dart';
import 'package:shoufeng_order/tools/vote_builder.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class AccountContent extends StatefulWidget {
  @override
  _AccountContentState createState() => _AccountContentState();
}

class _AccountContentState extends State<AccountContent> {
  final TextEditingController changeController = TextEditingController();
  final fireStore = Firestore.instance;
  int cupertinoTabBarValue = 0;
  int cupertinoTabBarValueGetter() {
    return cupertinoTabBarValue;
  }

  Future<String> userName;
  String _selectType;
  String _couponCount;

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

  @override
  void initState() {
    super.initState();
    userName = getUserName();
  }

  Widget showPopupMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        setState(() {});
        if (value == '返回上一頁') {
          Navigator.pop(context);
        }
      },
      itemBuilder: (context) {
        return <PopupMenuItem<String>>[
          PopupMenuItem<String>(
            value: '刪除我的訂單',
            child: Text('刪除我的訂單'),
          ),
          PopupMenuItem<String>(
            value: '清空所有訂單',
            child: Text('清空所有訂單'),
          ),
          PopupMenuItem<String>(
            value: '返回上一頁',
            child: Text('返回上一頁'),
          ),
        ];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 18, 18, 1),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(18, 18, 18, 1),
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: fireStore.collection('Members').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<double> totalPriceList = [];
                List<FinalOrder> objListTemp = [];
                List<FinalOrderWidgets> widgetTemp = [];
                for (var order in snapshot.data.documents) {
                  //data二維陣列
                  FinalOrder temp = new FinalOrder();
                  temp.userName = order.documentID;
                  order.data.forEach((k, v) {
                    temp.keys.add(v[0]);
                    temp.value.add(v[1]);
                    temp.notePrice.add(v[2]);
                    temp.note.add(v[3]);
                    temp.count.add(v[4]);
                  });
                  objListTemp.add(temp);
                }
                for (var obj in objListTemp) {
                  //widgets二維陣列
                  FinalOrderWidgets widgetsObjTemp = new FinalOrderWidgets();
                  for (int i = 0; i < obj.keys.length; i++) {
                    widgetsObjTemp.widgets.add(Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 5,
                            child: Center(
                              child: Text(
                                obj.count[i],
                                style: TextStyle(
                                    fontFamily: 'LilitaOne',
                                    fontSize:
                                        MediaQuery.of(context).size.width / 20),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 16,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(29, 185, 84, 1),
                              ),
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    '${obj.keys[i]} ',
                                    style: TextStyle(
                                        fontFamily: 'Yuanti',
                                        color: Color.fromRGBO(18, 18, 18, 1),
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                20),
                                  ),
                                  Text(
                                    '${obj.note[i]}',
                                    style: TextStyle(
                                        fontFamily: 'Yuanti',
                                        color: Colors.redAccent,
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                30),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 6,
                            child: Center(
                              child: Text(
                                  '${isNumeric(obj.notePrice[i]) ? obj.notePrice[i] : obj.value[i]}',
                                  style: TextStyle(
                                      fontFamily: 'LilitaOne',
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              20)),
                            ),
                          ),
                        ],
                      ),
                    ));
                  }

                  widgetTemp.add(widgetsObjTemp);
                }
                for (int i = 0; i < objListTemp.length; i++) {
                  double temp = 0;
                  for (int j = 0; j < objListTemp[i].notePrice.length; j++) {
                    temp = temp +
                        double.parse(objListTemp[i].count[j]) *
                            (isNumeric(objListTemp[i].notePrice[j])
                                ? double.parse(objListTemp[i].notePrice[j])
                                : double.parse(objListTemp[i].value[j]));
                  }
                  totalPriceList.add(temp);
                }

                //合單data build
                IntegrateOrderObj objIntegrate = integrateBuilder(objListTemp);
                int sumPrice = sumOfTotalPriceCalculator(totalPriceList);
                int integrateCount = 0;
                for (var item in objIntegrate.count) {
                  if (int.tryParse(item) != null) {
                    integrateCount = integrateCount + int.parse(item);
                  }
                }

                return Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width / 50,
                      right: MediaQuery.of(context).size.width / 50,
                      top: MediaQuery.of(context).size.height / 200),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        flex: 6,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Container(
                                  child: CupertinoTabBar(
                                Color.fromRGBO(18, 18, 18, 1),
                                Color.fromRGBO(18, 18, 18, 1),
                                [
                                  Center(
                                    child: Text(
                                      '分單',
                                      style: TextStyle(
                                          fontFamily: 'Yuanti',
                                          fontSize: cupertinoTabBarValue == 0
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  15
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  20,
                                          color: cupertinoTabBarValue == 0
                                              ? Color.fromRGBO(229, 229, 229, 1)
                                              : Color.fromRGBO(92, 92, 92, 1)),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      '合單',
                                      style: TextStyle(
                                        fontFamily: 'Yuanti',
                                        fontSize: cupertinoTabBarValue == 1
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                15
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                20,
                                        color: cupertinoTabBarValue == 1
                                            ? Color.fromRGBO(229, 229, 229, 1)
                                            : Color.fromRGBO(92, 92, 92, 1),
                                      ),
                                    ),
                                  )
                                ],
                                cupertinoTabBarValueGetter,
                                (int index) {
                                  //_onTap
                                  setState(() {
                                    cupertinoTabBarValue = index;
                                  });
                                },
                              )),
                            ),
                            Expanded(flex: 1, child: SizedBox()),
                            StreamBuilder<QuerySnapshot>(
                              stream:
                                  fireStore.collection('StoreList').snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  String storeName = '';
                                  String phoneNum = 'Unknow';
                                  for (var item in snapshot.data.documents) {
                                    if (item.documentID == 'imanomise') {
                                      item.data.forEach((k, v) {
                                        storeName = v;
                                      });
                                    }
                                  }
                                  for (var item in snapshot.data.documents) {
                                    if (item.documentID == 'Stores') {
                                      item.data.forEach((k, v) {
                                        if (k == storeName) {
                                          if (v != null) {
                                            phoneNum = v;
                                          }
                                        }
                                      });
                                    }
                                  }

                                  return Expanded(
                                    flex: 3,
                                    child: Container(
                                        child: Center(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              phoneNum,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'LilitaOne',
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          22),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              storeName,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Yuanti',
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          18),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                  );
                                } else {
                                  return Expanded(child: Container());
                                }
                              },
                            ),
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () {
                                  EasyDialog(
                                      //d
                                      cardColor: Color.fromRGBO(18, 18, 18, 1),
                                      cornerRadius: 15.0,
                                      fogOpacity: 0.1,
                                      width: MediaQuery.of(context).size.width /
                                          1.568,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              4.25,
                                      contentPadding: EdgeInsets.only(
                                        top:
                                            MediaQuery.of(context).size.height /
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
                                          child: SizedBox(),
                                        ),
                                        Expanded(
                                          child: Container(
                                            child: Text(
                                              '要刪除自己的訂單嗎？',
                                              style: TextStyle(
                                                  fontFamily: 'Yuanti',
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          17.81,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: SizedBox(),
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
                                                          fontFamily:
                                                              'LilitaOne',
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
                                                            Radius.circular(
                                                                10.0),
                                                      )),
                                                  child: FlatButton(
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
                                                    onPressed: () async {
                                                      setState(() {});
                                                      clearOrderCache(
                                                          fireStore);
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
                                                                '刪除完成！',
                                                                style:
                                                                    TextStyle(
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
                                                        duration: Duration(
                                                            seconds: 3),
                                                        onlyOne: true,
                                                        clickClose: true,
                                                        ignoreContentClick:
                                                            true,
                                                      );

                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]).show(context);
                                },
                                child: Icon(
                                  Icons.delete_forever,
                                  size: MediaQuery.of(context).size.width / 8,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Hero(
                                tag: 'bottle_accounting',
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    child: Image.asset(
                                      'images/message_in_a_bottle.png',
                                      scale: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ), // TopRow
                      cupertinoTabBarValue == 0
                          ? Expanded(
                              flex: 65,
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      child: StaggeredGridView.countBuilder(
                                        crossAxisCount: 4,
                                        itemCount: objListTemp.length,
                                        itemBuilder:
                                            (BuildContext context, int index) =>
                                                GestureDetector(
                                          onTap: () {
                                            EasyDialog(
                                                cardColor: Color.fromRGBO(
                                                    18, 18, 18, 1),
                                                cornerRadius: 15.0,
                                                fogOpacity: 0.1,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.568,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    3,
                                                contentPadding: EdgeInsets.only(
                                                  top: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      70.83,
                                                ), // Needed for the button design
                                                contentList: [
                                                  Expanded(
                                                    child: StatefulBuilder(
                                                      builder:
                                                          (context, setState) {
                                                        return Column(
                                                          children: <Widget>[
                                                            Expanded(
                                                              flex: 1,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: <
                                                                    Widget>[
                                                                  Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left: MediaQuery.of(context).size.width /
                                                                              30)),
                                                                  Text(
                                                                    "付款",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontFamily:
                                                                            'Yuanti',
                                                                        fontSize:
                                                                            MediaQuery.of(context).size.width /
                                                                                23.05),
                                                                    textScaleFactor:
                                                                        1.3,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 1,
                                                              child: Padding(
                                                                padding: EdgeInsets.only(
                                                                    left: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        20),
                                                                child:
                                                                    KeyboardActions(
                                                                  config:
                                                                      _buildConfig(
                                                                          context),
                                                                  child:
                                                                      TextField(
                                                                    onChanged:
                                                                        (data) {
                                                                      if (!isNumeric(
                                                                          data)) {
                                                                        changeController
                                                                            .clear();
                                                                        BotToast
                                                                            .showCustomText(
                                                                          toastBuilder: (_) =>
                                                                              Align(
                                                                            alignment:
                                                                                Alignment(0, 0.8),
                                                                            child:
                                                                                Card(
                                                                              child: Padding(
                                                                                padding: EdgeInsets.symmetric(horizontal: 8),
                                                                                child: Text(
                                                                                  '只能輸入數字哦..',
                                                                                  style: TextStyle(
                                                                                    fontFamily: 'Yuanti',
                                                                                    fontSize: 24,
                                                                                    color: Color.fromRGBO(18, 18, 18, 1),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          duration:
                                                                              Duration(seconds: 3),
                                                                          onlyOne:
                                                                              true,
                                                                          clickClose:
                                                                              true,
                                                                          ignoreContentClick:
                                                                              true,
                                                                        );
                                                                      }
                                                                    },
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                    focusNode:
                                                                        _nodeText1,
                                                                    controller:
                                                                        changeController,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                    maxLines: 1,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      hintStyle:
                                                                          TextStyle(
                                                                              color: Colors.grey),
                                                                      hintText:
                                                                          "輸入已付金額(不是找錢金額..)",
                                                                      border: InputBorder
                                                                          .none,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 1,
                                                              child:
                                                                  FutureBuilder<
                                                                      String>(
                                                                future:
                                                                    userName,
                                                                builder: (context,
                                                                    snapshot) {
                                                                  String
                                                                      userName =
                                                                      '';
                                                                  if (snapshot
                                                                      .hasData) {
                                                                    userName =
                                                                        snapshot
                                                                            .data;
                                                                  }
                                                                  return Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: <
                                                                        Widget>[
                                                                      Padding(
                                                                          padding:
                                                                              EdgeInsets.only(left: MediaQuery.of(context).size.width / 30)),
                                                                      Text(
                                                                        "折價券",
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .white,
                                                                            fontFamily:
                                                                                'Yuanti',
                                                                            fontSize:
                                                                                MediaQuery.of(context).size.width / 23.05),
                                                                        textScaleFactor:
                                                                            1.3,
                                                                      ),
                                                                      Expanded(
                                                                          child:
                                                                              SizedBox()),
                                                                      Text(
                                                                        '剩餘: ',
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'LilitaOne',
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: MediaQuery.of(context).size.width / 23.05),
                                                                      ),
                                                                      StreamBuilder<
                                                                          QuerySnapshot>(
                                                                        stream: Firestore
                                                                            .instance
                                                                            .collection('Coupons')
                                                                            .snapshots(),
                                                                        builder:
                                                                            (context,
                                                                                snapshot) {
                                                                          int couponsCount =
                                                                              0;
                                                                          if (snapshot
                                                                              .hasData) {
                                                                            for (var doc
                                                                                in snapshot.data.documents) {
                                                                              if (doc.documentID == userName) {
                                                                                doc.data.forEach((k, v) {
                                                                                  if (k == 'coupons') {
                                                                                    couponsCount = v;
                                                                                  }
                                                                                });
                                                                              }
                                                                            }
                                                                          }
                                                                          return Container(
                                                                            child:
                                                                                Text(
                                                                              couponsCount.toString(),
                                                                              style: TextStyle(fontFamily: 'LilitaOne', color: Colors.white, fontSize: MediaQuery.of(context).size.width / 22),
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                      SizedBox(
                                                                        width: MediaQuery.of(context).size.width /
                                                                            20,
                                                                      )
                                                                    ],
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child:
                                                                  FutureBuilder(
                                                                future:
                                                                    userName,
                                                                builder: (context,
                                                                    snapshot) {
                                                                  String
                                                                      userName =
                                                                      '';
                                                                  if (snapshot
                                                                      .hasData) {
                                                                    userName =
                                                                        snapshot
                                                                            .data;
                                                                  }
                                                                  return Row(
                                                                    children: <
                                                                        Widget>[
                                                                      SizedBox(
                                                                        width: MediaQuery.of(context).size.width /
                                                                            20,
                                                                      ),
                                                                      SizedBox(
                                                                        width: MediaQuery.of(context).size.width /
                                                                            20,
                                                                      ),
                                                                      Container(
                                                                          padding: EdgeInsets.only(
                                                                              left: MediaQuery.of(context).size.width /
                                                                                  20),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Colors.greenAccent,
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(10)),
                                                                          ),
                                                                          child: StreamBuilder<QuerySnapshot>(
                                                                              stream: Firestore.instance.collection('Coupons').snapshots(),
                                                                              builder: (context, snapshot) {
                                                                                int couponsCount = 0;
                                                                                if (snapshot.hasData) {
                                                                                  for (var doc in snapshot.data.documents) {
                                                                                    if (doc.documentID == userName) {
                                                                                      doc.data.forEach((k, v) {
                                                                                        if (k == 'coupons') {
                                                                                          couponsCount = v;
                                                                                        }
                                                                                      });
                                                                                    }
                                                                                  }
                                                                                }
                                                                                return DropdownButtonHideUnderline(
                                                                                    child: DropdownButton(
                                                                                  items: <DropdownMenuItem>[
                                                                                    DropdownMenuItem(
                                                                                      child: Center(
                                                                                        child: Text(
                                                                                          '請選擇',
                                                                                          style: TextStyle(fontFamily: 'Yuanti', fontSize: 22, color: Color.fromRGBO(18, 18, 18, 1)),
                                                                                        ),
                                                                                      ),
                                                                                      value: '請選擇',
                                                                                    ),
                                                                                    DropdownMenuItem(
                                                                                      child: Center(
                                                                                        child: Text(
                                                                                          '1',
                                                                                          style: TextStyle(fontFamily: 'Yuanti', fontSize: 22, color: Color.fromRGBO(18, 18, 18, 1)),
                                                                                        ),
                                                                                      ),
                                                                                      value: '1',
                                                                                    ),
                                                                                    DropdownMenuItem(
                                                                                      child: Center(
                                                                                        child: Text(
                                                                                          '2',
                                                                                          style: TextStyle(fontFamily: 'Yuanti', fontSize: 22, color: Color.fromRGBO(18, 18, 18, 1)),
                                                                                        ),
                                                                                      ),
                                                                                      value: '2',
                                                                                    ),
                                                                                    DropdownMenuItem(
                                                                                      child: Center(
                                                                                        child: Text(
                                                                                          '3',
                                                                                          style: TextStyle(fontFamily: 'Yuanti', fontSize: 22, color: Color.fromRGBO(18, 18, 18, 1)),
                                                                                        ),
                                                                                      ),
                                                                                      value: '3',
                                                                                    ),
                                                                                    DropdownMenuItem(
                                                                                      child: Center(
                                                                                        child: Text(
                                                                                          '4',
                                                                                          style: TextStyle(fontFamily: 'Yuanti', fontSize: 22, color: Color.fromRGBO(18, 18, 18, 1)),
                                                                                        ),
                                                                                      ),
                                                                                      value: '4',
                                                                                    ),
                                                                                    DropdownMenuItem(
                                                                                      child: Center(
                                                                                        child: Text(
                                                                                          '5',
                                                                                          style: TextStyle(fontFamily: 'Yuanti', fontSize: 22, color: Color.fromRGBO(18, 18, 18, 1)),
                                                                                        ),
                                                                                      ),
                                                                                      value: '5',
                                                                                    ),
                                                                                  ],
                                                                                  hint: Text(
                                                                                    '請選擇',
                                                                                    style: TextStyle(color: Color.fromRGBO(18, 18, 18, 1)),
                                                                                  ),
                                                                                  onChanged: (value) {
                                                                                    int temp = 0;
                                                                                    if (value != '請選擇') {
                                                                                      temp = int.tryParse(value);
                                                                                    }

                                                                                    if (temp <= couponsCount) {
                                                                                      _couponCount = value;
                                                                                    } else {
                                                                                      BotToast.showCustomText(
                                                                                        toastBuilder: (_) => Align(
                                                                                          alignment: Alignment(0, 0.8),
                                                                                          child: Card(
                                                                                            child: Padding(
                                                                                              padding: EdgeInsets.symmetric(horizontal: 8),
                                                                                              child: Text(
                                                                                                '折價券不夠了！',
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
                                                                                      _couponCount = '請選擇';
                                                                                    }
                                                                                    setState(() {});
                                                                                  },
                                                                                  value: _couponCount,
                                                                                  elevation: 24,
                                                                                  style: new TextStyle(
                                                                                    fontFamily: 'Yuanti',
                                                                                    color: Colors.white,
                                                                                    fontSize: 22,
                                                                                  ),
                                                                                  icon: Icon(Icons.arrow_drop_down),
                                                                                  iconSize: MediaQuery.of(context).size.height / 20,
                                                                                  iconEnabledColor: Color.fromRGBO(18, 18, 18, 1),
                                                                                ));
                                                                              })),
                                                                    ],
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height /
                                                                  100,
                                                            ),
                                                            Expanded(
                                                              child: Row(
                                                                children: <
                                                                    Widget>[
                                                                  Expanded(
                                                                    child:
                                                                        Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .greenAccent,
                                                                        borderRadius:
                                                                            BorderRadius.only(
                                                                          bottomLeft:
                                                                              Radius.circular(10.0),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          FlatButton(
                                                                        child:
                                                                            Text(
                                                                          "Cancel",
                                                                          textScaleFactor:
                                                                              1.6,
                                                                          style: TextStyle(
                                                                              fontFamily: 'LilitaOne',
                                                                              fontSize: MediaQuery.of(context).size.width / 24.5),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 1,
                                                                  ),
                                                                  Expanded(
                                                                    child: FutureBuilder<
                                                                            String>(
                                                                        future:
                                                                            userName,
                                                                        builder:
                                                                            (context,
                                                                                snapshot) {
                                                                          String
                                                                              userName =
                                                                              '';
                                                                          if (snapshot
                                                                              .hasData) {
                                                                            userName =
                                                                                snapshot.data;
                                                                          }
                                                                          return Container(
                                                                            decoration: BoxDecoration(
                                                                                color: Colors.greenAccent,
                                                                                borderRadius: BorderRadius.only(
                                                                                  bottomRight: Radius.circular(10.0),
                                                                                )),
                                                                            child:
                                                                                FlatButton(
                                                                              child: Text(
                                                                                "OK",
                                                                                textScaleFactor: 1.6,
                                                                                style: TextStyle(fontFamily: 'LilitaOne', fontSize: MediaQuery.of(context).size.width / 23.05),
                                                                              ),
                                                                              onPressed: () {
                                                                                String tempState;
                                                                                tempState = stateBuilder(changeController.text, totalPriceList[index].floor().toDouble(), _couponCount);
                                                                                setState(() {});
                                                                                if (tempState != '-1') {
                                                                                  uploadOrderState(fireStore, objListTemp[index].userName, tempState, changesBuilder(changeController.text, totalPriceList[index], _couponCount), changeController.text, _couponCount);
                                                                                  if (_couponCount != '請選擇') {
                                                                                    consumeCoupon(userName, _couponCount);
                                                                                  }

                                                                                  BotToast.showCustomText(
                                                                                    toastBuilder: (_) => Align(
                                                                                      alignment: Alignment(0, 0.8),
                                                                                      child: Card(
                                                                                        child: Padding(
                                                                                          padding: EdgeInsets.symmetric(horizontal: 8),
                                                                                          child: Text(
                                                                                            '付款成功',
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
                                                                                  changeController.clear();
                                                                                  _couponCount = '請選擇';
                                                                                } else {
                                                                                  BotToast.showCustomText(
                                                                                    toastBuilder: (_) => Align(
                                                                                      alignment: Alignment(0, 0.8),
                                                                                      child: Card(
                                                                                        child: Padding(
                                                                                          padding: EdgeInsets.symmetric(horizontal: 8),
                                                                                          child: Text(
                                                                                            '不能負債啦..',
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
                                                                                  changeController.clear();
                                                                                }

                                                                                Navigator.pop(context);
                                                                              },
                                                                            ),
                                                                          );
                                                                        }),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  )
                                                ]).show(context);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Color.fromRGBO(
                                                  29, 185, 84, 1),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(12),
                                              ),
                                            ),
                                            child: Column(
                                              children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              30),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Text(
                                                        objListTemp[index]
                                                            .userName,
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Yuanti',
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                15),
                                                      ),
                                                      Expanded(
                                                          child: SizedBox()),
                                                      StreamBuilder<
                                                              QuerySnapshot>(
                                                          stream: Firestore
                                                              .instance
                                                              .collection(
                                                                  'FinalState')
                                                              .snapshots(),
                                                          builder: (context,
                                                              snapshot) {
                                                            String couponCount =
                                                                '';
                                                            if (snapshot
                                                                .hasData) {
                                                              for (var doc
                                                                  in snapshot
                                                                      .data
                                                                      .documents) {
                                                                if (doc.documentID ==
                                                                    objListTemp[
                                                                            index]
                                                                        .userName) {
                                                                  doc.data
                                                                      .forEach(
                                                                          (k, v) {
                                                                    if (k ==
                                                                        'couponCount') {
                                                                      couponCount =
                                                                          v;
                                                                    }
                                                                  });
                                                                }
                                                              }
                                                            }
                                                            return Row(
                                                              children: <
                                                                  Widget>[
                                                                Container(
                                                                    child: Text(
                                                                  '$couponCount*',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'LilitaOne',
                                                                    fontSize: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        20,
                                                                  ),
                                                                )),
                                                                Container(
                                                                  child: Image
                                                                      .asset(
                                                                    'images/coupon.png',
                                                                    scale: 1,
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          }),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            50,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  child: Column(
                                                    children: widgetTemp[index]
                                                        .widgets,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      30,
                                                ),
                                                Container(
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Expanded(
                                                        flex: 2,
                                                        child: Center(
                                                          child: Text(
                                                            '總計',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'LilitaOne',
                                                                fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    17),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Center(
                                                          child: Text(
                                                            totalPriceList[
                                                                    index]
                                                                .floor()
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'LilitaOne',
                                                                fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    17),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Center(
                                                          child: Text(
                                                            '元',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'LilitaOne',
                                                                fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    17),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                StreamBuilder<QuerySnapshot>(
                                                    stream: fireStore
                                                        .collection(
                                                            'FinalState')
                                                        .snapshots(),
                                                    builder:
                                                        (context, snapshot) {
                                                      List<OrderState>
                                                          tempList = [];
                                                      if (snapshot.hasData) {
                                                        for (var item
                                                            in snapshot.data
                                                                .documents) {
                                                          OrderState temp =
                                                              new OrderState();
                                                          if (item.documentID ==
                                                              objListTemp[index]
                                                                  .userName) {
                                                            item.data.forEach(
                                                                (k, v) {
                                                              if (k ==
                                                                  'changes') {
                                                                temp.changes =
                                                                    v;
                                                              }
                                                              if (k ==
                                                                  'state') {
                                                                temp.state = v;
                                                              }
                                                              if (k == 'paid') {
                                                                temp.paid = v;
                                                              }
                                                            });
                                                          }
                                                          tempList.add(temp);
                                                        }

                                                        return Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              8,
                                                          child: Row(
                                                            children: <Widget>[
                                                              GestureDetector(
                                                                onTap: () {
                                                                  EasyDialog(
                                                                      cardColor:
                                                                          Color.fromRGBO(
                                                                              18,
                                                                              18,
                                                                              18,
                                                                              1),
                                                                      cornerRadius:
                                                                          15.0,
                                                                      fogOpacity:
                                                                          0.1,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          1.568,
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height /
                                                                          4.25,
                                                                      contentPadding:
                                                                          EdgeInsets
                                                                              .only(
                                                                        top: MediaQuery.of(context).size.height /
                                                                            70.83,
                                                                      ), // Needed for the button design
                                                                      contentList: [
                                                                        Expanded(
                                                                          child:
                                                                              StatefulBuilder(
                                                                            builder:
                                                                                (context, setState) {
                                                                              return Column(
                                                                                children: <Widget>[
                                                                                  Expanded(
                                                                                    flex: 1,
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                      children: <Widget>[
                                                                                        Padding(padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 30)),
                                                                                        Text(
                                                                                          "更改付款狀態",
                                                                                          style: TextStyle(color: Colors.white, fontFamily: 'Yuanti', fontSize: MediaQuery.of(context).size.width / 23.05),
                                                                                          textScaleFactor: 1.3,
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  Expanded(
                                                                                    child: Row(
                                                                                      children: <Widget>[
                                                                                        SizedBox(
                                                                                          width: MediaQuery.of(context).size.width / 20,
                                                                                        ),
                                                                                        Container(
                                                                                          child: Text(
                                                                                            '狀態',
                                                                                            style: TextStyle(fontFamily: 'Yuanti', fontSize: MediaQuery.of(context).size.width / 20, color: Colors.white),
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(
                                                                                          width: MediaQuery.of(context).size.width / 20,
                                                                                        ),
                                                                                        Container(
                                                                                            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 20),
                                                                                            decoration: BoxDecoration(
                                                                                              color: Colors.greenAccent,
                                                                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                                                                            ),
                                                                                            child: DropdownButtonHideUnderline(
                                                                                                child: DropdownButton(
                                                                                              items: <DropdownMenuItem>[
                                                                                                DropdownMenuItem(
                                                                                                  child: Center(
                                                                                                    child: Text(
                                                                                                      '未付',
                                                                                                      style: TextStyle(fontFamily: 'Yuanti', fontSize: 22, color: Color.fromRGBO(18, 18, 18, 1)),
                                                                                                    ),
                                                                                                  ),
                                                                                                  value: '未付',
                                                                                                ),
                                                                                                DropdownMenuItem(
                                                                                                  child: Center(
                                                                                                    child: Text(
                                                                                                      '結清',
                                                                                                      style: TextStyle(fontFamily: 'Yuanti', fontSize: 22, color: Color.fromRGBO(18, 18, 18, 1)),
                                                                                                    ),
                                                                                                  ),
                                                                                                  value: '結清',
                                                                                                ),
                                                                                              ],
                                                                                              hint: Text(
                                                                                                '請選擇',
                                                                                                style: TextStyle(color: Color.fromRGBO(18, 18, 18, 1)),
                                                                                              ),
                                                                                              onChanged: (value) {
                                                                                                setState(() {
                                                                                                  _selectType = value;
                                                                                                });
                                                                                              },
                                                                                              value: _selectType,
                                                                                              elevation: 24,
                                                                                              style: new TextStyle(
                                                                                                fontFamily: 'Yuanti',
                                                                                                color: Colors.white,
                                                                                                fontSize: 22,
                                                                                              ),
                                                                                              icon: Icon(Icons.arrow_drop_down),
                                                                                              iconSize: MediaQuery.of(context).size.height / 20,
                                                                                              iconEnabledColor: Color.fromRGBO(18, 18, 18, 1),
                                                                                            ))),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: MediaQuery.of(context).size.height / 20,
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
                                                                                                style: TextStyle(fontFamily: 'LilitaOne', fontSize: MediaQuery.of(context).size.width / 24.5),
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
                                                                                                  bottomRight: Radius.circular(10.0),
                                                                                                )),
                                                                                            child: FlatButton(
                                                                                              child: Text(
                                                                                                "OK",
                                                                                                textScaleFactor: 1.6,
                                                                                                style: TextStyle(fontFamily: 'LilitaOne', fontSize: MediaQuery.of(context).size.width / 23.05),
                                                                                              ),
                                                                                              onPressed: () {
                                                                                                setState(() {});

                                                                                                changeOrderState(fireStore, objListTemp[index].userName, _selectType, '0');

                                                                                                BotToast.showCustomText(
                                                                                                  toastBuilder: (_) => Align(
                                                                                                    alignment: Alignment(0, 0.8),
                                                                                                    child: Card(
                                                                                                      child: Padding(
                                                                                                        padding: EdgeInsets.symmetric(horizontal: 8),
                                                                                                        child: Text(
                                                                                                          '更改成功',
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
                                                                                                Navigator.pop(context);
                                                                                              },
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              );
                                                                            },
                                                                          ),
                                                                        )
                                                                      ]).show(
                                                                      context);
                                                                },
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                          color: Colors
                                                                              .greenAccent,
                                                                          borderRadius:
                                                                              BorderRadius.only(
                                                                            topRight:
                                                                                Radius.circular(15),
                                                                            topLeft:
                                                                                Radius.circular(15),
                                                                            bottomRight:
                                                                                Radius.circular(15),
                                                                          )),
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      8,
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      8,
                                                                  child:
                                                                      Visibility(
                                                                    visible:
                                                                        tempList[index].state ==
                                                                            '結清',
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        'OK',
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'LilitaOne',
                                                                            fontSize: MediaQuery.of(context).size.width /
                                                                                15,
                                                                            color: Color.fromRGBO(
                                                                                18,
                                                                                18,
                                                                                18,
                                                                                1)),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  child: Column(
                                                                    children: <
                                                                        Widget>[
                                                                      Visibility(
                                                                        visible:
                                                                            tempList[index].state !=
                                                                                '未付',
                                                                        child:
                                                                            Expanded(
                                                                          child:
                                                                              Text(
                                                                            '付 ${tempList[index].paid} 元',
                                                                            style:
                                                                                TextStyle(
                                                                              color: Color.fromRGBO(18, 18, 18, 1),
                                                                              fontFamily: 'Yuanti',
                                                                              fontSize: MediaQuery.of(context).size.width / 20,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          tempList[index].state != '結清'
                                                                              ? (tempList[index].state == '找錢' ? '找錢 ${tempList[index].changes} 元' : tempList[index].state)
                                                                              : '',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.redAccent,
                                                                            fontFamily:
                                                                                'Yuanti',
                                                                            fontSize:
                                                                                MediaQuery.of(context).size.width / 20,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        );
                                                      } else {
                                                        return SpinKitThreeBounce(
                                                            color:
                                                                Colors.white);
                                                      }
                                                    })
                                              ],
                                            ),
                                          ),
                                        ),
                                        staggeredTileBuilder: (int index) =>
                                            StaggeredTile.fit(2),
                                        mainAxisSpacing: 6.0,
                                        crossAxisSpacing: 6.0,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height:
                                        MediaQuery.of(context).size.height / 15,
                                    child: Center(
                                        child: BouncingWidget(
                                      onPressed: () {
                                        EasyDialog(
                                            //d
                                            cardColor:
                                                Color.fromRGBO(18, 18, 18, 1),
                                            cornerRadius: 15.0,
                                            fogOpacity: 0.1,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.568,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                4.25,
                                            contentPadding: EdgeInsets.only(
                                              top: MediaQuery.of(context)
                                                      .size
                                                      .height /
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
                                                            EdgeInsets.only(
                                                                left: 15.0)),
                                                    Text(
                                                      "提醒",
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
                                                          left: 15.0),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  child: Text(
                                                    '確定清空全部訂單',
                                                    style: TextStyle(
                                                        fontFamily: 'Yuanti',
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            17.81,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  child: Text(
                                                    '並重啟投票？',
                                                    style: TextStyle(
                                                        fontFamily: 'Yuanti',
                                                        fontSize: MediaQuery.of(
                                                                    context)
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
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .greenAccent,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10.0),
                                                          ),
                                                        ),
                                                        child: FlatButton(
                                                          child: Text(
                                                            "Cancel",
                                                            textScaleFactor:
                                                                1.6,
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'LilitaOne',
                                                                fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    24.5),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 1,
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                color: Colors
                                                                    .greenAccent,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          10.0),
                                                                )),
                                                        child: FlatButton(
                                                          child: Text(
                                                            "OK",
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
                                                          onPressed: () async {
                                                            setState(() {});
                                                            SharedPreferences
                                                                prefs =
                                                                await SharedPreferences
                                                                    .getInstance();
                                                            String userName =
                                                                prefs.getString(
                                                                    'userName');
                                                            if (userName !=
                                                                null) {
                                                              clearAllOrder(
                                                                  fireStore,
                                                                  userName);
                                                              uploadVoteState(
                                                                  fireStore,
                                                                  false,
                                                                  userName);
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
                                                                        '清除完成！',
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'Yuanti',
                                                                          fontSize:
                                                                              24,
                                                                          color: Color.fromRGBO(
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
                                                                    Duration(
                                                                        seconds:
                                                                            3),
                                                                onlyOne: true,
                                                                clickClose:
                                                                    true,
                                                                ignoreContentClick:
                                                                    true,
                                                              );
                                                            } else {
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
                                                                        '清除失敗,本地記憶體錯誤..',
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'Yuanti',
                                                                          fontSize:
                                                                              24,
                                                                          color: Color.fromRGBO(
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
                                                                    Duration(
                                                                        seconds:
                                                                            3),
                                                                onlyOne: true,
                                                                clickClose:
                                                                    true,
                                                                ignoreContentClick:
                                                                    true,
                                                              );
                                                            }
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ]).show(context);
                                      },
                                      child: Container(
                                        child: Center(
                                          child: Text(
                                            '結清所有訂單',
                                            style: TextStyle(
                                              fontFamily: 'Yuanti',
                                              color:
                                                  Color.fromRGBO(18, 18, 18, 1),
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  18,
                                            ),
                                          ),
                                        ),
                                        height:
                                            MediaQuery.of(context).size.height /
                                                18,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                            color: Colors.greenAccent),
                                      ),
                                    )),
                                  )
                                ],
                              ),
                            )
                          : objListTemp.length != 0 //合單頁
                              ? Expanded(
                                  flex: 65,
                                  child: Column(
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          child: ListView.builder(
                                            itemCount: objIntegrate.key.length,
                                            itemBuilder: (context, index) {
                                              List<Widget> widgetsNoteList = [];
                                              for (var note
                                                  in objIntegrate.note[index]) {
                                                widgetsNoteList.add(Container(
                                                    child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Visibility(
                                                      visible: note != '',
                                                      child: Icon(
                                                        Icons.forward,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Text(
                                                      note,
                                                      style: TextStyle(
                                                          fontFamily: 'Yuanti',
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              25,
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                )));
                                              }

                                              return IntrinsicHeight(
                                                child: Container(
                                                  child: Column(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  8,
                                                            ),
                                                            Text(
                                                              objIntegrate
                                                                  .count[index],
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'LilitaOne',
                                                                  fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      15,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  8,
                                                            ),
                                                            Text(
                                                              objIntegrate
                                                                  .key[index],
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Yuanti',
                                                                  fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      15,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  8,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          child: Column(
                                                            children:
                                                                widgetsNoteList,
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  color: Color.fromRGBO(
                                                      18, 18, 18, 1),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                18,
                                        child: Center(
                                          child: Text(
                                            '共 $integrateCount 品項 , $sumPrice 元',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Yuanti',
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  24,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : Expanded(flex: 65, child: Container())

                      //Staggered ListView
                    ], //BottomRow
                  ),
                );
              } else {
                return SpinKitThreeBounce(
                  color: Colors.white,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
