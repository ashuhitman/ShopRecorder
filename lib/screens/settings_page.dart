import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final String title;
  const SettingsPage({Key? key, required this.title}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController? _controller;
  String _errorText = '';
  String? _shopName;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller!.text = widget.title;
    _controller!.addListener(() {
      if (_errorText != '') {
        setState(() {
          _errorText = '';
        });
      }
    });
    _shopName = widget.title;
  }

  Future<bool> _onWillPop() async {
    if (_shopName!.isNotEmpty) {
      Navigator.pop(context, _shopName);
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context, _shopName);
              },
              icon: const Icon(Icons.arrow_back)),
          title: const Text("Settings"),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTextField(),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                _errorText,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 20.0),
              MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22.0)),
                minWidth: 100.0,
                height: 50,
                color: const Color(0xFF801E48),
                onPressed: () {
                  if (_controller!.text == _shopName) {
                    debugPrint("same title");
                    setState(() {
                      _errorText = "Change Shop Name to update";
                    });
                    return;
                  }

                  if (_controller!.text.trim().length <= 3) {
                    setState(() {
                      _errorText =
                          "Shop name msut be atleast 3 characters long";
                    });
                    return;
                  }

                  _saveShopName();
                },
                child: const Text(
                  "Update",
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20.0,
      ),
      controller: _controller,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.title),
        hintText: "Enter Mobile Shop Name",
        hintStyle: TextStyle(
          fontSize: 20.0,
          color: Colors.redAccent[100],
          backgroundColor: Colors.blue[30],
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF801E48)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[800],
      ),
    );
  }

  void _saveShopName() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String title = _controller!.text;
      preferences.setString("shopName", title);
      setState(() {
        _errorText = "Shop name updated 😊";
        _shopName = title;
      });
    } catch (e) {
      setState(() {
        _errorText = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(() {});
    _controller?.dispose();
    super.dispose();
  }
}
