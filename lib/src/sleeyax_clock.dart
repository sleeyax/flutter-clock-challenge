import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:intl/intl.dart';
import 'package:sleeyax_clock/src/seconds_painter.dart';

import 'theme.dart';
import 'temperature_settings.dart';

class SleeyaxClock extends StatefulWidget {
  final ClockModel model;

  const SleeyaxClock(this.model);

  @override
  _SleeyaxClockState createState() => _SleeyaxClockState();
}

class _SleeyaxClockState extends State<SleeyaxClock> {
  DateTime _dateTime = DateTime.now();

  Timer _timer;

  final _tempSettings = const TemperatureSettings(
    cold: 8,
    hot: 20
  );

  final _lightTheme = const ClockTheme(
      color: Colors.white,
      textStyle:
          TextStyle(color: Colors.black, fontFamily: 'Digital7', fontSize: 40));

  final _darkTheme = const ClockTheme(
      color: Colors.black,
      textStyle:
          TextStyle(color: Colors.white, fontFamily: 'Digital7', fontSize: 40));

  @override
  void initState() {
    super.initState();
    // rebuild clock when the model changes
    widget.model.addListener(_updateModel);
    _updateModel();
    _updateTime();
  }

  @override
  void didUpdateWidget(SleeyaxClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    // final second = DateFormat('ss').format(_dateTime);
    final theme = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;

    return Container(
      color: theme.color,
      child: Center(
        child: Stack(
          fit: StackFit.expand,
          children: [
            AspectRatio(
              aspectRatio: 6 / 6,
              child: CustomPaint(painter: SecondsPainter(
                color: Colors.grey[800],
                foregroundColor: _getBorderColor(widget.model),
                seconds: _dateTime.second
              ))
            ),
            Align(
              alignment: Alignment.center,
              child: Text('$hour:$minute', style: theme.textStyle),
            )
          ]),
      ),
    );
  }
  
  /// get the clock border color based on the current temperature
  /// 
  /// cold - blue
  /// neither hot or cold - orange
  /// hot - red
  Color _getBorderColor(ClockModel model) {
    if (model.temperature >= _tempSettings.hot) {
      return Colors.red;
    }else if (model.temperature > _tempSettings.cold && model.temperature < _tempSettings.hot) {
      return Colors.orange;
    }else {
      return Colors.blue;
    }
  }

  void _updateModel() => setState(() {});

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }
}
