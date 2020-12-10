import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:silnik_app/api/models/idle_reading.dart';
import 'package:silnik_app/api/models/load_reading.dart';
import '../lists.dart';

class CustomPaginatedTable extends StatefulWidget{
  final List<IdleReading> idleReadings;
  final List<LoadReading> loadReadings;
  final bool isIdleSelected;

  CustomPaginatedTable({this.idleReadings, this.loadReadings, this.isIdleSelected=true});

  @override
  _CustomPaginatedTableState createState() => _CustomPaginatedTableState();
}

class _CustomPaginatedTableState extends State<CustomPaginatedTable> {
  var dts;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child:
            PaginatedDataTable(
              columns: widget.isIdleSelected
                  ? Lists.statsList.where((x) => !x.loadEngineStateReading).map((e) {
                return DataColumn(label: Center(child: Text("${e.symbol} [${e.unit}]")));
              }).toList()
                  : Lists.statsList.map((e) {
                return DataColumn(label: Center(child: Text("${e.symbol} [${e.unit}]")));
              }).toList(),
              source: DTS(widget.isIdleSelected ? widget.idleReadings : widget.loadReadings),
              rowsPerPage: _rowsPerPage,
              onRowsPerPageChanged: (r){
                setState(() {
                  _rowsPerPage = r;
                });
              },
            )
        )
      ],
    );
  }
}

class DTS extends DataTableSource{

  var list;
  DTS(this.list);

  @override
  DataRow getRow(int index) {
    if(index<list.length)
    return DataRow(
      cells: [
        DataCell(Text(list[index]?.reading?.voltage?.toStringAsFixed(3) ?? "-")),
        DataCell(Text(list[index]?.reading?.powerFrequency?.toStringAsFixed(3) ?? "-")),
        DataCell(Text(list[index]?.reading?.power?.toStringAsFixed(3) ?? "-")),
        DataCell(Text(list[index]?.reading?.rotationalSpeed?.toStringAsFixed(3) ?? "-")),
        DataCell(Text(list[index]?.reading?.statorCurrent?.toStringAsFixed(3) ?? "-")),
        DataCell(Text(list[index]?.reading?.rotorCurrent?.toStringAsFixed(3) ?? "-")),
        if (list is List<LoadReading>) DataCell(Text(list[index]?.torque?.toStringAsFixed(3) ?? "-"))
      ],
    );
    else return DataRow(
      cells: [
        DataCell(Container()),
        DataCell(Container()),
        DataCell(Container()),
        DataCell(Container()),
        DataCell(Container()),
        DataCell(Container()),
        if (list is List<LoadReading>) DataCell(Container())
      ]
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => list.length;

  @override
  int get selectedRowCount => 0;

}