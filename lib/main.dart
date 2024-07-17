import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'widgets/post_list.dart';
import 'package:post_composer/util/db.dart';

/* 
one day there will be a script that:
1. runs `flutter build ios --release` 
2. copies /build/ios/iphoneos/Runner.app to a new folder titled "Payload"
3. compresses Payload into a zip file, and changes extension to .ipa
*/

/*
backlog: 
  * clear all slides
  * editing mode bug
  * persist posts 
    * delete posts https://pub.dev/documentation/flutter_swipe_action_cell/latest/
  * style empty post container
  * what's the deal with the image?
  * icebox
    * make the context menu action go on the entire post not just the text
    * undo / redo
    * hide delete when there is only one slide?
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
