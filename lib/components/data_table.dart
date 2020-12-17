import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:silnik_app/api/models/idle_reading.dart';
import 'package:silnik_app/api/models/load_reading.dart';
import '../lists.dart';

class CustomPaginatedTable extends StatefulWidget{
  final List<IdleReading> idleReadings;
  final List<LoadReading> loadReadings;
  final bool isIdleSelected;

  static List<int> idleReadingItemSelected = new List();
  static List<int> loadReadingItemSelected = new List();

  CustomPaginatedTable({this.idleReadings, this.loadReadings, this.isIdleSelected=true});

  @override
  _CustomPaginatedTableState createState() => _CustomPaginatedTableState();
}

class _CustomPaginatedTableState extends State<CustomPaginatedTable> {
  DTS dts;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int selectedItems = 0;

  @override
  Widget build(BuildContext context) {
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
            Expanded(child:
            PaginatedDataTable(
              columns: widget.isIdleSelected
                  ? Lists.statsList.where((x) => !x.loadEngineStateReading)
                  .map((e) {
                return DataColumn(label: Center(child: Text("${e.symbol} [${e.unit}]")));
              }).toList()
                  : Lists.statsList.map((e) {
                return DataColumn(label: Center(child: Text("${e.symbol} [${e.unit}]")));
              }).toList(),
              source: dts,
              onSelectAll: dts._selectAll,
              rowsPerPage: _rowsPerPage,
              onRowsPerPageChanged: (r) {
                setState(() {
                  _rowsPerPage = r;
                });
              },
              header: selectedItems>0 ? Container(
                margin: EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: FlatButton(
                        onPressed: () {
                          setState(() {
                            if(widget.isIdleSelected) {
                              CustomPaginatedTable.idleReadingItemSelected.forEach((i) {
                                widget.idleReadings.removeWhere((x)=>x.reading.id==i);
                              });
                              CustomPaginatedTable.idleReadingItemSelected.clear();
                            }
                              else {
                              CustomPaginatedTable.loadReadingItemSelected.forEach((i) {
                                print("CustomPaginatedTable.loadReadingItemSelected $i");
                                widget.loadReadings.removeWhere((x)=>x.reading.id==i);
                              });
                              CustomPaginatedTable.loadReadingItemSelected.clear();
                            }
                            dts._selectAll(false);
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Usuń zaznaczone",
                              style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.red)),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide(color: Colors.red)
                        ),
                      ),
                    )
                  ],
                ),
              ) : Container(),
            )
            )
          ],
        ),
      ],
    );
  }
}

class DTS extends DataTableSource{

  List list;
  MyCallback callback;
  IdleReadingSelectedIndexes idleReadingSelectedIndexes;
  LoadReadingSelectedIndexes loadReadingSelectedIndexes;

  List<int> idleReadingSelectedIndexesList = new List();
  List<int> loadReadingSelectedIndexesList = new List();

  DTS(this.list, {this.callback, this.idleReadingSelectedIndexes,
    this.loadReadingSelectedIndexes});

  void addSelectedIndexes(int id, {bool remove = false}){
    if (list is List<LoadReading>){
      if(remove)
        CustomPaginatedTable.loadReadingItemSelected.remove(id);
      else
        CustomPaginatedTable.loadReadingItemSelected.add(id);
    }
    else{
      if(remove)
        CustomPaginatedTable.idleReadingItemSelected.remove(id);
      else
        CustomPaginatedTable.idleReadingItemSelected.add(id);
    }
  }

  @override
  DataRow getRow(int index) {
    if(index<list.length) {
      assert(index >= 0);
      if (index >= list.length)
        return null;
      final dynamic x = list[index];
      return DataRow.byIndex(
        index: index,
        selected: x.selected,
        onSelectChanged: (bool value) {
          if (x.selected != value) {
            x.selected = !x.selected;
            _selectedCount = list.where((z)=>z.selected).length;
            callback(selectedRowCount);
            addSelectedIndexes(x.reading.id, remove: !x.selected);
            notifyListeners();
          }
        },
        cells: [
          DataCell(Text(list[index]?.reading?.voltage?.toStringAsFixed(3) ?? "-")),
          DataCell(Text(list[index]?.reading?.powerFrequency?.toStringAsFixed(3) ?? "-")),
          DataCell(Text(list[index]?.reading?.power?.toStringAsFixed(3) ?? "-")),
          DataCell(Text(list[index]?.reading?.rotationalSpeed?.toStringAsFixed(3) ?? "-")),
          DataCell(Text(list[index]?.reading?.statorCurrent?.toStringAsFixed(3) ?? "-")),
          DataCell(Text(list[index]?.reading?.rotorCurrent?.toStringAsFixed(3) ?? "-")),
          if (list is List<LoadReading>)
            DataCell(Text(list[index]?.torque?.toStringAsFixed(3) ?? "-"))
        ],
      );
    }
    else return DataRow(
      cells: [
        DataCell(Container()),
        DataCell(Container()),
        DataCell(Container()),
        DataCell(Container()),
        DataCell(Container()),
        DataCell(Container()),
        if (list is List<LoadReading>)
          DataCell(Container())
      ]
    );
  }


  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => list.length;

  @override
  int get selectedRowCount => _selectedCount;

  void _selectAll(bool checked) {
    for (dynamic x in list) {
      x.selected = checked;
      addSelectedIndexes(x.reading.id, remove: !x.selected);
    }
    _selectedCount = list.where((x)=>x.selected).length;
    callback(selectedRowCount);
    notifyListeners();
  }

  int _selectedCount = 0;

}

typedef void MyCallback(int foo);
typedef void IdleReadingSelectedIndexes(List<int> foo);
typedef void LoadReadingSelectedIndexes(List<int> foo);