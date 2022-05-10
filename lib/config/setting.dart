import 'package:flutter/material.dart';

class Setting {
  static const MaterialColor themeColor = MaterialColor(
    0xffb4101b,
    <int, Color>{
      50: Color(0xffb4101b),
      100: Color(0xffb4101b),
      200: Color(0xffb4101b),
      300: Color(0xffb4101b),
      400: Color(0xffb4101b),
      500: Color(0xffb4101b),
      600: Color(0xffb4101b),
      700: Color(0xffb4101b),
      800: Color(0xffb4101b),
      900: Color(0xffb4101b),
    },
  );
}

// ignore: camel_case_types
class isLoading extends StatelessWidget {
  const isLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Setting.themeColor)));
  }
}
