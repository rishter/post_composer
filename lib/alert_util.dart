import 'package:flutter/cupertino.dart';

void showAlert(BuildContext context, String title, String text) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(text),
      // actions: <CupertinoDialogAction>[
      //   CupertinoDialogAction(
      //     /// This parameter indicates this action is the default,
      //     /// and turns the action's text to bold text.
      //     isDefaultAction: true,
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //     child: const Text('No'),
      //   ),
      //   CupertinoDialogAction(
      //     /// This parameter indicates the action would perform
      //     /// a destructive action such as deletion, and turns
      //     /// the action's text color to red.
      //     isDestructiveAction: true,
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //     child: const Text('Yes'),
      //   ),
      // ],
    ),
  );
}
