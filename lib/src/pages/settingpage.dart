import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:scientific_calculator/src/backend/mathmodel.dart';
import 'package:community_material_icon/community_material_icon.dart';

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mathModel = Provider.of<MathModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,),
          onPressed: () {
            mathModel.calcNumber();
            Navigator.pop(context);
          },
        ),
        title: Text('Setting',),
      ),
      body: ListView(
        itemExtent: 60.0,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        children: <Widget>[
          ListTile(
            leading: Text(
              'Calc Setting',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Consumer<SettingModel>(
            builder: (context, setmodel, _) => ListTile(
              title: ToggleButtons(
                children: <Widget>[
                  Text('RAD'),
                  Text('DEG'),
                ],
                constraints: BoxConstraints(
                  minWidth: 100,
                  minHeight: 40,
                ),
                isSelected: [setmodel.isRadMode, !setmodel.isRadMode],
                onPressed: (index) {
                  setmodel.changeRadMode((index==0)?true:false);
                },
              ),
            ),
          ),
          Consumer<SettingModel>(
            builder: (context, setmodel, _) => ListTile(
              title: Text('Calc Precision'),
              subtitle: Slider(
                value: setmodel.precision.toDouble(),
                min: 0.0,
                max: 10.0,
                label: "${setmodel.precision.toInt()}",
                divisions: 10,
                onChanged: (val) {
                  setmodel.changeSlider(val);
                },
              ),
              trailing: Text('${setmodel.precision.toInt()}'),
            ),
          ),
          Divider(),
          ListTile(
            leading: Text(
              'About',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ListTile(
            leading: Icon(CommunityMaterialIcons.github),
            title: Text('Github'),
            onTap: () {
              // _launchURL('https://github.com/DylanXie123/Num-Plus-Plus');
            },
          ),
          ListTile(
            leading: Icon(CommunityMaterialIcons.email_edit_outline),
            title: Text('Email'),
            onTap: () {
              Uri url = Uri.parse('https://www.google.com/');
              _launchURL(url);
            },
          ),
        ],
      ),
    );
  }

  _launchURL(Uri url) async {
    if (await launchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

}

class SettingModel with ChangeNotifier {
  num precision = 10;
  bool isRadMode = true;
  bool hideKeyboard = false;
  int initPage = 0;
  Completer loading = Completer();

  SettingModel() {
    initVal();
  }

  Future changeSlider(double val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    precision = val;
    prefs.setDouble('precision', precision.toDouble());
    notifyListeners();
  }

  Future changeRadMode(bool mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isRadMode = mode;
    prefs.setBool('isRadMode', isRadMode);
    notifyListeners();
  }

  Future changeKeyboardMode(bool mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    hideKeyboard = mode;
    prefs.setBool('hideKeyboard', hideKeyboard);
  }

  Future changeInitpage(int val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    initPage = val;
    prefs.setInt('initPage', initPage);
  }

  Future initVal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    precision = prefs.getDouble('precision') ?? 10;
    isRadMode = prefs.getBool('isRadMode') ?? true;
    hideKeyboard = prefs.getBool('hideKeyboard') ?? false;
    initPage = prefs.getInt('initPage') ?? 0;
    loading.complete();
    notifyListeners();
  }

}
