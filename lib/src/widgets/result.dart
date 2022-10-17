import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'package:scientific_calculator/src/backend/mathmodel.dart';

import '../backend/historyitem.dart';

class Result extends StatefulWidget {
  @override
  _ResultState createState() => _ResultState();
}
bool cnt = false;
class _ResultState extends State<Result> with TickerProviderStateMixin {

  late AnimationController animationController;
  late Animation animation;

  @override
  void initState() {
    super.initState();
    final mathModel = Provider.of<MathModel>(context, listen: false);
    animationController = AnimationController(duration: const Duration(milliseconds: 400),vsync: this);
    mathModel.equalAnimation = animationController;
    final curve = CurvedAnimation(parent: animationController, curve: Curves.easeInOutBack);
    animation = Tween<double>(begin: 30.0, end: 60.0).animate(curve);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Widget _buildAnimation(BuildContext? context, Widget? child) {
    return Container(
      height: animation.value,
      width: double.infinity,
      alignment: Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
      child: Consumer<MathModel>(
        builder: (_, model, __) {
          String text;

          if (model.result!='' && animationController.status == AnimationStatus.dismissed) {
            text = '= ' + model.result;
            print("inside result if: $cnt");
            cnt = true;
          }
          else {
            text = model.result;
            print("inside result else before: $cnt");
            if(cnt == true && model.result.toString() != '') {
              final historyItem = HistoryItem()
                ..title = model.result.toString()
                ..subtitle = expre.toString();

              Hive.box<HistoryItem>('history').add(historyItem);
            }
            cnt = false;
            print("inside result else: $cnt");
          }
          return SelectableText(
            text,
            style: TextStyle(
              fontFamily: "TimesNewRoman",
              fontSize: animation.value - 5,
            ),
            maxLines: 1,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: _buildAnimation,
    );
  }
}
