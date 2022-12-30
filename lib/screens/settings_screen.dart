import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('Allgemeines'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.send_rounded),
                title: const Text('Feedback senden'),
                description: const Text('Sende uns Feedback, Feature Wünsche oder Fehlerberichte.'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16.0),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Konto'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.delete_forever),
                title: const Text('Alle Daten löschen'),
                description: const Text('Gelöschte Daten können nicht wiederhergestellt werden.'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16.0),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Rechtliches'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.article_rounded),
                title: const Text('Allgemeine Geschäftsbedingungen'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16.0),
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.privacy_tip_rounded),
                title: const Text('Datenschutzerklärung'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16.0),
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.art_track_rounded),
                title: const Text('Impressum'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16.0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
