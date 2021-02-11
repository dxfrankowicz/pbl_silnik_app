import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtils{

  static void showToast(String msg, {Color textColor, String bgColor}){
    Fluttertoast.showToast(
        msg: msg,
        fontSize: 100.0,
        textColor: textColor ?? Colors.black,
        webBgColor: bgColor ?? "#F5F5F5",
        webPosition: "center",
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2);
  }
}