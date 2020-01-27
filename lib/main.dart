import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:shoufeng_order/pages/accounting_content.dart';
import 'package:shoufeng_order/pages/login_page.dart';
import 'package:shoufeng_order/pages/menu_list.dart';
import 'package:shoufeng_order/pages/ordering_page.dart';
import 'package:shoufeng_order/pages/vote_content.dart';
import 'package:shoufeng_order/tools/login_builder.dart';
import 'package:shoufeng_order/pages/main_page.dart';
import 'package:flutter/services.dart';

void main() => runApp(Shoufeng());

class Shoufeng extends StatefulWidget {
  @override
  _ShoufengState createState() => _ShoufengState();
}

class _ShoufengState extends State<Shoufeng> {
  Future<bool> futureIsLogin;
  @override
  void initState() {
    super.initState();
    futureIsLogin = getUserIsLogin();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return FutureBuilder(
      future: futureIsLogin,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          bool isLogin = snapshot.data;
          print('fromLogin :$isLogin');
          return BotToastInit(
            child: MaterialApp(
              navigatorObservers: [BotToastNavigatorObserver()],
              initialRoute: '/',
              routes: {
                '/main': (context) => MainPage(),
                '/vote': (context) => VoteContent(),
                '/accounting': (context) => AccountContent(),
                '/menulist': (context) => MenuList(),
                '/ordering': (context) => OrderingPage(),
              },
              home: isLogin ? MainPage() : LoginPage(),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
