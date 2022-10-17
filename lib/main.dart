import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:scientific_calculator/src/backend/historyitem.dart';
import 'package:scientific_calculator/src/pages/history.dart';

import 'package:scientific_calculator/src/widgets/mathbox.dart';
import 'package:scientific_calculator/src/widgets/result.dart';
import 'package:scientific_calculator/src/widgets/matrixbutton.dart';
import 'package:scientific_calculator/src/widgets/keyboard.dart';
import 'package:scientific_calculator/src/backend/mathmodel.dart';
import 'package:scientific_calculator/src/pages/settingpage.dart';
import 'package:scientific_calculator/src/pages/functionpage.dart';
import 'package:community_material_icon/community_material_icon.dart';


void main() async{

  //It make sures that all binding is done before MyApp() is called
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(HistoryItemAdapter());
  await Hive.openBox<HistoryItem>('history');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  //Describes the part of the user interface represented by this widget.
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.blueAccent,
      ),
    );
    return MultiProvider(
      providers: [
        Provider(create: (context) => MathBoxController()),
        Provider(create: (_)=> History()),
        ChangeNotifierProvider(create: (_) => SettingModel()),

        //combine file with another model
        ChangeNotifierProxyProvider<SettingModel, MathModel>(
          create: (context) => MathModel(),
          update: (context, settings, model) => model!
            ..changeSetting(
            precision: settings.precision.toInt(),
            isRadMode: settings.isRadMode),

    ),
        ChangeNotifierProxyProvider<SettingModel, MatrixModel>(
          create: (context) => MatrixModel(),
          update: (context, settings, model) => model!
            ..changeSetting(
              precision: settings.precision.toInt(),
            ),
        ),
        Provider(create: (context) => FunctionModel()),
        ListenableProxyProvider<SettingModel, CalculationMode>(
          create: (context) => CalculationMode(Mode.Basic),
          update: (context, settings, model) {
            if (settings.loading.isCompleted) {
              switch (settings.initPage) {
                case 0:
                  if (model!.value == Mode.Matrix) {
                    model.value = Mode.Basic;
                  }
                  break;
                case 1:
                  model!.changeMode(Mode.Matrix);
                  break;
              }
            }
            return model!;
          },
          dispose: (context, value) => value.dispose(),
        ),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Scientific calculator',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          canvasColor: Colors.white,
        ),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final Server _server = Server();
  TabController? tabController;
  List tabs = ["Basic", "Matrix",""];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabs.length, vsync: this);
    _server.start();
  }

  @override
  void dispose() {
    _server.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = Provider.of<CalculationMode>(context, listen: false);
    final mathBoxController =
    Provider.of<MathBoxController>(context, listen: false);
    final setting = Provider.of<SettingModel>(context, listen: false);
    final history = Provider.of<History>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        brightness: Brightness.light,
        leading: IconButton(
          icon: Icon(
            CommunityMaterialIcons.brightness_7,
            color: Colors.grey,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingPage()),
            );
          },
        ),
        
        title: FutureBuilder(
          future: setting.loading.future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              tabController!.index = setting.initPage;
            }
            return TabBar(
              indicatorColor: Colors.blueAccent[400],
              controller: tabController,
              labelColor: Colors.black,
              indicator: BoxDecoration(
                border: Border.all(
                  color: Colors.blueAccent,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              tabs: <Widget>[
                Tab(text: 'Basic'),
                Tab(text: 'Matrix'),
                Tab(
                    icon: IconButton(
                      icon: Icon(
                        CommunityMaterialIcons.history,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => History()),
                        );
                      },
                    ),
                ),
              ],
              onTap: (index) {
                setting.changeInitpage(index);
                switch (index) {
                  case 0:
                    if (mode.value == Mode.Matrix) {
                      mode.value = Mode.Basic;
                      mathBoxController.deleteAllExpression();
                    }
                    break;
                  case 1:
                    if (mode.value != Mode.Matrix) {
                      mode.value = Mode.Matrix;
                      mathBoxController.deleteAllExpression();
                      mathBoxController.addExpression('\\\\bmatrix');
                    }
                    break;

                  default:
                    throw 'Unknown type';
                }
              },
            );
          },
        ),


      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                MathBox(),
                SlidComponent(),
              ],
            ),
          ),
          MathKeyBoard(),
        ],
      ),
    );
  }
}

class SlidComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Consumer<CalculationMode>(
          builder: (context, mathMode, _) {
            switch (mathMode.value) {
              case Mode.Basic:
                return Result();
                break;
              case Mode.Matrix:
                return MatrixButton();
                break;
              case Mode.Function:
                return OutlinedButton(
                  child: Text('Analyze'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FunctionPage()),
                    );
                  },
                );
                break;
              default:
                throw 'Error';
            }
          },
        ),
        Consumer<CalculationMode>(
          builder: (context, mathMode, _) => mathMode.value != Mode.Matrix
              ? ExpandKeyBoard()
              : SizedBox(
            height: 0.0,
          ),
        ),
      ],
    );
  }
}
