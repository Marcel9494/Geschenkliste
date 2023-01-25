import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:settings_ui/settings_ui.dart';

import '/models/screen_arguments/bottom_nav_bar_screen_arguments.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _showDeleteAllDataDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Alle Daten löschen?'),
          content: const Text('Wollen Sie wirklich alle Daten löschen?\nDie gelöschten Daten können nicht wiederhergestellt werden!'),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Nein',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                onPrimary: Colors.black87,
              ),
              onPressed: () => {
                _deleteAllData(),
              },
              child: const Text('Ja'),
            ),
          ],
        );
      },
    );
  }

  void _deleteAllData() {
    Hive.deleteFromDisk();
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.popAndPushNamed(context, '/bottomNavBar', arguments: BottomNavBarScreenArguments(0));
  }

  void _showImpressumDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Impressum'),
          content: const Text('MDM Studio\n\nE-Mail Adresse:\nMarcel.Geirhos@gmail.com'),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.cyanAccent,
                onPrimary: Colors.black87,
              ),
              child: const Text('OK'),
              onPressed: () => {
                Navigator.pop(context),
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('Konto'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.delete_forever_rounded),
                title: const Text('Alle Daten löschen'),
                description: const Text('Gelöschte Daten können nicht wiederhergestellt werden.'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16.0),
                onPressed: (_) => {
                  _showDeleteAllDataDialog(),
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Rechtliches'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.privacy_tip_rounded),
                title: const Text('Datenschutzerklärung'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16.0),
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.art_track_rounded),
                title: const Text('Impressum'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16.0),
                onPressed: (_) => _showImpressumDialog(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
