
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:torn_pda/providers/settings_provider.dart';

class TctClock extends StatefulWidget {
  const TctClock({
    Key key,
  }) : super(key: key);

  @override
  State<TctClock> createState() => _TctClockState();
}

class _TctClockState extends State<TctClock> {
  Timer _oneSecTimer;
  DateTime _currentTctTime = DateTime.now().toUtc();

  @override
  void initState() {
    _oneSecTimer = new Timer.periodic(Duration(seconds: 1), (Timer t) => _refreshTctClock());
    super.initState();
  }

  @override
  void dispose() {
    _oneSecTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    TimeFormatSetting timePrefs = settingsProvider.currentTimeFormat;
    DateFormat formatter;
    switch (timePrefs) {
      case TimeFormatSetting.h24:
        formatter = DateFormat('HH:mm');
        break;
      case TimeFormatSetting.h12:
        formatter = DateFormat('hh:mm a');
        break;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(formatter.format(_currentTctTime)),
        Text('TCT'),
      ],
    );
  }

  void _refreshTctClock() {
    setState(() {
      _currentTctTime = DateTime.now().toUtc();
    });
  }
}