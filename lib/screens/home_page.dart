import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_record/models/mobile_part.dart';
import 'package:shop_record/screens/settings_page.dart';
import 'package:shop_record/utils/db_provider.dart';
import 'package:shop_record/widget/mobile_part_widget.dart';
import 'package:shop_record/widget/update_mobile_part.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _myList = [];

  TextEditingController? _itemNameController;
  TextEditingController? _priceController;
  final GlobalKey<AnimatedListState> _globalKey =
      GlobalKey<AnimatedListState>();
  AnimatedListState? get _animatedListState => _globalKey.currentState;
  final TextEditingController _controller = TextEditingController();
  late SharedPreferences _preferences;
  String? title;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      getAppTitle();
      getQuery();
    });
  }

  getAppTitle() async {
    try {
      _preferences = await SharedPreferences.getInstance();
      setState(() {
        title = _preferences.getString("shopName") ?? 'Delta MObile';
      });
      debugPrint("home page :$title");
    } catch (e) {
      title = "Delta Mobile";
    }
  }

  getQuery() async {
    debugPrint("function called");
    try {
      var list = await DBProvider.instance.queryAll();

      _myList = list;
      for (int offset = 0; offset < _myList.length; offset++) {
        _globalKey.currentState
            ?.insertItem(offset, duration: Duration(seconds: offset + 1));
      }
    } catch (e) {
      debugPrint("error: ${e.toString()}");
    }
  }

  insertData(MobilePart row, int? index) async {
    debugPrint(row.toMap().toString());
    int i = index ?? (_myList.length > 0 ? _myList.length : 0);
    debugPrint("pos: $i");
    _myList.insert(i, row);
    debugPrint(_myList.toString());

    _animatedListState?.insertItem(i,
        duration: const Duration(milliseconds: 500));
  }

  deleteData(int index) {
    _myList.removeAt(index);
    _animatedListState?.removeItem(index, (context, animation) => Container());
  }

  customUpdate(row, index) {
    debugPrint("custom: from main" + row.toString() + "index: $index");
    debugPrint(_myList.toString());
    deleteData(index);
    insertData(row, index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.home),
        title: Text(title ?? 'Delta Mobile'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                goToSettingPage(context);
              },
              icon: const Icon(Icons.settings)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Expanded(
              child: AnimatedList(
                key: _globalKey,
                initialItemCount: _myList.length,
                itemBuilder: (BuildContext context, int index,
                    Animation<double> animation) {
                  debugPrint(index.toString());
                  return SlideTransition(
                      position: animation.drive(Tween(
                          begin: const Offset(1, 0), end: const Offset(0, 0))),
                      child: MobilePartWidget(
                        customUpdate: (row, index) {
                          customUpdate(row, index);
                        },
                        index: index,
                        mobilePart: _myList[index],
                        customDeleteFunction: (int index) {
                          deleteData(index);
                        },
                      ));
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        onPressed: () {
          showItemInsertDialogBox(
            context,
            MobilePart(iconName: '', partName: ''),
            'Add Item',
            'Add',
          );
          // openInsertPartItemDialogBox(context);
        },
        tooltip: 'Increment',
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  showSnackBar(BuildContext context, String message) {
    SnackBar snackBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future showItemInsertDialogBox(
    BuildContext context,
    MobilePart mobilePart,
    String title,
    String buttonText,
  ) {
    return showDialog<String>(
        context: context,
        builder: (BuildContext context) => UpdateMobilePartWidget(
              mobilePart: null,
              title: title,
              okButtonText: buttonText,
              customUpdateFunction: (row) {
                insertData(row, null);
              },
            ));
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    _controller.dispose();
    if (_itemNameController != null) {
      _itemNameController!.dispose();
    }
    if (_priceController != null) {
      _priceController!.dispose();
    }
    super.dispose();
  }

  void goToSettingPage(BuildContext context) async {
    var data = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          title: title ?? 'Delta Mobile',
        ),
      ),
    );

    if (title != data && title != null) {
      setState(() {
        title = data;
      });
    }
    debugPrint(data);
  }
}
