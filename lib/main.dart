import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'app.dart';

/* 
one day there will be a script that:
1. runs `flutter build ios --release` 
2. copies /build/ios/iphoneos/Runner.app to a new folder titled "Payload"
3. compresses Payload into a zip file, and changes extension to .ipa
*/

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // This app is designed only to work vertically, so we limit
  // orientations to portrait up and down.
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(const PostComposerApp());
}
