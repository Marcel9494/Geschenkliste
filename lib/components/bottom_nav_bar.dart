import 'package:flutter/material.dart';

import '/models/screen_arguments/create_gift_screen_arguments.dart';

import '/screens/gift_list_screen.dart';
import '/screens/contact_list_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  static List<Widget> _screens = [];
  int _selectedIndex = 0;

  @override
  initState() {
    super.initState();
    _screens = <Widget>[
      const GiftListScreen(),
      const ContactListScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/createOrEditGift', arguments: CreateGiftScreenArguments(-1)),
        child: const Icon(
          Icons.add_rounded,
          size: 28.0,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard_rounded),
            label: 'Geschenkliste',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts_rounded),
            label: 'Kontakte',
          ),
        ],
      ),
    );
  }
}
