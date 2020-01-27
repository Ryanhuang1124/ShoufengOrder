import 'package:flutter/material.dart';
import 'package:shoufeng_order/widgets/glow_avatar.dart';
import 'package:shoufeng_order/widgets/barchart.dart';

class MemberPage extends StatefulWidget {
  @override
  _MemberPageState createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
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
            children: <Widget>[
              SizedBox(
                height: 40,
              ),
              Expanded(
                child: Container(
                  //夾層
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 5.0,
                      ),
                    ],
                    color: Colors.white70,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.elliptical(35, 25),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      //上層
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: <Widget>[
                            SizedBox(
                              width: 20,
                            ),
                            buildGlowAvatar(),
                            Expanded(
                              child: SizedBox(),
                            ),
                            IconButton(
                              onPressed: () {
                                print('menu pressed!');
                              },
                              color: Color.fromRGBO(49, 27, 146, 1),
                              icon: Icon(Icons.assignment),
                              iconSize: 40,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            IconButton(
                              onPressed: () {
                                print('setting pressed!');
                              },
                              color: Color.fromRGBO(49, 27, 146, 1),
                              icon: Icon(Icons.settings),
                              iconSize: 40,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: <Widget>[
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              "How's your day  ,  ",
                              style: TextStyle(
                                fontFamily: 'LilitaOne',
                                fontSize: 30,
                                color: Color.fromRGBO(49, 27, 146, 1),
                              ),
                            ),
                            Visibility(
                              visible: true,
                              child: GestureDetector(
                                onTap: () {
                                  print('name taped');
                                },
                                child: Container(
                                  width: 130,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(0, 0, 81, 1),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Image.asset(
                                        'images/firefighter_icon.png',
                                        scale: 1.3,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        '冠翔',
                                        style: TextStyle(
                                          fontFamily: 'Yuanti',
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: <Widget>[
                            SizedBox(
                              width: 20,
                            ),
                            IconButton(
                              iconSize: 35,
                              icon: Icon(Icons.equalizer),
                            ),
                            Text(
                              'Statistics',
                              style: TextStyle(
                                fontFamily: 'LilitaOne',
                                fontSize: 30,
                                color: Color.fromRGBO(49, 27, 146, 1),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Container(
                            child: BarChartSample1(),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
