import 'package:flutter/material.dart';

import '/models/screen_arguments/create_gift_screen_arguments.dart';

import '/screens/gift_list_screen.dart';
import '/screens/contact_list_screen.dart';

class BottomNavBar extends StatefulWidget {
  final int selectedBottomNavBarIndex;

  const BottomNavBar({
    Key? key,
    required this.selectedBottomNavBarIndex,
  }) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  static List<Widget> _screens = [];
  late int _selectedIndex;

  @override
  initState() {
    super.initState();
    _selectedIndex = widget.selectedBottomNavBarIndex;
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
    bool showFab = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      floatingActionButton: Visibility(
        visible: !showFab,
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, '/createOrEditGift', arguments: CreateGiftScreenArguments(-1)),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.cyanAccent, Colors.cyan.shade700],
                ),
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 28.0,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        backgroundColor: const Color(0x0fffffff),
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
