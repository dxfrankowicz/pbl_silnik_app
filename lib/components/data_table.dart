import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:silnik_app/api/models/idle_reading.dart';
import 'package:silnik_app/api/models/load_reading.dart';
import 'package:silnik_app/api/models/reading.dart';
import '../lists.dart';

// ignore: must_be_immutable
class CustomPaginatedTable extends StatefulWidget {
  List<IdleReading> idleReadings;
  List<LoadReading> loadReadings;
  final bool isIdleSelected;

  static List<int> idleReadingItemSelected = [];
  static List<int> loadReadingItemSelected = [];

  CustomPaginatedTable(
      {this.idleReadings, this.loadReadings, this.isIdleSelected = true});

  @override
  _CustomPaginatedTableState createState() => _CustomPaginatedTableState();
}

class _CustomPaginatedTableState extends State<CustomPaginatedTable> {
  DTS dts;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int selectedItems = 0;

  @override
  Widget build(BuildContext context) {
    Random r = new Random();
    dts = DTS(widget.isIdleSelected ? widget.idleReadings : widget.loadReadings,
        callback: (int i) {
      print("Selected items: $i");
      setState(() {
        selectedItems = i;
      });
    });
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: PaginatedDataTable(
              showCheckboxColumn: false,
              columns: widget.isIdleSelected
                  ? Lists.statsList
                      .where((x) => !x.loadEngineStateReading)
                      .map((e) {
                      return DataColumn(
                          label:
                              Center(child: Text("${e.symbol} [${e.unit}]")));
                    }).toList()
                  : Lists.statsList.map((e) {
                      return DataColumn(
                          label:
                              Center(child: Text("${e.symbol} [${e.unit}]")));
                    }).toList(),
              source: dts,
              onSelectAll: dts._selectAll,
              rowsPerPage: _rowsPerPage,
              onRowsPerPageChanged: (r) {
                setState(() {
                  _rowsPerPage = r;
                });
              },
              header:
              // selectedItems > 0
              //     ? Container(
              //         margin: EdgeInsets.only(top: 8),
              //         child: Row(
              //           children: [
              //             Expanded(
              //               child: FlatButton(
              //                 onPressed: () {
              //                   setState(() {
              //                     if (widget.isIdleSelected) {
              //                       CustomPaginatedTable.idleReadingItemSelected
              //                           .forEach((i) {
              //                         // ApiClient()
              //                         //     .deleteReading(
              //                         //         id: i,
              //                         //         chosenTask: widget.idleReadings
              //                         //             .first.task,
              //                         //         engineState: EngineState.idle)
              //                         //     .then((value) {
              //                         //   //widget.idleReadings = value.idleReadings;
              //                         // });
              //                       });
              //                       setState(() {
              //                         dts.list = widget.idleReadings;
              //                       });
              //                       CustomPaginatedTable.idleReadingItemSelected
              //                           .clear();
              //                     } else {
              //                       CustomPaginatedTable.loadReadingItemSelected
              //                           .forEach((i) {
              //                         // ApiClient()
              //                         //     .deleteReading(
              //                         //         id: i,
              //                         //         chosenTask: widget.loadReadings.first.task,
              //                         //         engineState: EngineState.load)
              //                         //     .then((value) {
              //                         //   //widget.loadReadings = value.loadReadings;
              //                         // });
              //                       });
              //                       setState(() {
              //                         dts.list = widget.loadReadings;
              //                       });
              //                       CustomPaginatedTable.loadReadingItemSelected
              //                           .clear();
              //                     }
              //                     dts._selectAll(false);
              //                   });
              //                 },
              //                 child: Padding(
              //                   padding: const EdgeInsets.all(8.0),
              //                   child: Text("Usuń zaznaczone",
              //                       style: Theme.of(context)
              //                           .textTheme
              //                           .bodyText1
              //                           .copyWith(color: Colors.red)),
              //                 ),
              //                 shape: RoundedRectangleBorder(
              //                     borderRadius: BorderRadius.circular(8.0),
              //                     side: BorderSide(color: Colors.red)),
              //               ),
              //             )
              //           ],
              //         ),
              //       )
              //     :
              null,
            ))
          ],
        ),
      ],
    );
  }
}

class DTS extends DataTableSource {
  List list;
  MyCallback callback;
  IdleReadingSelectedIndexes idleReadingSelectedIndexes;
  LoadReadingSelectedIndexes loadReadingSelectedIndexes;

  List<int> idleReadingSelectedIndexesList = new List();
  List<int> loadReadingSelectedIndexesList = new List();

  DTS(this.list,
      {this.callback,
      this.idleReadingSelectedIndexes,
      this.loadReadingSelectedIndexes});

  void addSelectedIndexes(int id, {bool remove = false}) {
    if (list is List<LoadReading>) {
      if (remove)
        CustomPaginatedTable.loadReadingItemSelected.remove(id);
      else
        CustomPaginatedTable.loadReadingItemSelected.add(id);
    } else {
      if (remove)
        CustomPaginatedTable.idleReadingItemSelected.remove(id);
      else
        CustomPaginatedTable.idleReadingItemSelected.add(id);
    }
  }

  @override
  DataRow getRow(int index) {
    if (index < list.length) {
      assert(index >= 0);
      if (index >= list.length) return null;
      final dynamic x = list[index];
      return DataRow(
        key:
            Key("row-${list[index].id * Random().nextInt(pow(2, 32))}"),
        // selected: x.selected,
        // onSelectChanged: (bool value) {
        //   if (x.selected != value) {
        //     x.selected = !x.selected;
        //     _selectedCount = list.where((z) => z.selected).length;
        //     callback(selectedRowCount);
        //     print("SELECTED ROW: ${x.toString()}");
        //     addSelectedIndexes(x.id, remove: !x.selected);
        //     notifyListeners();
        //   }
        // },
        cells: [
          DataCell(
              Text(list[index]?.voltage?.toStringAsFixed(3) ?? "-")),
          DataCell(Text(
              list[index]?.powerFrequency?.toStringAsFixed(3) ?? "-")),
          DataCell(
              Text(list[index]?.power?.toStringAsFixed(3) ?? "-")),
          DataCell(Text(
              list[index]?.rotationalSpeed?.toStringAsFixed(3) ?? "-")),
          DataCell(Text(
              list[index]?.statorCurrent?.toStringAsFixed(3) ?? "-")),
          DataCell(Text(
              list[index]?.rotorCurrent?.toStringAsFixed(3) ?? "-")),
          DataCell(Text(
              list[index]?.apparentPower?.toStringAsFixed(3) ?? "-")),
          DataCell(Text(
              list[index]?.activePower?.toStringAsFixed(3) ?? "-")),
          if (list is List<LoadReading>)
            DataCell(Text(list[index]?.ballastMoment?.toStringAsFixed(3) ?? "-"))
        ],
      );
    } else
      return DataRow(
          key: Key(Random().nextInt(double.maxFinite.toInt()).toString()),
          cells: [
            DataCell(Container()),
            DataCell(Container()),
            DataCell(Container()),
            DataCell(Container()),
            DataCell(Container()),
            DataCell(Container()),
            DataCell(Container()),
            DataCell(Container()),
            if (list is List<LoadReading>) DataCell(Container())
          ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => list.length;

  @override
  int get selectedRowCount => _selectedCount;

  void _selectAll(bool checked) {
    for (dynamic x in list) {
      //x.selected = checked;
      addSelectedIndexes(x.id, remove: !x.selected);
    }
    _selectedCount = list.where((x) => x.selected).length;
    callback(selectedRowCount);
    notifyListeners();
  }

  int _selectedCount = 0;
}

typedef void MyCallback(int foo);
typedef void IdleReadingSelectedIndexes(List<int> foo);
typedef void LoadReadingSelectedIndexes(List<int> foo);
