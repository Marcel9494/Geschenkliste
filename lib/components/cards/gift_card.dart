import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../models/contact.dart';
import '../../models/enums/gift_state.dart';
import '../modal_bottom_sheets/gift_options_bottom_sheet.dart';

import '../buttons/state_button.dart';

import '/models/gift.dart';

class GiftCard extends StatefulWidget {
  final Gift gift;

  const GiftCard({
    Key? key,
    required this.gift,
  }) : super(key: key);

  @override
  State<GiftCard> createState() => _GiftCardState();
}

class _GiftCardState extends State<GiftCard> {
  List<bool> isGiftStateSelected = [false, false, false, false];

  @override
  initState() {
    super.initState();
    getCurrentGiftState();
  }

  void getCurrentGiftState() async {
    var giftBox = await Hive.openBox('gifts');
    Gift gift = giftBox.getAt(widget.gift.boxPosition);
    for (int i = 0; i < isGiftStateSelected.length; i++) {
      if (gift.giftState == GiftStatus.values[i].name) {
        isGiftStateSelected[i] = true;
      } else {
        isGiftStateSelected[i] = false;
      }
    }
    setState(() {});
  }

  void updateGiftState(String newGiftState) async {
    var giftBox = await Hive.openBox('gifts');
    var updatedGift = Gift()
      ..giftname = widget.gift.giftname
      ..contact = widget.gift.contact
      ..giftState = newGiftState
      ..note = widget.gift.note
      ..event = widget.gift.event;
    giftBox.putAt(widget.gift.boxPosition, updatedGift);
  }

  void _showNotes() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Notizen'),
          content: Text(widget.gift.note),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.cyanAccent,
                onPrimary: Colors.black87,
              ),
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
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
    Gift currentGift = giftBox.getAt(widget.gift.boxPosition);
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
          giftBox.deleteAt(widget.gift.boxPosition);
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.only(left: 6.0),
        child: Card(
          color: const Color(0x0fffffff),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        widget.gift.giftname,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _showNotes(),
                    icon: const Icon(Icons.event_note_rounded),
                  ),
                  IconButton(
                    onPressed: () => showCupertinoModalBottomSheet(
                      context: context,
                      builder: (context) => GiftOptionsBottomSheet(giftBoxPosition: widget.gift.boxPosition),
                    ),
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6.0, left: 20.0, bottom: 2.0),
                child: Text('Für ${widget.gift.contact.contactname}'),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 18.0, left: 20.0, bottom: 12.0),
                child: Text(widget.gift.event.eventname),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ToggleButtons(
                    onPressed: (int index) {
                      setState(() {
                        for (int i = 0; i < isGiftStateSelected.length; i++) {
                          isGiftStateSelected[i] = i == index;
                          if (i == index) {
                            updateGiftState(GiftStatus.values[i].name);
                          }
                        }
                        if (isGiftStateSelected[3]) {
                          _showArchiveGiftDialog();
                        }
                      });
                    },
                    isSelected: isGiftStateSelected,
                    selectedColor: Colors.cyanAccent,
                    selectedBorderColor: Colors.cyanAccent,
                    borderRadius: BorderRadius.circular(4.0),
                    constraints: const BoxConstraints(minHeight: 36),
                    children: <Widget>[
                      StateButton(
                        text: 'Idee',
                        icon: Icons.tips_and_updates_rounded,
                        isSelected: isGiftStateSelected[0],
                      ),
                      StateButton(
                        text: 'Gekauft',
                        icon: Icons.shopping_cart,
                        isSelected: isGiftStateSelected[1],
                      ),
                      StateButton(
                        text: 'Verpackt',
                        icon: Icons.card_giftcard_rounded,
                        isSelected: isGiftStateSelected[2],
                      ),
                      StateButton(
                        text: 'Geschenkt',
                        icon: Icons.volunteer_activism_rounded,
                        isSelected: isGiftStateSelected[3],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
