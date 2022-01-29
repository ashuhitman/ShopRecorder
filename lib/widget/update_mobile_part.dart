import 'package:flutter/material.dart';
import 'package:shop_record/models/mobile_part.dart';
import 'package:shop_record/utils/db_provider.dart';

class UpdateMobilePartWidget extends StatefulWidget {
  final MobilePart? mobilePart;
  final String okButtonText;
  final String title;
  final Function customUpdateFunction;

  const UpdateMobilePartWidget(
      {Key? key,
      required this.mobilePart,
      required this.title,
      required this.okButtonText,
      required this.customUpdateFunction})
      : super(key: key);

  @override
  _UpdateMobilePartState createState() => _UpdateMobilePartState();
}

class _UpdateMobilePartState extends State<UpdateMobilePartWidget> {
  final TextEditingController _controller = TextEditingController();
  var _selectedItem;
  String errorText = '';
  final parts = ['folder', 'touch', 'battery', 'default'];
  var partsValues = [
    Icons.folder,
    Icons.touch_app,
    Icons.battery_charging_full_outlined,
    Icons.mobile_friendly,
  ];
  @override
  void initState() {
    super.initState();
    if (widget.mobilePart != null) {
      _controller.text = widget.mobilePart!.partName;
      _selectedItem = widget.mobilePart!.iconName;
    }
    _controller.addListener(() {
      if (_controller.text.length > 0) {
        setState(() {
          errorText = '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              controller: _controller,
              decoration:
                  const InputDecoration(hintText: "Enter mobile part name")),
          const SizedBox(height: 10),
          DropdownButton<String>(
            isExpanded: true,
            hint: const Text("select an icon"),
            items: parts.asMap().entries.map((e) {
              return DropdownMenuItem<String>(
                  value: e.value,
                  child: Row(
                    children: [
                      Icon(
                        partsValues[e.key],
                        color: Colors.green[700],
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(e.value)
                    ],
                  ));
            }).toList(),
            onChanged: (String? newSelectedItem) {
              setState(() {
                _selectedItem = newSelectedItem;
                errorText = '';
              });
            },
            value: _selectedItem,
          ),
          const SizedBox(
            height: 5,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            // Navigator.pop(context, 'Update');
            debugPrint("ouy, ${_controller.text}, $_selectedItem");
            debugPrint(_isValid(_controller.text, _selectedItem).toString());
            if (_isValid(_controller.text, _selectedItem)) {
              if (widget.okButtonText == "Add") {
                await _insert();
              } else {
                await _update();
              }
              Navigator.pop(context, widget.okButtonText);
            }
          },
          child: Text(widget.okButtonText),
        ),
      ],
    );
  }

  bool _isValid(String text, selectedItem) {
    if (text.trim().length < 3) {
      setState(() {
        errorText = "Enter atlest 3 characters";
      });
      return false;
    }
    if (_selectedItem == null) {
      setState(() {
        errorText = "Select an Icon";
      });
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    try {
      debugPrint("starting");
      MobilePart updatedRow = await DBProvider.instance.update(
          MobilePart(partName: _controller.text, iconName: _selectedItem));
      debugPrint("updated");
      widget.customUpdateFunction(updatedRow);
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        errorText = "Couldn't update";
      });
    }
  }

  _insert() async {
    try {
      debugPrint("starting");
      MobilePart updatedRow = await DBProvider.instance.insert(
          MobilePart(partName: _controller.text, iconName: _selectedItem));
      debugPrint("uinserted");
      widget.customUpdateFunction(updatedRow);
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        errorText = "Couldn't insert";
      });
    }
  }
}
