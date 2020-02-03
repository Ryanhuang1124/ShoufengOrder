import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:shoufeng_order/tools/vote_builder.dart';
import 'package:easy_dialog/easy_dialog.dart';
import 'package:shoufeng_order/tools/menu_builder.dart';
import 'package:shoufeng_order/widgets/glow_avatar.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;

class VoteContent extends StatefulWidget {
  @override
  _VoteContentState createState() => _VoteContentState();
}

class _VoteContentState extends State<VoteContent> {
  final fireStore = Firestore.instance;
  Future<List<String>> storeList;

  void voteMenuDialog() {
    slideDialog.showSlideDialog(
      context: context,
      backgroundColor: Color.fromRGBO(18, 18, 18, 1),
      transitionDuration: Duration(milliseconds: 700),
      child: Expanded(
        child: Container(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.dashboard,
                      color: Colors.red,
                      size: 30,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      '新增候選店鋪',
                      style: TextStyle(
                          fontFamily: 'Yuanti',
                          fontSize: 22,
                          color: Colors.white),
                    ),
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
                      uploadVoteStore(fireStore, data);
                    });
                    print('$data:accept');
                    Navigator.pop(context);
                  },
                  builder: (context, a, b) {
                    return Container(
                      height: 70,
                      child: Center(
                        child: Text(
                          'Drag  to  here',
                          style: TextStyle(
                              color: Color.fromRGBO(18, 18, 18, 1),
                              fontSize: 32,
                              fontFamily: 'LilitaOne'),
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(27, 180, 82, 0.75),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 30,
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
                              color: Color.fromRGBO(27, 180, 82, 1),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                        Radius.elliptical(10, 9)),
                                    color: Color.fromRGBO(27, 180, 82, 1)),
                                child: Center(
                                    child: Text(
                                  store,
                                  style: TextStyle(
                                      fontSize: 30, fontFamily: 'Yuanti'),
                                )),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                        Radius.elliptical(10, 9)),
                                    color: Color.fromRGBO(27, 180, 82, 1)),
                                child: Center(
                                    child: Text(
                                  store,
                                  style: TextStyle(
                                      fontSize: 26, fontFamily: 'Yuanti'),
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
                            child: LoadingBouncingGrid.square(
                          size: 10,
                          duration: Duration(milliseconds: 700),
                          backgroundColor: Color.fromRGBO(27, 180, 82, 1),
                        ));
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

  @override
  void initState() {
    super.initState();
    storeList = getStore(fireStore);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(18, 18, 18, 1),
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Voting',
                        style: TextStyle(
                          fontFamily: 'LilitaOne',
                          fontSize: 70,
                          color: Color.fromRGBO(29, 185, 84, 1),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Hero(
                        tag: 'bottle_vote',
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            child: Image.asset(
                              'images/message_in_a_bottle.png',
                              scale: 7,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 30,
              ),
              StreamBuilder<QuerySnapshot>(
                stream: fireStore.collection('Vote').snapshots(),
                builder: (context, snapshot) {
                  bool state = false;
                  String year = '', month = '', day = '', hour = '', min = '';
                  if (snapshot.hasData) {
                    for (var item in snapshot.data.documents) {
                      if (item.documentID == 'VoteTime') {
                        if (item.data != null) {
                          item.data.forEach((k, v) {
                            switch (k) {
                              case 'year':
                                year = v;
                                break;
                              case 'month':
                                month = v;
                                break;
                              case 'day':
                                day = v;
                                break;
                              case 'hour':
                                hour = v;
                                break;
                              case 'min':
                                min = v;
                            }
                          });
                        }
                      }
                      if (item.documentID == 'VoteState') {
                        if (item.data != null) {
                          item.data.forEach((k, v) {
                            state = v;
                          });
                        }
                      }
                    }

                    return Column(
                      children: <Widget>[
                        Text(
                          '$day  $month  $year ',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontFamily: 'LilitaOne'),
                        ),
                        Text(
                          '$hour : $min',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontFamily: 'LilitaOne'),
                        ),
                        state
                            ? Text(
                                '投票開始時間',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontFamily: 'Yuanti'),
                              )
                            : Text(
                                '上次投票時間',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontFamily: 'Yuanti'),
                              )
                      ],
                    );
                  } else {
                    return Container();
                  }
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 30,
              ),
              StreamBuilder<DocumentSnapshot>(
                stream: fireStore
                    .collection('Vote')
                    .document('VoteState')
                    .snapshots(),
                builder: (context, snapshot) {
                  bool isVoting = false;
                  if (snapshot.hasData) {
                    final voteState = snapshot.data.data;
                    if (voteState != null) {
                      voteState.forEach((k, v) {
                        if (v != null) {
                          isVoting = v;
                        }
                      });
                    }
                    return Container(
                      child: isVoting
                          ? Text(
                              '投票進行中',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 30,
                                  fontFamily: 'Yuanti'),
                            )
                          : Column(
                              children: <Widget>[
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 10,
                                ),
                                GestureDetector(
                                  child: buttonGlowAvatar(context),
                                  onTap: () {
                                    EasyDialog(
                                        cardColor:
                                            Color.fromRGBO(18, 18, 18, 1),
                                        cornerRadius: 15.0,
                                        fogOpacity: 0.1,
                                        width: 250,
                                        height: 190,
                                        contentPadding: EdgeInsets.only(
                                            top:
                                                12.0), // Needed for the button design
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
                                                      fontSize: 17),
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
                                              child: Padding(
                                                padding: EdgeInsets.all(15),
                                                child: Text(
                                                  '確定開始新一輪投票？',
                                                  style: TextStyle(
                                                      fontFamily: 'Yuanti',
                                                      fontSize: 22,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Colors.greenAccent,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          bottomRight:
                                                              Radius.circular(
                                                                  10.0),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10),
                                                        )),
                                                    child: FlatButton(
                                                      child: Text(
                                                        "OK",
                                                        textScaleFactor: 1.6,
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'LilitaOne',
                                                            fontSize: 17),
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          uploadVoteState(
                                                              fireStore,
                                                              true,
                                                              'Ryan');
                                                          uploadVoteTime(
                                                              fireStore);
                                                          clearStoreSelect(
                                                              fireStore);
                                                          clearVoteStore(
                                                              fireStore);

                                                          Navigator.pop(
                                                              context);
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]).show(context);
                                  },
                                )
                              ],
                            ),
                    );
                  } else {
                    return LoadingBouncingGrid.square(
                      size: 100,
                      duration: Duration(milliseconds: 700),
                      backgroundColor: Color.fromRGBO(29, 185, 84, 1),
                    );
                  }
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 30,
              ),
              StreamBuilder<QuerySnapshot>(
                stream: fireStore.collection('Vote').snapshots(),
                builder: (context, snapshot) {
                  int count = 0;
                  bool isShow = false;
                  bool voteState = false;
                  if (snapshot.hasData) {
                    for (var doc in snapshot.data.documents) {
                      if (doc.documentID == 'VoteState') {
                        if (doc.data != null) {
                          doc.data.forEach((k, v) {
                            voteState = v;
                          });
                        }
                      }
                      if (doc.documentID == 'VoteStore') {
                        if (doc.data != null) {
                          doc.data.forEach((k, v) {
                            if (k != null) {
                              count++;
                            }
                          });
                        }
                      }
                    }
                    if (count < 3 && voteState == true) {
                      isShow = true;
                    } else {
                      isShow = false;
                    }
                    return Visibility(
                      visible: isShow,
                      child: BouncingWidget(
                        onPressed: () {
                          voteMenuDialog();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: Color.fromRGBO(29, 185, 84, 1),
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.elliptical(90, 90)),
                          ),
                          child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Icon(
                                Icons.add,
                                color: Color.fromRGBO(29, 185, 84, 1),
                              )),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 100,
              ),
              StreamBuilder<QuerySnapshot>(
                stream: fireStore.collection('Vote').snapshots(),
                builder: (context, snapshot) {
                  bool isShow = false;
                  String pickName = '';
                  List<VoteStore> storesPicked = [];
                  List<Widget> storesBuilder = [];
                  if (snapshot.hasData) {
                    for (var item in snapshot.data.documents) {
                      if (item.documentID == 'VoteStore') {
                        if (item.data != null) {
                          item.data.forEach((k, v) {
                            if (k != null) {
                              storesPicked.add(new VoteStore(k));
                            }
                          });
                        }
                      }
                      if (item.documentID == 'storeSelect') {
                        if (item.data != null) {
                          item.data.forEach((k, v) {
                            if (k == 'Ryan') {
                              pickName = v;
                            }
                            for (var obj in storesPicked) {
                              if (v == obj.storeName) {
                                obj.count++;
                              }
                            }
                          });
                        }
                      }
                      if (item.documentID == 'VoteState') {
                        if (item.data != null) {
                          item.data.forEach((k, v) {
                            isShow = v;
                          });
                        }
                      }
                    }
                    for (var obj in storesPicked) {
                      storesBuilder.add(
                        Visibility(
                          visible: isShow,
                          child: Expanded(
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        pickName = obj.storeName;
                                      });
                                      uploadStoreSelect(
                                          fireStore, 'Ryan', obj.storeName);
                                    },
                                    child: obj.storeName == pickName
                                        ? Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                4,
                                            //被選中
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 5,
                                                color: Color.fromRGBO(
                                                    29, 185, 84, 1),
                                              ),
                                              borderRadius: BorderRadius.all(
                                                  Radius.elliptical(5, 5)),
                                              color: Color.fromRGBO(
                                                  29, 185, 84, 1),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Center(
                                                child: Text(
                                                  obj.storeName,
                                                  style: TextStyle(
                                                    fontFamily: 'Yuanti',
                                                    fontSize: 30,
                                                    color: Color.fromRGBO(
                                                        18, 18, 18, 1),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            //沒選中
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                4,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 5,
                                                color: Color.fromRGBO(
                                                    29, 185, 84, 1),
                                              ),
                                              borderRadius: BorderRadius.all(
                                                Radius.elliptical(5, 5),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Center(
                                                child: Text(
                                                  obj.storeName,
                                                  style: TextStyle(
                                                    fontFamily: 'Yuanti',
                                                    fontSize: 30,
                                                    color: Color.fromRGBO(
                                                        29, 185, 84, 1),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 15,
                                ),
                                Container(
                                  child: Text(
                                    obj.count.toString(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 75,
                                        fontFamily: 'LilitaOne'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return Row(
                      children: storesBuilder,
                    );
                  } else {
                    return LoadingBouncingGrid.square(
                      size: 100,
                      duration: Duration(milliseconds: 700),
                      backgroundColor: Color.fromRGBO(29, 185, 84, 1),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
