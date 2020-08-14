import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_dialog/easy_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shoufeng_order/pages/edit_store.dart';

class EditMenuPage extends StatefulWidget {
  @override
  _EditMenuPageState createState() => _EditMenuPageState();
}

class _EditMenuPageState extends State<EditMenuPage> {
  final fireStore = Firestore.instance;

  void deleteStore(String storeName) async {
    fireStore.collection(storeName).getDocuments().then((snapshot) {
      for (DocumentSnapshot doc in snapshot.documents) {
        doc.reference.delete();
      }
    });
    await FirebaseStorage.instance.ref().child(storeName).delete();
    fireStore
        .collection('StoreList')
        .document('Stores')
        .updateData({storeName: FieldValue.delete()}).whenComplete(() {
      BotToast.showCustomText(
        toastBuilder: (_) => Align(
          alignment: Alignment(0, 0.8),
          child: Card(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '刪除成功！',
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
          stream:
              fireStore.collection('StoreList').document('Stores').snapshots(),
          builder: (context, snapshot) {
            List<Widget> stores = [];
            if (snapshot.hasData) {
              snapshot.data.data.forEach((k, v) {
                stores.add(new Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 4,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditStorePage(
                                          storeName: k,
                                          phoneNumber: v,
                                        )));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.elliptical(10, 9)),
                                color: Color.fromRGBO(27, 180, 82, 1)),
                            child: Center(
                                child: Text(
                              k,
                              style:
                                  TextStyle(fontSize: 30, fontFamily: 'Yuanti'),
                            )),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 20.0, left: 8.0, bottom: 20.0),
                          child: GestureDetector(
                            onTap: () {
                              EasyDialog(
                                  closeButton: false,
                                  cardColor: Color.fromRGBO(18, 18, 18, 1),
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
                                              padding:
                                                  EdgeInsets.only(left: 15.0)),
                                          Text(
                                            "確定要刪除",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Yuanti',
                                                fontSize: 17),
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
                                        child: Padding(
                                          padding: EdgeInsets.all(15),
                                          child: Text(
                                            '$k ?',
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
                                            width: 2,
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
                                                      fontSize: 17),
                                                ),
                                                onPressed: () {
                                                  deleteStore(k);
                                                  setState(() {
                                                    Navigator.pop(context);
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
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(27, 180, 82, 1),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Center(
                                child: Icon(
                                  Icons.delete_forever,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ));
              });
              return Container(
                color: Color.fromRGBO(18, 18, 18, 1),
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
                      Center(
                        child: Text(
                          'Store  List',
                          style: TextStyle(
                            fontFamily: 'LilitaOne',
                            fontSize: 60,
                            color: Color.fromRGBO(29, 185, 84, 1),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/newstore');
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.elliptical(10, 9)),
                                  color: Color.fromRGBO(27, 180, 82, 1)),
                              child: Center(
                                  child: Text(
                                '新增店家',
                                style: TextStyle(
                                    fontSize: 30, fontFamily: 'Yuanti'),
                              )),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 100,
                      ),
                      Expanded(
                        child: Container(
                          child: GridView.count(
                            shrinkWrap: true,
                            childAspectRatio: 2,
                            crossAxisCount: 2,
                            children: stores,
                          ),
                        ),
                      ),
                    ],
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
          }),
    );
  }
}
