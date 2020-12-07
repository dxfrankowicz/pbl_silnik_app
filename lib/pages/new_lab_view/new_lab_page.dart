import 'package:flutter/material.dart';
import 'package:silnik_app/api/models/lab.dart';
import '../../lists.dart';
import 'new_lab_view.dart';

class MainLabPage extends StatelessWidget{
  final int id;

  MainLabPage(this.id);

  Widget getLabsPage(int id) {
    for (Lab lab in Lists.labs) {
      if (lab.id == id) {
        return MainLabView(lab);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return getLabsPage(id);
  }
}