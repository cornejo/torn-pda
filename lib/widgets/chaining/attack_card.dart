import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:torn_pda/models/chaining/attack_model.dart';
import 'package:torn_pda/providers/settings_provider.dart';
import 'package:torn_pda/providers/targets_provider.dart';
import 'package:torn_pda/providers/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../webviews/webview_generic.dart';

class AttackCard extends StatefulWidget {
  final Attack attackModel;

  AttackCard({@required this.attackModel});

  @override
  _AttackCardState createState() => _AttackCardState();
}

class _AttackCardState extends State<AttackCard> {
  Attack _attack;
  ThemeProvider _themeProvider;
  SettingsProvider _settingsProvider;

  @override
  Widget build(BuildContext context) {
    _attack = widget.attackModel;
    _themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // LINE 1
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(15, 5, 15, 0),
              child: Row(
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: IconButton(
                          padding: EdgeInsets.all(0.0),
                          iconSize: 20,
                          icon: Icon(
                            Icons.remove_red_eye,
                          ),
                          onPressed: () async {
                            var browserType = _settingsProvider.currentBrowser;
                            switch (browserType) {
                              case BrowserSetting.app:
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          TornWebViewGeneric(
                                            profileId: '${_attack.targetId}',
                                            profileName: _attack.targetName,
                                            webViewType: WebViewType.profile,
                                          )),
                                );
                                break;
                              case BrowserSetting.external:
                                var url = 'https://www.torn.com/profiles.php?'
                                    'XID=${_attack.targetId}';
                                if (await canLaunch(url)) {
                                  await launch(url, forceSafariVC: false);
                                }
                                break;
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text(
                          '${_attack.targetName}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        SizedBox(
                          width: 85,
                          child: Text(
                            ' [${_attack.targetId}]',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _returnTargetLevel(),
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: _returnAddTargetButton(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // LINE 2
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(15, 5, 15, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(_returnDateFormatted()),
                  _returnRespect(),
                ],
              ),
            ),
            // LINE 3
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(15, 5, 15, 0),
              child: Row(
                children: <Widget>[
                  Text('Last results: '),
                  _returnLastResults(),
                ],
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _returnAddTargetButton() {
    bool existingTarget = false;

    var targetsProvider = Provider.of<TargetsProvider>(context, listen: false);
    var targetList = targetsProvider.allTargets;
    for (var tar in targetList) {
      if (tar.playerId.toString() == _attack.targetId) {
        existingTarget = true;
      }
    }

    if (existingTarget) {
      return IconButton(
        padding: EdgeInsets.all(0.0),
        iconSize: 20,
        icon: Icon(
          Icons.remove_circle_outline,
          color: Colors.red,
        ),
        onPressed: () {
          targetsProvider.deleteTargetById(_attack.targetId);
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('Removed ${_attack.targetName}!'),
              action: SnackBarAction(
                label: 'UNDO',
                textColor: Colors.orange,
                onPressed: () {
                  targetsProvider.restoredDeleted();
                  // Update the button
                  setState(() {});
                },
              ),
            ),
          );
          // Update the button
          setState(() {});
        },
      );
    } else {
      return IconButton(
        padding: EdgeInsets.all(0.0),
        iconSize: 20,
        icon: Icon(
          Icons.add_circle_outline,
          color: Colors.green,
        ),
        onPressed: () async {
          AddTargetResult tryAddTarget =
              await targetsProvider.addTarget(_attack.targetId);
          if (tryAddTarget.success) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                duration: Duration(seconds: 1),
                content: Text(
                  'Added ${tryAddTarget.targetName} '
                  '[${tryAddTarget.targetId}]',
                ),
              ),
            );
            // Update the button
            setState(() {});
          } else if (!tryAddTarget.success) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  'Error adding ${_attack.targetId}.'
                  ' ${tryAddTarget.errorReason}',
                ),
              ),
            );
          }
        },
      );
    }
  }

  Widget _returnTargetLevel() {
    if (_attack.attackInitiated) {
      if (_attack.attackWon) {
        return Text('Level ${_attack.targetLevel}');
      } else {
        return Text('[lost]',
            style: TextStyle(
              fontSize: 13,
              color: Colors.red,
            ));
      }
    } else {
      if (_attack.attackWon) {
        return Text('[lost]',
            style: TextStyle(
              fontSize: 13,
              color: Colors.red,
            ));
      } else {
        return Text(
          '[defended]',
          style: TextStyle(fontSize: 13),
        );
      }
    }
  }

  String _returnDateFormatted() {
    var date =
        new DateTime.fromMillisecondsSinceEpoch(_attack.timestampEnded * 1000);
    var formatter = new DateFormat('dd MMMM HH:mm');
    return formatter.format(date);
  }

  Widget _returnRespect() {
    dynamic respect = _attack.respectGain;
    if (respect is String) {
      respect = double.parse(respect);
    }

    TextSpan respectSpan;
    if ((_attack.attackInitiated && !_attack.attackWon) ||
        (!_attack.attackInitiated && _attack.attackWon)) {
      // If we attacked and lost, or someone attacked us and won
      // we just show '0' but in red to indicate that we lost
      respectSpan = TextSpan(
        text: '0',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (_attack.attackInitiated && _attack.attackWon) {
      // If we attacked and won, we show the actual respect
      respectSpan = TextSpan(
        text: respect.toStringAsFixed(2),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _themeProvider.mainText,
        ),
      );
    } else {
      // Else (if someone attacked and lost (we defended successfully), we
      // don't gain any respect at all
      respectSpan = TextSpan(
        text: '0',
        style: TextStyle(
          color: _themeProvider.mainText,
        ),
      );
    }

    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: 'Respect: ',
            style: TextStyle(
              color: _themeProvider.mainText,
            ),
          ),
          respectSpan,
        ],
      ),
    );
  }

  Widget _returnLastResults() {
    var results = List<Widget>();

    Widget firstResult = Padding(
      padding: EdgeInsets.only(left: 3, right: 8, top: 1),
      child: Container(
        width: 13,
        height: 13,
        decoration: BoxDecoration(
            color: _attack.attackSeriesGreen[0] ? Colors.green : Colors.red,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black)),
      ),
    );

    results.add(firstResult);

    if (_attack.attackSeriesGreen.length > 1) {
      for (var i = 1; i < _attack.attackSeriesGreen.length; i++) {
        if (i == 10) {
          break;
        }

        Widget anotherResult = Padding(
          padding: EdgeInsets.only(right: 5, top: 2),
          child: Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
                color: _attack.attackSeriesGreen[i] ? Colors.green : Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black)),
          ),
        );

        results.add(anotherResult);
      }
    }

    return Row(children: results);
  }
}