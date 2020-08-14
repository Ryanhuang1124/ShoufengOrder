import 'package:flutter/material.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:shoufeng_order/pages/accounting_page.dart';

import 'package:shoufeng_order/pages/member_page.dart';

import 'package:shoufeng_order/pages/ordering_page.dart';
import 'package:shoufeng_order/pages/vote_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  //版本號碼
  static String version = '1.0.5';
  int currentPage = 0;
  final pages = [
    VotePage(),
    OrderingPage(
      version: version,
    ),
    AccountPage(),
    MemberPage(
      version: version,
    )
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: FancyBottomNavigation(
        tabs: [
          TabData(iconData: Icons.star, title: '投票'),
          TabData(iconData: Icons.library_books, title: '點餐'),
          TabData(iconData: Icons.local_grocery_store, title: '結算'),
          TabData(iconData: Icons.assignment_ind, title: '設定'),
        ],
        onTabChangedListener: (position) {
          setState(
            () {
              currentPage = position;
            },
          );
        },
      ),
      body: pages[currentPage],
    );
  }
}
