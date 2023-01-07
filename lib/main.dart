import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '/screens/archive_screen.dart';
import '/screens/settings_screen.dart';
import '/screens/gift_list_screen.dart';
import '/screens/contact_list_screen.dart';
import '/screens/edit_archived_gift_screen.dart';
import '/screens/create_or_edit_gift_screen.dart';
import '/screens/create_or_edit_contact_screen.dart';

import '/components/bottom_nav_bar.dart';

import '/models/gift.dart';
import '/models/event.dart';
import '/models/contact.dart';
import '/models/screen_arguments/create_contact_screen_arguments.dart';
import '/models/screen_arguments/create_gift_screen_arguments.dart';
import '/models/screen_arguments/archive_screen_arguments.dart';
import '/models/screen_arguments/archived_gift_screen_arguments.dart';
import '/models/screen_arguments/bottom_nav_bar_screen_arguments.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ContactAdapter());
  Hive.registerAdapter(EventAdapter());
  Hive.registerAdapter(GiftAdapter());
  // Auskommentieren zum Daten löschen oder App deinstallieren
  // var contactBox = await Hive.openBox('gifts');
  // await Hive.box('gifts').deleteFromDisk();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Geschenkliste',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF171717),
        appBarTheme: const AppBarTheme(
          color: Color(0xFF171717),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Colors.cyanAccent,
          onPrimary: Colors.black87,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            primary: Colors.cyanAccent,
          ),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de'),
      ],
      debugShowCheckedModeBanner: false,
      home: const BottomNavBar(selectedBottomNavBarIndex: 0),
      routes: {
        '/giftList': (context) => const GiftListScreen(),
        '/contactList': (context) => const ContactListScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/bottomNavBar':
            final args = settings.arguments as BottomNavBarScreenArguments;
            return MaterialPageRoute<String>(
              builder: (BuildContext context) => BottomNavBar(
                selectedBottomNavBarIndex: args.selectedBottomNavBarIndex,
              ),
              settings: settings,
            );
          case '/createOrEditContact':
            final args = settings.arguments as CreateContactScreenArguments;
            return MaterialPageRoute<String>(
              builder: (BuildContext context) => CreateOrEditContactScreen(
                contactBoxPosition: args.contactBoxPosition,
                backToCreateGiftScreen: args.backToCreateGiftScreen,
                callback: args.callback,
              ),
              settings: settings,
            );
          case '/createOrEditGift':
            final args = settings.arguments as CreateGiftScreenArguments;
            return MaterialPageRoute<String>(
              builder: (BuildContext context) => CreateOrEditGiftScreen(
                giftBoxPosition: args.giftBoxPosition,
              ),
              settings: settings,
            );
          case '/archive':
            final args = settings.arguments as ArchiveScreenArguments;
            return MaterialPageRoute<String>(
              builder: (BuildContext context) => ArchiveScreen(
                contact: args.contact,
              ),
              settings: settings,
            );
          case '/editArchivedGift':
            final args = settings.arguments as ArchivedGiftScreenArguments;
            return MaterialPageRoute<String>(
              builder: (BuildContext context) => EditArchivedGiftScreen(
                contactBoxPosition: args.contactBoxPosition,
                archivedGiftIndex: args.archivedGiftIndex,
              ),
              settings: settings,
            );
          default:
            return null;
        }
      },
    );
  }
}
