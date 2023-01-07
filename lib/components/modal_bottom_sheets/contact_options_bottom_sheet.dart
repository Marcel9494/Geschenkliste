import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:another_flushbar/flushbar.dart';

import '/models/gift.dart';
import '/models/contact.dart';
import '/models/screen_arguments/archive_screen_arguments.dart';
import '/models/screen_arguments/create_contact_screen_arguments.dart';
import '/models/screen_arguments/bottom_nav_bar_screen_arguments.dart';

class ContactOptionsBottomSheet extends StatefulWidget {
  final int contactBoxPosition;

  const ContactOptionsBottomSheet({
    Key? key,
    required this.contactBoxPosition,
  }) : super(key: key);

  @override
  State<ContactOptionsBottomSheet> createState() => _ContactOptionsBottomSheetState();
}

class _ContactOptionsBottomSheetState extends State<ContactOptionsBottomSheet> {
  List<int> giftBoxPositionsToDelete = [];
  int numberOfGifts = 0;
  bool contactHasGifts = false;

  void _getContactAndShowArchiveScreen() async {
    var contactBox = await Hive.openBox('contacts');
    Contact contact = contactBox.getAt(widget.contactBoxPosition);
    _navigateToArchiveScreen(contact);
  }

  void _navigateToArchiveScreen(Contact contact) {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/archive', arguments: ArchiveScreenArguments(contact));
    FocusScope.of(context).unfocus();
  }

  void _showEditContactScreen() {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/createOrEditContact', arguments: CreateContactScreenArguments(widget.contactBoxPosition, false, () => {}));
    FocusScope.of(context).unfocus();
  }

  void _deleteContact() async {
    var contactBox = await Hive.openBox('contacts');
    var giftBox = await Hive.openBox('gifts');
    Contact contact = contactBox.getAt(widget.contactBoxPosition);
    if (_checkIfContactHasGifts(contact, giftBox)) {
      _showDeleteContactAndGiftsDialog(contact.contactname);
    } else {
      _showDeleteContactDialog();
    }
  }

  bool _checkIfContactHasGifts(Contact contact, var giftBox) {
    contactHasGifts = false;
    giftBoxPositionsToDelete = [];
    for (int i = 0; i < giftBox.length; i++) {
      Gift gift = giftBox.getAt(i);
      if (gift.contact.contactname == contact.contactname) {
        contactHasGifts = true;
        giftBoxPositionsToDelete.add(i);
      }
    }
    return contactHasGifts;
  }

  void _showDeleteContactAndGiftsDialog(String contactname) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Kontakt und Geschenke löschen?'),
          content: Text(
              '$contactname hat noch ${giftBoxPositionsToDelete.length} Geschenke auf der Geschenkliste. Damit der Kontakt gelöscht werden kann müssen alle Geschenke gelöscht werden. Willst du alle Geschenke von $contactname löschen?'),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Nein',
                style: TextStyle(
                  color: Colors.cyanAccent,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                FocusScope.of(context).unfocus();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.cyanAccent,
                onPrimary: Colors.black87,
              ),
              onPressed: () => {
                _deleteContactAndGifts(),
                Navigator.pop(context),
                Navigator.popAndPushNamed(context, '/bottomNavBar', arguments: BottomNavBarScreenArguments(1)),
                FocusScope.of(context).unfocus(),
              },
              child: const Text('Ja'),
            ),
          ],
        );
      },
    );
  }

  void _deleteContactAndGifts() async {
    var contactBox = await Hive.openBox('contacts');
    var giftBox = await Hive.openBox('gifts');
    Contact contact = contactBox.getAt(widget.contactBoxPosition);
    for (int i = giftBoxPositionsToDelete.length - 1; i >= 0; i--) {
      giftBox.deleteAt(giftBoxPositionsToDelete[i]);
    }
    contactBox.deleteAt(widget.contactBoxPosition);
    _showFlushbar('Alle Geschenke und Kontakt ${contact.contactname} wurde gelöscht.');
  }

  void _showDeleteContactDialog() async {
    var contactBox = await Hive.openBox('contacts');
    Contact contact = contactBox.getAt(widget.contactBoxPosition);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Kontakt löschen?'),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Nein',
                style: TextStyle(
                  color: Colors.cyanAccent,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                FocusScope.of(context).unfocus();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.cyanAccent,
                onPrimary: Colors.black87,
              ),
              onPressed: () => {
                setState(() {
                  contactBox.deleteAt(widget.contactBoxPosition);
                }),
                Navigator.pop(context),
                Navigator.popAndPushNamed(context, '/bottomNavBar', arguments: BottomNavBarScreenArguments(1)),
                FocusScope.of(context).unfocus(),
                _showFlushbar('Kontakt ${contact.contactname} wurde gelöscht.'),
              },
              child: const Text('Ja'),
            ),
          ],
        );
      },
    );
  }

  void _showFlushbar(String text) {
    Flushbar(
      message: text,
      icon: const Icon(
        Icons.info_outline,
        size: 28.0,
        color: Colors.cyanAccent,
      ),
      duration: const Duration(seconds: 4),
      leftBarIndicatorColor: Colors.cyanAccent,
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Material(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 4.0),
                child: Container(
                  width: 75,
                  height: 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16.0, bottom: 16.0, left: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: Text('Kontakt:', style: TextStyle(fontSize: 16.0)),
              ),
            ),
            const Divider(height: 0, color: Colors.grey),
            ListTile(
              onTap: _getContactAndShowArchiveScreen,
              leading: const Icon(Icons.archive_rounded, color: Colors.cyanAccent),
              title: const Text('Archiv'),
            ),
            const Divider(height: 0, color: Colors.grey),
            ListTile(
              onTap: _showEditContactScreen,
              leading: const Icon(Icons.edit_rounded, color: Colors.cyanAccent),
              title: const Text('Bearbeiten'),
            ),
            const Divider(height: 0, color: Colors.grey),
            ListTile(
              onTap: _deleteContact,
              leading: const Icon(Icons.delete_forever_rounded, color: Colors.cyanAccent),
              title: const Text('Löschen'),
            ),
          ],
        ),
      ),
    );
  }
}
