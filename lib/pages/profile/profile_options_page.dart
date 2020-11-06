import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:torn_pda/pages/profile/shortcuts_page.dart';
import 'package:torn_pda/providers/settings_provider.dart';
import 'package:torn_pda/providers/theme_provider.dart';
import 'package:torn_pda/utils/shared_prefs.dart';

class ProfileOptionsReturn {
  bool nukeReviveEnabled;
  bool warnAboutChainsEnabled;
  bool shortcutsEnabled;
}

class ProfileOptionsPage extends StatefulWidget {
  @override
  _ProfileOptionsPageState createState() => _ProfileOptionsPageState();
}

class _ProfileOptionsPageState extends State<ProfileOptionsPage> {
  bool _nukeReviveEnabled = true;
  bool _warnAboutChainsEnabled = true;
  bool _shortcutsEnabled = true;

  Future _preferencesLoaded;

  ThemeProvider _themeProvider;
  SettingsProvider _settingsProvider;

  @override
  void initState() {
    super.initState();
    _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _preferencesLoaded = _restorePreferences();
  }

  @override
  Widget build(BuildContext context) {
    _themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: SafeArea(
        bottom: true,
        child: Scaffold(
          appBar: _settingsProvider.appBarTop ? buildAppBar() : null,
          bottomNavigationBar: !_settingsProvider.appBarTop
              ? SizedBox(
                  height: AppBar().preferredSize.height,
                  child: buildAppBar(),
                )
              : null,
          body: Builder(
            builder: (BuildContext context) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () =>
                    FocusScope.of(context).requestFocus(new FocusNode()),
                child: FutureBuilder(
                  future: _preferencesLoaded,
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'SHORTCUTS',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text("Enable shortcuts"),
                                  Switch(
                                    value: _shortcutsEnabled,
                                    onChanged: (value) {
                                      SharedPreferencesModel()
                                          .setEnableShortcuts(value);
                                      setState(() {
                                        _shortcutsEnabled = value;
                                      });
                                    },
                                    activeTrackColor: Colors.lightGreenAccent,
                                    activeColor: Colors.green,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                'Enable configurable shortcuts in the Profile section to '
                                'quickly access your favourite sections in game. '
                                'Tip: short-press shortcuts to open a small browser '
                                'window, long-press to open a full browser with app bar',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "Configure shortcuts",
                                    style: TextStyle(
                                      color: _shortcutsEnabled
                                          ? _themeProvider.mainText
                                          : Colors.grey,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                        Icons.keyboard_arrow_right_outlined),
                                    color: _shortcutsEnabled
                                        ? _themeProvider.mainText
                                        : Colors.grey,
                                    onPressed: _shortcutsEnabled
                                        ? () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        ShortcutsPage(),
                                              ),
                                            );
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 15),
                            Divider(),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'CHAINING',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text("Warn about chains"),
                                  Switch(
                                    value: _warnAboutChainsEnabled,
                                    onChanged: (value) {
                                      SharedPreferencesModel()
                                          .setWarnAboutChains(value);
                                      setState(() {
                                        _warnAboutChainsEnabled = value;
                                      });
                                    },
                                    activeTrackColor: Colors.lightGreenAccent,
                                    activeColor: Colors.green,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                'If active, you\'ll get a message and a chain icon to the side of '
                                'the energy bar, so that you avoid spending energy in the gym '
                                'if you are unaware that your faction is chaining',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            Divider(),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'REVIVING SERVICES',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text("Use Nuke Reviving Services"),
                                  Switch(
                                    value: _nukeReviveEnabled,
                                    onChanged: (value) {
                                      SharedPreferencesModel()
                                          .setUseNukeRevive(value);
                                      setState(() {
                                        _nukeReviveEnabled = value;
                                      });
                                    },
                                    activeTrackColor: Colors.lightGreenAccent,
                                    activeColor: Colors.green,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                'If active, when you are in hospital you\'ll have the option to call '
                                'a reviver from Central Hospital. NOTE: this is an external '
                                'service not affiliated to Torn PDA. It\'s here so that it is '
                                'more accessible!',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            SizedBox(height: 50),
                          ],
                        ),
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text("Profile Options"),
      leading: new IconButton(
        icon: new Icon(Icons.arrow_back),
        onPressed: () {
          _willPopCallback();
        },
      ),
    );
  }

  Future _restorePreferences() async {
    var useNuke = await SharedPreferencesModel().getUseNukeRevive();
    var warnChains = await SharedPreferencesModel().getWarnAboutChains();
    var shortcuts = await SharedPreferencesModel().getEnableShortcuts();

    setState(() {
      _nukeReviveEnabled = useNuke;
      _warnAboutChainsEnabled = warnChains;
      _shortcutsEnabled = shortcuts;
    });
  }

  Future<bool> _willPopCallback() async {
    Navigator.of(context).pop(
      ProfileOptionsReturn()
        ..nukeReviveEnabled = _nukeReviveEnabled
        ..warnAboutChainsEnabled = _warnAboutChainsEnabled
        ..shortcutsEnabled = _shortcutsEnabled,
    );
    return true;
  }
}
