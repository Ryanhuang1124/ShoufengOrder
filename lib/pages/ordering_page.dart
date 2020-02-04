import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shoufeng_order/tools/member_builder.dart';
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
