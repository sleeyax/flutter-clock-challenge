import 'dart:async';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:intl/intl.dart';
import 'package:sleeyax_clock/src/border_painter.dart';

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

  final _tempSettings = const TemperatureSettings(cold: 8, hot: 20);

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
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    // final second = DateFormat('ss').format(_dateTime);
    final theme = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;

    return Container(
      color: theme.color,
      child: DefaultTextStyle(
        style: theme.textStyle,
        child: Center(
          child: Stack(fit: StackFit.expand, children: [
            // dynamic temperature border
            AspectRatio(
                aspectRatio: 6 / 6,
                child: CustomPaint(
                    painter: ClockBorderPainter(
                        color: Colors.grey[800],
                        foregroundColor: _getBorderColor(widget.model),
                        seconds: _dateTime.second))),
            // time & temperature
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('$hour:$minute'),
                  Text(
                    widget.model.temperatureString,
                    style: TextStyle(fontSize: 20),
                  )
                ],
              ),
            ),
            // weather & location
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                _buildWeatherAnimation(widget.model.weatherString),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    widget.model.location,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildWeatherAnimation(String weather) {
    return Container(
      width: 50,
      height: 50,
      child: FlareActor(
        'assets/animations/$weather.flr',
        alignment: Alignment.center,
        //fit: BoxFit.contain,
        animation: 'go',
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
    } else if (model.temperature > _tempSettings.cold &&
        model.temperature < _tempSettings.hot) {
      return Colors.orange;
    } else {
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
