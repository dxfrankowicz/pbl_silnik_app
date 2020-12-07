import 'package:flutter/material.dart';

class DialogUtils{
  static void showYesNoDialog(BuildContext context, String msg,
      {VoidCallback noFunction, VoidCallback yesFunction}) async {
    TextTheme textTheme = Theme.of(context).textTheme;
    await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(16.0),
            content: new Row(
              children: <Widget>[
                new Expanded(child: Text(msg))
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  child: Row(
                    children: [
                      Icon(Icons.clear, color: Colors.red),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("Nie".toUpperCase(),
                            style: textTheme.button.copyWith(color: Colors.red)),
                      )
                    ],
                  ),
                  onPressed: () {
                    Navigator.pop(context, false);
                  }),
              new FlatButton(
                  child: Row(
                    children: [
                      Icon(Icons.check, color: Colors.black),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("Tak".toUpperCase(), style: textTheme.button.copyWith(color: Colors.black)),
                      )
                    ],
                  ),
                  onPressed: () {
                    Navigator.pop(context, true);
                  })
            ],
          );
        }).then((value){
          if(value!=null && value){
            yesFunction();
          }
          else{
            noFunction();
          }
    });
  }
}