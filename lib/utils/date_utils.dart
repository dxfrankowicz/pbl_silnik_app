import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyDateUtils{

  static String formatDateTime(BuildContext context, DateTime dateTime){
    final df = new DateFormat('d MMMM yyyy HH:mm', 'pl');
    return df.format(dateTime);
  }

  static String formatHour(BuildContext context, DateTime dateTime){
    final df = new DateFormat('HH:mm', 'pl');
    return df.format(dateTime);
  }

  static String formatDateYMD(BuildContext context, DateTime dateTime){
    final df = new DateFormat('d MMMM yyyy', 'pl');
    return df.format(dateTime);
  }

}