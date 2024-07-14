// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';

abstract class Styles {
  static const TextStyle comicSansText =
      TextStyle(fontFamily: 'Comic', fontSize: 16.66);

  static const Color backgroundGrey = Color(0xFFF5F5F5);
  static Color shadowGrey = CupertinoColors.systemGrey.withOpacity(0.5);
  static Color activeBlue = CupertinoColors.activeBlue.withOpacity(0.6);
}
