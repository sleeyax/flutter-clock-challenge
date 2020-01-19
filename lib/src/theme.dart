import 'dart:ui';

import 'package:flutter/widgets.dart';

class ClockTheme {
  final Color color;
  final TextStyle textStyle;

  const ClockTheme({
    @required this.color,
    @required this.textStyle,
  })  : assert(color != null),
        assert(textStyle != null);
}
