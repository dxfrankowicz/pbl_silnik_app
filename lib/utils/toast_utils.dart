import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtils{

  static void showToast(String msg){
    Fluttertoast.showToast(
        msg: msg,
        fontSize: 100.0,
        textColor: Colors.black,
        webBgColor: "#F5F5F5",
        webPosition: "center",
        gravity: ToastGravity.CENTER,

        timeInSecForIosWeb: 2);
  }
}