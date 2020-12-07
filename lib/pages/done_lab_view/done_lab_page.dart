import 'package:flutter/material.dart';
import 'package:silnik_app/api/models/lab.dart';
import '../../lists.dart';
import 'done_lab_view.dart';

class DoneLabPage extends StatelessWidget{
  final int id;

  DoneLabPage(this.id);

  Widget getLabsPage(int id) {
    for (Lab lab in Lists.labs) {
      if (lab.id == id) {
        return DoneLabView(lab);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return getLabsPage(id);
  }
}