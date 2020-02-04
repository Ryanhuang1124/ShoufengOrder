import 'package:bot_toast/bot_toast.dart';
import 'package:easy_dialog/easy_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoufeng_order/tools/member_builder.dart';
import 'package:xlive_switch/xlive_switch.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class MemberPage extends StatefulWidget {
  @override
  _MemberPageState createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  Future<bool> _value;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _changeValue(bool value) {
    setState(() {});
    setBottleState(value);
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
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 13,
                  child: TypewriterAnimatedTextKit(
                    totalRepeatCount: 1,
                    speed: Duration(milliseconds: 300),
                    isRepeatingAnimation: true,
                    text: ["How's your day?"],
                    textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width / 8,
                        fontFamily: 'LilitaOne'),
                    textAlign: TextAlign.start,
                  )),
              Row(
                children: <Widget>[
                  FutureBuilder<String>(
                    future: getUserName(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
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
                  Expanded(flex: 1, child: SizedBox()),
                ],
              ),
              Center(
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
                              fontSize: MediaQuery.of(context).size.width / 14,
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
              SizedBox(
                height: MediaQuery.of(context).size.height / 17,
              ),
              Center(
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
                          '給冠翔開發建議',
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width / 14,
                              fontFamily: 'Yuanti',
                              color: Colors.white),
                        ),
                      ),
                    ),
                    Expanded(flex: 2, child: SizedBox()),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 17,
              ),
              Center(
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Padding(padding: EdgeInsets.only(left: 15.0)),
                                Text(
                                  "提醒",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Yuanti',
                                      fontSize:
                                          MediaQuery.of(context).size.width /
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
                                          bottomRight: Radius.circular(10.0),
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
                                        setState(() {});

                                        Navigator.pushReplacementNamed(
                                            context, '/loggin');
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
                                    MediaQuery.of(context).size.width / 14,
                                fontFamily: 'Yuanti',
                                color: Colors.white),
                          ),
                        ),
                      ),
                      Expanded(flex: 2, child: SizedBox()),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
