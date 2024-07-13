import 'dart:typed_data';
import 'package:gal/gal.dart';

_checkAccess() async {
  final hasAccess = await Gal.hasAccess();
  if (!hasAccess) {
    await Gal.requestAccess();
  }
}

Future<void> _saveImage(imageController) async {
  Uint8List bytes = await imageController.capture();
  await Gal.putImageBytes(bytes);
}

saveImages(imageControllers) async {
  await _checkAccess();

  List<Future<void>> futures = imageControllers.map((ic) => _saveImage(ic)).toList();
  try {
    await Future.wait(futures);
  } on GalException catch (e) {
    print(e.type.message);
  }

  await Gal.open();
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
