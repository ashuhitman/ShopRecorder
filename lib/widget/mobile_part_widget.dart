import 'package:flutter/material.dart';
import 'package:shop_record/models/mobile_part.dart';
import 'package:shop_record/screens/part_item_page.dart';
import 'package:shop_record/utils/db_provider.dart';
import 'package:shop_record/widget/update_mobile_part.dart';

class MobilePartWidget extends StatelessWidget {
  final MobilePart mobilePart;
  final int index;
  final Function customDeleteFunction;
  final Function customUpdate;
  MobilePartWidget(
      {Key? key,
      required this.mobilePart,
      required this.customDeleteFunction,
      required this.index,
      required this.customUpdate})
      : super(key: key);
  final parts = ['folder', 'touch', 'battery', 'default'];

  final partsValues = [
    Icons.folder,
    Icons.touch_app,
    Icons.battery_charging_full_outlined,
    Icons.mobile_friendly,
  ];

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      onDismissed: (direction) async {
        debugPrint("deleteing");
        int id = mobilePart.id!;
        try {
          await DBProvider.instance.delete(id);
          await DBProvider.instance.deletePartItem(mobilePart.partName);
        } catch (e) {
          debugPrint(e.toString());
        }
        debugPrint(id.toString());
        customDeleteFunction(index);
      },
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
        padding: const EdgeInsets.all(10.0),
        alignment: Alignment.centerRight,
        color: Colors.red,
        child: const Icon(Icons.delete),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        color: Theme.of(context).primaryColor,
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PartItemPage(
                  partTitle: mobilePart.partName,
                ),
              ),
            );
          },
          contentPadding:
              const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          leading: Icon(
            partsValues[parts.indexOf(mobilePart.iconName)],
            color: Colors.pinkAccent,
          ),
          title: Text(mobilePart.partName),
          trailing: IconButton(
            onPressed: () {
              showItemUpdateDialogBox(
                  context, mobilePart, "Update Item", "Update");
            },
            icon: const Icon(Icons.edit),
          ),
        ),
      ),
    );
  }

  Future showItemUpdateDialogBox(
    BuildContext context,
    MobilePart mobilePart,
    String title,
    String buttonText,
  ) {
    return showDialog<String>(
        context: context,
        builder: (BuildContext context) => UpdateMobilePartWidget(
              mobilePart: mobilePart,
              title: title,
              okButtonText: buttonText,
              customUpdateFunction: (row) {
                customUpdate(row, index);
              },
            ));
  }
}
