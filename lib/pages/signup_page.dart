import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:beauty_textfield/beauty_textfield.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:progress_indicator_button/progress_button.dart';
import 'package:shoufeng_order/tools/menu_builder.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String inputPhoneNumber;

  String inputName;
  final fireStore = Firestore.instance;

  String splitInputName() {
    String name;
    if (inputName.length > 2) {
      List<String> temp = [];
      for (int i = 0; i < inputName.length; i++) {
        temp.add(inputName[i]);
      }
      name = temp[inputName.length - 2] + temp[inputName.length - 1];
    } else if (inputName.length <= 2) {
      name = inputName;
    }

    return name;
  }

  void signUpMember() async {
    await fireStore
        .collection('MemberData')
        .document('ID')
        .setData({splitInputName(): inputPhoneNumber}, merge: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: ListView(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 20,
                  ),
                  Container(
                    child: Center(
                      child: ColorizeAnimatedTextKit(
                        speed: Duration(milliseconds: 800),
                        totalRepeatCount: double.infinity,
                        onTap: () {},
                        text: ['Sign Up'],
                        textStyle:
                            TextStyle(fontSize: 70, fontFamily: 'Pacifico'),
                        colors: [
                          Colors.white,
                          Colors.blue,
                          Colors.red,
                          Colors.yellow,
                        ],
                        textAlign: TextAlign.start,
                        alignment: AlignmentDirectional.topStart,
                      ),
                    ),
                    width: MediaQuery.of(context).size.width,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      BeautyTextfield(
                        width: MediaQuery.of(context).size.width / 1.25,
                        height: MediaQuery.of(context).size.height / 13,
                        duration: Duration(milliseconds: 600),
                        inputType: TextInputType.text,
                        prefixIcon: Icon(
                          Icons.person,
                        ),
                        suffixIcon: Icon(Icons.highlight),
                        placeholder: "姓名",
                        fontFamily: 'Yuanti',
                        fontWeight: FontWeight.w200,
                        isShadow: true,
                        onTap: () {},
                        onChanged: (text) {
                          inputName = text;
                        },
                        onSubmitted: (data) {},
                        onClickSuffix: () {},
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 44,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      BeautyTextfield(
                        width: MediaQuery.of(context).size.width / 1.25,
                        height: MediaQuery.of(context).size.height / 13,
                        duration: Duration(milliseconds: 600),
                        inputType: TextInputType.text,
                        prefixIcon: Icon(
                          Icons.phone,
                        ),
                        suffixIcon: Icon(Icons.highlight),
                        placeholder: "電話號碼",
                        fontFamily: 'Yuanti',
                        fontWeight: FontWeight.w200,
                        isShadow: true,
                        onTap: () {},
                        onChanged: (text) {
                          inputPhoneNumber = text;
                        },
                        onSubmitted: (data) {},
                        onClickSuffix: () {},
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 10,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: MediaQuery.of(context).size.height / 13,
                    child: ProgressButton(
                      color: Color.fromRGBO(66, 39, 122, 1),
                      progressIndicatorColor: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                      strokeWidth: 10,
                      child: Text(
                        "Sign  Up",
                        style: TextStyle(
                          fontFamily: 'LilitaOne',
                          color: Colors.white,
                          fontSize: 30,
                        ),
                      ),
                      onPressed: (AnimationController controller) async {
                        controller.forward();
                        await Future.delayed(
                          Duration(milliseconds: 1500),
                        );
                        if (!isNumeric(inputPhoneNumber)) {
                          BotToast.showCustomText(
                            toastBuilder: (_) => Align(
                              alignment: Alignment(0, 0.8),
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    '只能輸入數字..',
                                    style: TextStyle(
                                      fontFamily: 'Yuanti',
                                      fontSize: 24,
                                      color: Color.fromRGBO(66, 39, 122, 1),
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
                          controller.reverse();
                        } else {
                          signUpMember();
                          await Future.delayed(
                            Duration(milliseconds: 1500),
                          );
                          BotToast.showCustomText(
                            toastBuilder: (_) => Align(
                              alignment: Alignment(0, 0.8),
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    '註冊成功',
                                    style: TextStyle(
                                      fontFamily: 'Yuanti',
                                      fontSize: 24,
                                      color: Color.fromRGBO(66, 39, 122, 1),
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
                          Navigator.pushReplacementNamed(context, '/loggin');
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 23,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 3,
                    height: MediaQuery.of(context).size.height / 13,
                    child: ProgressButton(
                      color: Color.fromRGBO(66, 39, 122, 1),
                      progressIndicatorColor: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                      strokeWidth: 10,
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontFamily: 'LilitaOne',
                          color: Colors.white,
                          fontSize: 30,
                        ),
                      ),
                      onPressed: (AnimationController controller) async {
                        controller.forward();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
