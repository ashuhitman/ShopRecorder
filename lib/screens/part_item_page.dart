import 'package:flutter/material.dart';
import 'package:shop_record/models/part_item.dart';
import 'package:shop_record/utils/db_provider.dart';
import 'package:shop_record/utils/uitlity_fun.dart';

class PartItemPage extends StatefulWidget {
  final String partTitle;
  const PartItemPage({Key? key, required this.partTitle}) : super(key: key);

  @override
  _PartItemPageState createState() => _PartItemPageState();
}

class _PartItemPageState extends State<PartItemPage>
    with SingleTickerProviderStateMixin {
  var _myPartITems = [];
  var _newPartItems = [];
  bool isLading = true;
  int _selectedIndex = -1;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    getPartItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var dataRows = _newPartItems.map<DataRow>((item) {
      return DataRow(
        selected: _myPartITems.indexOf(item) == _selectedIndex,
        cells: [
          DataCell(Text("${_myPartITems.indexOf(item) + 1}")),
          DataCell(Text(item.itemName)),
          DataCell(Text("₹ " + item.price.toString())),
          DataCell(IconButton(
            onPressed: () async {
              var partItem = await openPartItemDialogBox(
                  context, item, 'Update', 'Update Item');
              debugPrint("datarow: ${partItem?.toMap()}");
              if (partItem != null) {
                int index = _myPartITems
                    .indexWhere((element) => element.id == partItem.id);
                debugPrint("index: " + index.toString());
                _myPartITems[index] = partItem;
                setState(() {
                  _newPartItems = _myPartITems;
                  _selectedIndex = index;
                });
              }
              // reset search field
              if (_controller.text.trim() != '') {
                _controller.text = '';
              }
            },
            icon: const Icon(Icons.edit),
          )),
          DataCell(IconButton(
              onPressed: () async {
                await deleteALertDialogBox(context, item.id);
                setState(() {
                  _myPartITems.removeWhere((element) => element.id == item.id);
                  _selectedIndex = -1;
                  _newPartItems = _myPartITems;
                });
              },
              icon: const Icon(Icons.delete))),
        ],
      );
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.partTitle),
      ),
      body: getBodyItem(dataRows),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var partItem = await openPartItemDialogBox(
              context,
              PartItem(itemName: '', partName: widget.partTitle, price: 0),
              'Add',
              'Add Item');
          if (partItem != null) {
            _myPartITems.add(partItem);
            setState(() {
              _newPartItems = _myPartITems;
              _selectedIndex = _newPartItems.length - 1;
            });
          }
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.pink,
      ),
    );
  }

  void getPartItems() async {
    try {
      List<PartItem> partItems =
          await DBProvider.instance.queryAllPartItems(widget.partTitle);
      _myPartITems = partItems;
      setState(() {
        _newPartItems = _myPartITems;
        isLading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  buildDataTable(List<DataRow> dataRows) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: DataTable(
            columnSpacing: 20,
            columns: [
              const DataColumn(label: Text('S.No.')),
              const DataColumn(label: Text('Name')),
              const DataColumn(label: Text('Price')),
              const DataColumn(label: Text('Edit')),
              const DataColumn(label: Text('Delete')),
            ],
            rows: dataRows,
          ),
        );
      },
    );
  }

  getBodyItem(dataRows) {
    if (isLading) {
      return const Center(child: CircularProgressIndicator());
    } else if (!isLading && _myPartITems.isEmpty) {
      return const Center(
        child: Text("No items"),
      );
    } else {
      return Column(children: [buildSearchBox(), buildDataTable(dataRows)]);
    }
  }

  Future<void> deleteALertDialogBox(BuildContext context, int id) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Icon(Icons.add_alert_outlined),
            content: const Text("Are you sure you want to delete?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await DBProvider.instance.deleteSinglePartItem(id);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("couldn't delete")),
                    );
                  }
                  Navigator.pop(context);
                },
                child: const Text('Yes'),
              ),
            ],
          );
        });
  }

  Widget buildSearchBox() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0)),
      child: TextField(
        style: const TextStyle(color: Colors.black),
        onChanged: (value) {
          searchBook(value);
        },
        controller: _controller,
        decoration: InputDecoration(
          hintText: "Search here",
          hintStyle: const TextStyle(color: Colors.pinkAccent),
          filled: true,
          fillColor: Colors.blue[50],
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          suffixIcon: _controller.text.length > 0
              ? GestureDetector(
                  child: const Icon(Icons.close),
                  onTap: () {
                    _controller.clear();
                    setState(() {
                      _newPartItems = _myPartITems;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void searchBook(String query) {
    final newPartItems = _myPartITems.where((item) {
      final partname = item.itemName.toLowerCase();
      final searchLower = query.toLowerCase();
      return partname.contains(searchLower);
    }).toList();
    setState(() {
      _newPartItems = newPartItems;
    });
  }
}
