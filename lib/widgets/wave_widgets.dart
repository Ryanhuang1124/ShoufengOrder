import 'package:flutter/material.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

Widget buildWave(double value, int min, int max) {
  return WaveWidget(
    config: CustomConfig(
      gradients: [
        [Colors.red, Color(0xEEF44336)],
        [Colors.red[800], Color(0x77E57373)],
        [Colors.orange, Color(0x66FF9800)],
        [Colors.yellow, Color(0x55FFEB3B)]
      ],
      durations: [35000, 19440, 10800, 6000],
      heightPercentages: [0.2, 0.23, 0.25, 0.35],
      blur: MaskFilter.blur(BlurStyle.solid, 10),
      gradientBegin: Alignment.bottomCenter,
      gradientEnd: Alignment.topCenter,
    ),
    waveAmplitude: 0,
    backgroundColor: Color.fromRGBO(66, 147, 175, 0),
    size: Size(double.infinity, min + (value * max)),
  );
}
