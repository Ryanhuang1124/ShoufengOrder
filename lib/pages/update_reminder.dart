import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class UpdateReminderPage extends StatefulWidget {
  final String localVersion;
  final String liveVersion;

  const UpdateReminderPage({Key key, this.localVersion, this.liveVersion})
      : super(key: key);
  @override
  _UpdateReminderPageState createState() => _UpdateReminderPageState();
}

class _UpdateReminderPageState extends State<UpdateReminderPage> {
  final fireStore = Firestore.instance;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: fireStore.collection('UpdateReminder').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            bool lock = false;
            List<Obj> objList = [];
            for (var doc in snapshot.data.documents) {
              if (doc.documentID == 'lock') {
                doc.data.forEach((k, v) {
                  lock = v;
                });
              }
              if (doc.documentID == 'data') {
                doc.data.forEach((k, v) {
                  Obj obj = new Obj();
                  obj.k = k;
                  obj.v = v;
                  objList.add(obj);
                });
              }
            }
            return SafeArea(
              child: Scaffold(
                backgroundColor: Color.fromRGBO(18, 18, 18, 1),
                body: Container(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            objList[0].k == 'title'
                                ? objList[0].v
                                : objList[1].v,
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Yuanti',
                                fontSize: 45),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 40,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Text(
                              objList[0].k == 'content'
                                  ? objList[0].v
                                  : objList[1].v,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Yuanti',
                                  fontSize: 24),
                            ),
                          ),
                        ],
                      ),
                      Expanded(flex: 2, child: SizedBox()),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          BouncingWidget(
                            onPressed: () {
                              if (lock) {
                                Navigator.of(context).pop();
                              } else {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, '/menulist');
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                color: Color.fromRGBO(29, 185, 84, 1),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  '好哦',
                                  style: TextStyle(
                                      color: Color.fromRGBO(18, 18, 18, 1),
                                      fontFamily: 'Yuanti',
                                      fontSize: 24),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 77,
                      ),
                      Container(
                        child: Column(
                          children: <Widget>[
                            Text(
                              '目前最新版本：${widget.liveVersion}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Yuanti',
                                  fontSize: 20),
                            ),
                            Text(
                              '你的版本：${widget.localVersion}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Yuanti',
                                  fontSize: 20),
                            ),
                          ],
                        ),
                        height: MediaQuery.of(context).size.height / 4,
                      )
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Scaffold(
              body: Center(
                child: SpinKitThreeBounce(
                  color: Colors.white,
                ),
              ),
            );
          }
        });
  }
}

class Obj {
  String k;
  String v;
}
