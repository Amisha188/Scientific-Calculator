import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

const buttonsBackgroundColor = Color(0xFF090E1C);
const backgroundColor = Color(0xFF141A2F);
const yellowColor = Color(0xFFF7CF32);
const whiteColor = Colors.white;

AppBar appbar(
  BuildContext context,
  String title,
  IconData icon,
  Function() tap,
) {
  return AppBar(
    title: Text(
      title,
      style: TextStyle(fontWeight: FontWeight.w400),
    ),
    actions: [
      IconButton(
        onPressed: tap,
        icon: Icon(icon),
      ),
    ],
  );
}

// class CalculatorButton extends StatelessWidget {
//   final String label;
//   final bool isColored, isEqualSign, canBeFirst;
//   const CalculatorButton(
//     this.label, {
//     this.isColored = false,
//     this.isEqualSign = false,
//     this.canBeFirst = true,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final TextStyle? textStyle = Theme.of(context).textTheme.headline6;
//     final mediaQuery = MediaQuery.of(context).size;
//     return Material(
//       color: buttonsBackgroundColor,
//       child: Center(
//         child: isEqualSign
//             ? Container(
//                 height: mediaQuery.width * 0.1,
//                 width: mediaQuery.width * 0.1,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(5.0),
//                   color: yellowColor,
//                 ),
//                 child: Center(
//                   child: Text(
//                     label,
//                     style: textStyle?.copyWith(color: backgroundColor),
//                   ),
//                 ),
//               )
//             : Text(
//                 label,
//                 style: textStyle?.copyWith(
//                     color: isColored ? yellowColor : whiteColor),
//               ),
//       ),
//     );
//   }
// }

void showToast(BuildContext context, String message) {
  final scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(milliseconds: 400),
    ),
  );
}
