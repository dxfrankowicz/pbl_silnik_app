import 'package:flutter/material.dart';
import 'package:silnik_app/api/models/stat_value.dart';

class StatCard extends StatelessWidget {
  final StatValue stat;
  final double value;

  const StatCard({this.stat, this.value, Key key}) : super(key: key);

  Widget statValue(BuildContext context, StatValue stat, double value) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: TextFormField(
                          controller: TextEditingController(
                              text: value == null
                                  ? "-"
                                  : "${value.toStringAsFixed(stat.precision)}"),
                          readOnly: true,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              suffix:
                                  Container(width: 40, child: Text(stat.unit)),
                              isDense: true,
                              prefix: Container(
                                  width: 40, child: Text(stat.symbol)),
                              labelText: stat.desc,
                              border: OutlineInputBorder()),
                          style: Theme.of(context).textTheme.subtitle1),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) => statValue(context, stat, value);
}
