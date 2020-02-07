import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_dialog/easy_dialog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shoufeng_order/tools/member_builder.dart';
import 'package:shoufeng_order/tools/vote_builder.dart';
import 'package:shoufeng_order/widgets/wave_widgets.dart';

class OrderingPage extends StatefulWidget {
  @override
  _OrderingPageState createState() => _OrderingPageState();
}

class _OrderingPageState extends State<OrderingPage>
    with TickerProviderStateMixin {
  AnimationController begin_controller, drag_controller, icon_controller;
  Animation begin_animation, drag_animation, icon_animation;
  int wavemax, wavemin;
  double bottle_move, value = 0;
  bool bottle_visible = false;

  bool moneyVisible = false;
  final fireStore = Firestore.instance;
  @override
  void initState() {
    super.initState();

    bottle_move = 0;
    wavemax = 200;
    wavemin = 0;
    begin_controller = AnimationController(
        duration: Duration(milliseconds: 1500), vsync: this);

    begin_animation =
        CurvedAnimation(parent: begin_controller, curve: Curves.easeInOutBack);
    begin_controller.forward();
    begin_controller.addListener(() {
      value = begin_controller.value;
      setState(() {});
    });

    drag_controller = AnimationController(
        duration: Duration(milliseconds: 1500), vsync: this);
    drag_animation =
        CurvedAnimation(parent: drag_controller, curve: Curves.easeInOutBack);

    icon_controller = AnimationController(
        duration: Duration(milliseconds: 1300), vsync: this);
    icon_animation =
        CurvedAnimation(parent: icon_controller, curve: Curves.easeInOutBack);

    icon_controller.forward();
    icon_controller.addStatusListener((status) {
      setState(() {});

      if (status == AnimationStatus.completed) {
        icon_controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        icon_controller.forward();
      }
    });
    icon_controller.addListener(() {
      bottle_move = icon_controller.value * 100;
      setState(() {});
    });
  }

  @override
  void dispose() {
    icon_controller.dispose();
    drag_controller.dispose();
    begin_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Container(
          //底層
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Color.fromRGBO(66, 147, 175, 1),
                Color.fromRGBO(51, 8, 103, 1),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Column(
            //上層
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Text(
                'ShouFeng',
                style: TextStyle(
                  fontFamily: 'Pacifico',
                  fontSize: 60,
                  color: Colors.white,
                ),
              ), //標題列
              Text(
                'Ordering System',
                style: TextStyle(
                  fontFamily: 'Courgette',
                  fontSize: 25,
                  color: Colors.white,
                ),
              ), //副標題
            ],
          ),
        ),
        //
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(
              height: 1,
              width: 1,
            ),
            Column(
              children: <Widget>[
                SizedBox(
                  height: bottle_move,
                ),
                FutureBuilder<bool>(
                  future: getBottleState(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data) {
                        bottle_visible = true;
                      }
                    } else {
                      bottle_visible = false;
                    }
                    return Hero(
                      tag: 'bottle_vote',
                      child: Visibility(
                        visible: bottle_visible,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/menulist');
                          },
                          child: Container(
                            child: Image.asset(
                              'images/message_in_a_bottle.png',
                              scale: 5,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        Visibility(
          visible: moneyVisible,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            child: Row(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: bottle_move / 3,
                    ),
                    GestureDetector(
                      onTap: () {
                        moneyVisible = false;
                        addCouponsCount(fireStore);
                        setState(() {});
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.only(left: 15.0)),
                                    Text(
                                      "恭喜！",
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
                                    '獲得一張5元折價券',
                                    style: TextStyle(
                                        fontFamily: 'Yuanti',
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                17.81,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  child: Text(
                                    '請到資料欄中查看',
                                    style: TextStyle(
                                        fontFamily: 'Yuanti',
                                        fontSize:
                                            MediaQuery.of(context).size.width /
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
                                                fontSize: MediaQuery.of(context)
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
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    23.05),
                                          ),
                                          onPressed: () {
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
                      child: Container(
                        child: Image.asset(
                          'images/coupon.png',
                          scale: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
        GestureDetector(
          //波浪animation
          onTap: () {},
          onHorizontalDragEnd: (DragEndDetails details) {},
          onVerticalDragEnd: (DragEndDetails detail) {
            wavemin = 200;
            wavemax = 600;
            drag_controller.forward();
            drag_controller.addStatusListener((status) {
              if (status == AnimationStatus.completed) {
                int _rng = Random().nextInt(200);
                _rng == 11 ? moneyVisible = true : moneyVisible = false;
                bottle_visible = true;
                drag_controller.reverse();
              }
            });
            drag_controller.addListener(
              () {
                setState(() {});
                value = drag_controller.value;
              },
            );
          },
          child: Container(
            child: buildWave(value, wavemin, wavemax),
          ),
        ),
      ],
    );
  }
}
