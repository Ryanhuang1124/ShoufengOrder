import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_dialog/easy_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shoufeng_order/tools/login_builder.dart';
import 'package:shoufeng_order/tools/member_builder.dart';
import 'package:shoufeng_order/tools/vote_builder.dart';
import 'package:xlive_switch/xlive_switch.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import '../main.dart';

class MemberPage extends StatefulWidget {
  final String version;

  const MemberPage({Key key, this.version}) : super(key: key);
  @override
  _MemberPageState createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  String userName;
  final TextEditingController adviceController = TextEditingController();
  String content = '';

  @override
  void initState() {
    super.initState();
  }

  void _changeValue(bool value) {
    setState(() {});
    setBottleState(value);
  }

  void _changeWave(bool value) {
    setState(() {});
    setWaveState(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 18, 18, 1),
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height / 20,
              ),
              Text(
                'Settings',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'LilitaOne',
                    fontSize: MediaQuery.of(context).size.width / 7),
              ),
              Row(
                children: <Widget>[
                  FutureBuilder<String>(
                    future: getUserName(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        userName = snapshot.data;
                        return Expanded(
                          flex: 1,
                          child: Container(
                            child: TextLiquidFill(
                              boxWidth: MediaQuery.of(context).size.width / 2,
                              boxHeight: MediaQuery.of(context).size.height / 4,
                              text: snapshot.data,
                              waveColor: Color.fromRGBO(29, 185, 54, 1),
                              boxBackgroundColor: Color.fromRGBO(18, 18, 18, 1),
                              textStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Yuanti',
                                fontSize: MediaQuery.of(context).size.width / 6,
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                  Expanded(
                    flex: 1,
                    child: Transform.translate(
                      offset: Offset(MediaQuery.of(context).size.width / 6,
                          MediaQuery.of(context).size.height / 13),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 15,
                        child: Row(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                BotToast.showCustomText(
                                  toastBuilder: (_) => Align(
                                    alignment: Alignment(0, 0.8),
                                    child: Card(
                                      child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 8),
                                        child: Text(
                                          '我把折價券都藏在那裡了..去找吧!',
                                          style: TextStyle(
                                            fontFamily: 'Yuanti',
                                            fontSize: 24,
                                            color:
                                                Color.fromRGBO(18, 18, 18, 1),
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
                              child: Container(
                                child: Image.asset(
                                  'images/coupon.png',
                                  scale: 0.8,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 50,
                            ),
                            Container(
                                child: Icon(
                              Icons.clear,
                              color: Colors.white,
                            )),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 50,
                            ),
                            StreamBuilder<QuerySnapshot>(
                              stream: Firestore.instance
                                  .collection('Coupons')
                                  .snapshots(),
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
                                return Container(
                                  child: Text(
                                    couponsCount.toString(),
                                    style: TextStyle(
                                        fontFamily: 'LilitaOne',
                                        color: Colors.white,
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                9),
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView(children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 25,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 15,
                    child: Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Container(
                              child: Image.asset(
                                'images/message_in_a_bottle.png',
                                scale: 12,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 20,
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              child: Text(
                                '永遠顯示瓶中信',
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width / 14,
                                    fontFamily: 'Yuanti',
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: FutureBuilder<bool>(
                              future: getBottleState(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Container(
                                    child: XlivSwitch(
                                      value: snapshot.data,
                                      onChanged: _changeValue,
                                    ),
                                  );
                                } else {
                                  return Container(
                                    child: XlivSwitch(
                                      value: false,
                                      onChanged: _changeValue,
                                    ),
                                  );
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 25,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 15,
                    child: Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Container(
                              child: Image.asset(
                                'images/wave.png',
                                scale: 12,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 20,
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              child: Text(
                                '顯示波浪動畫',
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width / 14,
                                    fontFamily: 'Yuanti',
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: FutureBuilder<bool>(
                              future: getWaveState(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Container(
                                    child: XlivSwitch(
                                      value: snapshot.data,
                                      onChanged: _changeWave,
                                    ),
                                  );
                                } else {
                                  return Container(
                                    child: XlivSwitch(
                                      value: true,
                                      onChanged: _changeWave,
                                    ),
                                  );
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 25,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 15,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/editmenu');
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Container(
                                child: Image.asset(
                                  'images/document.png',
                                  scale: 12,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 20,
                            ),
                            Expanded(
                              flex: 5,
                              child: Container(
                                child: Text(
                                  '編輯菜單',
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              14,
                                      fontFamily: 'Yuanti',
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            Expanded(flex: 2, child: SizedBox()),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 25,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 15,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
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
                                      '確定要登出嗎？',
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
                                              setUserCache(false, '');
                                              RestartWidget.restartApp(context);
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]).show(context);
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Container(
                                child: Image.asset(
                                  'images/log_out.png',
                                  scale: 12,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 20,
                            ),
                            Expanded(
                              flex: 5,
                              child: Container(
                                child: Text(
                                  '登 出',
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              14,
                                      fontFamily: 'Yuanti',
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            Expanded(flex: 2, child: SizedBox()),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: SizedBox(),
                      ),
                      Container(
                        child: Text(
                          widget.version,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  )
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
