import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';

Widget buildGlowAvatar() {
  return AvatarGlow(
    glowColor: Colors.red,
    duration: Duration(milliseconds: 1500),
    endRadius: 70.0,
    child: Material(
      elevation: 10.0,
      shape: CircleBorder(),
      child: CircleAvatar(
        backgroundColor: Colors.yellow,
        child: Image.asset('images/account_icon.png'),
        radius: 40,
      ),
    ),
  );
}

Widget buttonGlowAvatar(context) {
  return AvatarGlow(
    glowColor: Color.fromRGBO(27, 180, 82, 1),
    duration: Duration(milliseconds: 2000),
    repeatPauseDuration: Duration(milliseconds: 20),
    endRadius: MediaQuery.of(context).size.width / 3.5,
    child: Material(
      elevation: 10.0,
      shape: CircleBorder(),
      child: CircleAvatar(
        backgroundColor: Color.fromRGBO(27, 180, 82, 1),
        child: Text(
          'Vote',
          style: TextStyle(
              fontFamily: 'LilitaOne',
              fontSize: MediaQuery.of(context).size.width / 8.5,
              color: Colors.black),
        ),
        radius: MediaQuery.of(context).size.width / 8,
      ),
    ),
  );
}
