import 'package:flutter/material.dart';
import 'package:shop_record/models/part_item.dart';
import 'package:shop_record/utils/db_provider.dart';

Future<PartItem?> openPartItemDialogBox(BuildContext context, PartItem partItem,
    String okButtonText, String title) {
  String errorText = '';
  bool isLoading = false;
  String name = partItem.itemName!;
  String price = partItem.price == 0 ? '' : partItem.price.toString();

  return showDialog<PartItem>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                    enabled: false,
                    initialValue: partItem.partName,
                    onChanged: (value) {
                      setState(() {
                        errorText = '';
                      });
                    },
                    decoration: InputDecoration(hintText: "Enter part name")),
                const SizedBox(height: 10),
                TextFormField(
                    initialValue: name,
                    onChanged: (value) {
                      name = value;
                      setState(() {
                        errorText = '';
                      });
                    },
                    decoration:
                        const InputDecoration(hintText: "Enter item name")),
                TextFormField(
                    initialValue: price,
                    onChanged: (value) {
                      price = value;
                      setState(() {
                        errorText = '';
                      });
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: "Enter Price")),
                const SizedBox(
                  height: 10,
                ),
                isLoading
                    ? const CircularProgressIndicator()
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          errorText,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (name.isEmpty || price.isEmpty) {
                    debugPrint("Field can't be empty");
                    setState(() {
                      errorText = "Field can't be empty";
                    });
                    return;
                  }

                  PartItem? item;

                  try {
                    setState(() {
                      isLoading = true;
                    });

                    debugPrint("$name: $price");
                    item = (okButtonText == 'Add')
                        ? await DBProvider.instance.insertPartItem(
                            PartItem(
                              partName: partItem.partName,
                              itemName: name,
                              price: int.parse(price),
                            ),
                          )
                        : await DBProvider.instance.updatePartItem(
                            PartItem(
                              id: partItem.id,
                              partName: partItem.partName,
                              itemName: name,
                              price: int.parse(price),
                            ),
                          );
                    showSnackBar(context,
                        okButtonText == 'Add' ? 'Item Added' : 'Item UPdated');
                  } catch (e) {
                    debugPrint("error: " + e.toString());
                    item = null;
                    showSnackBar(
                        context,
                        okButtonText == 'Add'
                            ? "Coudn't add item"
                            : "Couldn't update item.");
                  }

                  setState(() {
                    isLoading = false;
                  });
                  Navigator.pop(context, item);
                },
                child: Text(okButtonText),
              ),
            ],
          );
        });
      });
}

showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
