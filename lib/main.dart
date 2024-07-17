import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'widgets/post_list.dart';
import 'package:post_composer/util/db.dart';

/*
icebox:
  * fix build_ipa.sh
  * delete all slides following this one
  * focus on new slide text field when adding new slide
  * make the context menu action go on the entire post not just the text
  * undo / redo
  * hide delete when there is only one slide?
  * save as album
*/

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // deleteDatabase();

  // This app is designed only to work vertically, so we limit
  // orientations to portrait up and down.
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(const PostComposerApp());
}

class PostComposerApp extends StatelessWidget {
  const PostComposerApp({super.key}) : super();

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      theme: CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          navLargeTitleTextStyle: TextStyle(fontSize: 25.0),
        ),
      ),
      home: PostListHomePage(),
    );
  }
}
