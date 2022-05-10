import 'package:firebase_notify_demo/config/setting.dart';
import 'package:firebase_notify_demo/widgets/widget.dart';
import 'package:flutter/material.dart';

class UIHelper {

  static void showLoadingDialog(context, String title){
    AlertDialog loadingDialog = AlertDialog(
      backgroundColor: Colors.transparent,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Setting.themeColor)),
          const SizedBox(height: 6),
          Text(title, style: simpleTextStyle()),
        ],
      ),
    );
    showDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel: 'vjp',
        builder: (context) {
          return loadingDialog;
        }
    );
  }

  static void showAlertDialog(context, String title, String content){
    AlertDialog alertDialog = AlertDialog(
      backgroundColor: Colors.black,
      titleTextStyle: simpleTextStyle(),
      contentTextStyle: simpleTextStyle(),
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Got it'),
        ),
      ],
    );

    showDialog(context: context, builder: (context)
    {
      return alertDialog;
    });
  }
}