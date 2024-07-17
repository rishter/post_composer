import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import 'alert_util.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

import 'package:gal/gal.dart';
import 'package:jpeg_encode/jpeg_encode.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'styles.dart';

_checkAccess() async {
  final hasAccess = await Gal.hasAccess();
  if (!hasAccess) {
    await Gal.requestAccess();
  }
}

// not sure how to make this work async
_alertError(BuildContext context, String message) {
  showAlert(context, "Error", message);
}

Future<Uint8List?> captureImage(GlobalKey key) async {
  try {
    RenderRepaintBoundary? boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      print("Boundary is null");
      return null;
    }
    ui.Image image =
        await boundary.toImage(pixelRatio: Styles.invertScaleFactor);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      print("ByteData is null");
      return null;
    }
    return byteData.buffer.asUint8List();
  } catch (e) {
    print("Error capturing image: $e");
    return null;
  }
}

saveImages(List<GlobalKey> imageKeys, Function(int) switchToIndex) async {
  await _checkAccess();

  for (int i = 0; i < imageKeys.length; i++) {
    await switchToIndex(i);

    // Wait for the slide to be visible and rendered
    await Future.delayed(const Duration(milliseconds: 100));

    Uint8List? pngBytes = await captureImage(imageKeys[i]);
    if (pngBytes != null) {
      try {
        // await Gal.putImageBytes(pngBytes);
        await ImageGallerySaver.saveImage(pngBytes);
      } catch (e) {
        print("Failed to save image $i: $e");
      }
    } else {
      print("Failed to capture image $i");
    }
  }

  try {
    await Gal.open();
  } on GalException catch (e) {
    print(e.type.message);
  } catch (e) {
    print("Unexpected error: $e");
  }
}

// Exception Type
enum GalExceptionType {
  accessDenied,
  notEnoughSpace,
  notSupportedFormat,
  unexpected;

  String get message => switch (this) {
        accessDenied => 'Permission to access the gallery is denied.',
        notEnoughSpace => 'Not enough space for storage.',
        notSupportedFormat => 'Unsupported file formats.',
        unexpected => 'An unexpected error has occurred.',
      };
}
