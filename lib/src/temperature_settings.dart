import 'package:flutter/widgets.dart';

class TemperatureSettings {
  final num cold;
  final num hot;

  const TemperatureSettings({@required this.cold, @required this.hot})
      : assert(cold != null),
        assert(hot != null);
}
