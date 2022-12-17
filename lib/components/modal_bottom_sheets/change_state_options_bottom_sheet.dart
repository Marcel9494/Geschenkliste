import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../models/contact.dart';
import '../../models/enums/gift_state.dart';
import '../../models/gift.dart';

typedef void StringCallback(String val);

class ChangeStateOptionsBottomSheet extends StatefulWidget {
  final int giftBoxPosition;
  final StringCallback updatedGiftStateCallback;

  const ChangeStateOptionsBottomSheet({
    Key? key,
    required this.giftBoxPosition,
    required this.updatedGiftStateCallback,
  }) : super(key: key);

  @override
  State<ChangeStateOptionsBottomSheet> createState() => _ChangeStateOptionsBottomSheetState();
}

class _ChangeStateOptionsBottomSheetState extends State<ChangeStateOptionsBottomSheet> {
  List<bool> isGiftStateSelected = [false, false, false, false];

  void _changeGiftState(int giftStateIndex) async {
    setState(() {
      for (int i = 0; i < isGiftStateSelected.length; i++) {
        isGiftStateSelected[i] = i == giftStateIndex;
        if (i == giftStateIndex) {
          updateGiftState(GiftStatus.values[i].name);
          widget.updatedGiftStateCallback(GiftStatus.values[i].name);
        }
      }
      if (isGiftStateSelected[3]) {
        _showArchiveGiftDialog();
      }
    });
    if (!isGiftStateSelected[3]) {
      Navigator.pop(context);
    }
  }

  void updateGiftState(String newGiftState) async {
    var giftBox = await Hive.openBox('gifts');
    Gift gift = giftBox.getAt(widget.giftBoxPosition);
    var updatedGift = Gift()
      ..giftname = gift.giftname
      ..contact = gift.contact
      ..giftState = newGiftState
      ..note = gift.note
      ..event = gift.event;
    giftBox.putAt(widget.giftBoxPosition, updatedGift);
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
                Navigator.pop(context),
                Navigator.popAndPushNamed(context, '/bottomNavBar'),
                _showArchievedSnackbar(),
              },
            ),
          ],
        );
      },
    );
  }

  void _showArchievedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Geschenk wurde archiviert',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.cyanAccent),
        ),
        backgroundColor: Color(0x0fffffff),
      ),
    );
  }

  void _archiveGift() async {
    List<Contact> contacts = [];
    var contactBox = await Hive.openBox('contacts');
    var giftBox = await Hive.openBox('gifts');
    Gift currentGift = giftBox.getAt(widget.giftBoxPosition);
    for (int i = 0; i < contactBox.length; i++) {
      contacts.add(contactBox.getAt(i));
      if (contacts[i].contactname == currentGift.contact.contactname) {
        // Hive unterstützt aktuell (Stand: 03.12.22) keine Liste von Objekten und kann diese nicht persistent speichern,
        // deshalb wird hier eine String Datenstruktur verwendet um die archivierten Geschenkdaten zu speichern.
        // Open Hive Issue on Github: https://github.com/hivedb/hive/issues/837
        String archivedGiftsDataString = '${currentGift.giftname};${currentGift.event.eventname};${currentGift.event.eventDate};${currentGift.note};${currentGift.giftState}';
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
                child: Text('Geschenk Status:', style: TextStyle(fontSize: 16.0)),
              ),
            ),
            const Divider(height: 0, color: Colors.grey),
            ListTile(
              onTap: () => _changeGiftState(0),
              leading: const Icon(Icons.tips_and_updates_rounded, color: Colors.cyanAccent),
              title: Text(GiftStatus.idea.name),
            ),
            const Divider(height: 0, color: Colors.grey),
            ListTile(
              onTap: () => _changeGiftState(1),
              leading: const Icon(Icons.shopping_cart, color: Colors.cyanAccent),
              title: Text(GiftStatus.bought.name),
            ),
            const Divider(height: 0, color: Colors.grey),
            ListTile(
              onTap: () => _changeGiftState(2),
              leading: const Icon(Icons.card_giftcard_rounded, color: Colors.cyanAccent),
              title: Text(GiftStatus.packed.name),
            ),
            const Divider(height: 0, color: Colors.grey),
            ListTile(
              onTap: () => _changeGiftState(3),
              leading: const Icon(Icons.volunteer_activism_rounded, color: Colors.cyanAccent),
              title: Text(GiftStatus.gifted.name),
            ),
          ],
        ),
      ),
    );
  }
}
