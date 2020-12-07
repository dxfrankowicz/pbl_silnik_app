import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExpandableCard extends StatelessWidget{
  final String title;
  final Widget child;

  ExpandableCard({this.title, this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: ExpansionTile(
              title: Text(title, textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline6),
              children: [
                child
              ],
            )
          ),
        )
      ],
    );
  }
}