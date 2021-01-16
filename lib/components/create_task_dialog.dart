import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddTaskDialog {

  static Future showAddTaskDialog(BuildContext context) async {
    TextEditingController labNameController =
        TextEditingController(text: "Nowe ćwiczenie".toString());
    return await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(16.0),
            content: new Row(
              children: <Widget>[
                new Expanded(
                    child: TextFormField(
                  maxLines: 1,
                  textAlign: TextAlign.left,
                  autofocus: false,
                  decoration: InputDecoration(
                      labelText: "Podaj tytuł nowego ćwiczenia" ?? "",
                      border: OutlineInputBorder()),
                  controller: labNameController,
                ))
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  child: Row(
                    children: [
                      Icon(Icons.clear, color: Colors.red),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("Anuluj".toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .button
                                .copyWith(color: Colors.red)),
                      )
                    ],
                  ),
                  onPressed: () {
                    Navigator.pop(context, false);
                  }),
              new FlatButton(
                  child: Row(
                    children: [
                      Icon(Icons.add, color: Colors.black),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("Utwórz".toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .button
                                .copyWith(color: Colors.black)),
                      )
                    ],
                  ),
                  onPressed: labNameController.value.text != ""
                      ? () {
                          Navigator.pop(context, labNameController.value.text);
                        }
                      : null)
            ],
          );
        });
  }
}
