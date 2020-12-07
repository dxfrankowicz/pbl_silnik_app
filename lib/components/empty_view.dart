import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget{
  final String message;

  EmptyView({this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Icon(Icons.assignment_late_outlined, size: 50),
            SizedBox(height: 8),
            Text(message ?? "Brak danych")
          ],
        ),
      ),
    );
  }
}