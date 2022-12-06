import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '/models/gift.dart';
import '/models/contact.dart';
import '/models/screen_arguments/create_gift_screen_arguments.dart';

class GiftOptionsBottomSheet extends StatefulWidget {
  final int giftBoxPosition;

  const GiftOptionsBottomSheet({
    Key? key,
    required this.giftBoxPosition,
  }) : super(key: key);

  @override
  State<GiftOptionsBottomSheet> createState() => _GiftOptionsBottomSheetState();
}

class _GiftOptionsBottomSheetState extends State<GiftOptionsBottomSheet> {
  void _showEditGiftScreen() {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/createOrEditGift', arguments: CreateGiftScreenArguments(widget.giftBoxPosition));
  }

  void _showDeleteGiftDialog() async {
    var giftBox = await Hive.openBox('gifts');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Geschenk löschen?'),
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
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.cyanAccent,
                onPrimary: Colors.black87,
              ),
              onPressed: () => {
                setState(() {
                  giftBox.deleteAt(widget.giftBoxPosition);
                }),
                Navigator.pop(context),
                Navigator.pop(context),
                Navigator.popAndPushNamed(context, '/bottomNavBar'),
              },
              child: const Text('Ja'),
            ),
          ],
        );
      },
    );
  }

  void _showArchiveGiftDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Geschenk archivieren?'),
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
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.cyanAccent,
                onPrimary: Colors.black87,
              ),
              child: const Text('Ja'),
              onPressed: () => {
                _archiveGift(),
                Navigator.pop(context),
                Navigator.popAndPushNamed(context, '/bottomNavBar'),
              },
            ),
          ],
        );
      },
    );
  }

  void _archiveGift() async {
    List<Contact> contacts = [];
    var contactBox = await Hive.openBox('contacts');
    var giftBox = await Hive.openBox('gifts');
    Gift gift = giftBox.getAt(widget.giftBoxPosition);
    for (int i = 0; i < contactBox.length; i++) {
      contacts.add(contactBox.getAt(i));
      if (contacts[i].contactname == gift.contact.contactname) {
        // Hive unterstützt aktuell (Stand: 03.12.22) keine Liste von Objekten und kann diese nicht persistent speichern,
        // deshalb wird hier eine String Datenstruktur verwendet um die archivierten Geschenkdaten zu speichern.
        // Open Hive Issue on Github: https://github.com/hivedb/hive/issues/837
        String archivedGiftsDataString = '${gift.giftname};${gift.event.eventname};${gift.event.eventDate};${gift.note};${gift.giftState}';
        contacts[i].archivedGiftsData.add(archivedGiftsDataString);
        contactBox.putAt(i, contacts[i]);
        setState(() {
          giftBox.deleteAt(widget.giftBoxPosition);
        });
        break;
      }
    }
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
                child: Text('Geschenk:', style: TextStyle(fontSize: 16.0)),
              ),
            ),
            const Divider(height: 0, color: Colors.grey),
            ListTile(
              onTap: _showEditGiftScreen,
              leading: const Icon(Icons.edit_rounded, color: Colors.cyanAccent),
              title: const Text('Bearbeiten'),
            ),
            const Divider(height: 0, color: Colors.grey),
            ListTile(
              onTap: _showDeleteGiftDialog,
              leading: const Icon(Icons.delete_rounded, color: Colors.cyanAccent),
              title: const Text('Löschen'),
            ),
            const Divider(height: 0, color: Colors.grey),
            ListTile(
              onTap: _showArchiveGiftDialog,
              leading: const Icon(Icons.archive_rounded, color: Colors.cyanAccent),
              title: const Text('Archivieren'),
            ),
          ],
        ),
      ),
    );
  }
}
