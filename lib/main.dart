import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shoufeng_order/pages/accounting_content.dart';
import 'package:shoufeng_order/pages/accounting_content_second.dart';
import 'package:shoufeng_order/pages/login_page.dart';
import 'package:shoufeng_order/pages/menu_list.dart';
import 'package:shoufeng_order/pages/menu_list_second.dart';
import 'package:shoufeng_order/pages/ordering_page.dart';
import 'package:shoufeng_order/pages/vote_content.dart';
import 'package:shoufeng_order/tools/firebase_messagin.dart';
import 'package:shoufeng_order/tools/login_builder.dart';
import 'package:shoufeng_order/pages/main_page.dart';
import 'package:flutter/services.dart';

void main() => runApp(RestartWidget(
      child: Shoufeng(),
    ));

class Shoufeng extends StatefulWidget {
  @override
  _ShoufengState createState() => _ShoufengState();
}

class _ShoufengState extends State<Shoufeng> {
  Future<bool> futureIsLogin;
  FirebaseMessaging _firebaseMessaging;
  @override
  void initState() {
    _firebaseMessaging = configureMessaging();
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
          return BotToastInit(
            child: MaterialApp(
              navigatorObservers: [BotToastNavigatorObserver()],
              initialRoute: '/',
              routes: {
                '/accounting2': (context) => AccountContent2(),
                '/menulist2': (context) => MenuList2(),
                '/loggin': (context) => LoginPage(),
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

class RestartWidget extends StatefulWidget {
  RestartWidget({this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>().restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
