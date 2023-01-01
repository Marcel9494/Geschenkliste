import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '/models/contact.dart';
import '/models/screen_arguments/archive_screen_arguments.dart';
import '/models/screen_arguments/archived_gift_screen_arguments.dart';

class ArchivedGiftOptionsBottomSheet extends StatefulWidget {
  final int contactBoxPosition;
  final int archivedGiftIndex;
  final Contact contact;

  const ArchivedGiftOptionsBottomSheet({
    Key? key,
    required this.contactBoxPosition,
    required this.archivedGiftIndex,
    required this.contact,
  }) : super(key: key);

  @override
  State<ArchivedGiftOptionsBottomSheet> createState() => _ArchivedGiftOptionsBottomSheetState();
}

class _ArchivedGiftOptionsBottomSheetState extends State<ArchivedGiftOptionsBottomSheet> {
  void _showDeleteGiftDialog() {
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
                _deleteArchivedGift(),
                Navigator.pop(context),
                Navigator.pop(context),
                Navigator.popAndPushNamed(context, '/archive', arguments: ArchiveScreenArguments(widget.contact)),
              },
              child: const Text('Ja'),
            ),
          ],
        );
      },
    );
  }

  void _deleteArchivedGift() async {
    var contactBox = await Hive.openBox('contacts');
    Contact currentContact = contactBox.getAt(widget.contactBoxPosition);
    for (int i = 0; i < currentContact.archivedGiftsData.length; i++) {
      if (widget.archivedGiftIndex == i) {
        currentContact.archivedGiftsData.removeAt(i);
        setState(() {
          contactBox.putAt(widget.contactBoxPosition, currentContact);
        });
        break;
      }
    }
  }

  void _editArchievedGiftNote() {
    Navigator.popAndPushNamed(
      context,
      '/editArchivedGift',
      arguments: ArchivedGiftScreenArguments(
        widget.contactBoxPosition,
        widget.archivedGiftIndex,
      ),
    );
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
                child: Text('Archiviertes Geschenk:', style: TextStyle(fontSize: 16.0)),
              ),
            ),
            const Divider(height: 0, color: Colors.grey),
            ListTile(
              onTap: _editArchievedGiftNote,
              leading: const Icon(Icons.edit_note_rounded, color: Colors.cyanAccent),
              title: const Text('Notiz bearbeiten'),
            ),
            const Divider(height: 0, color: Colors.grey),
            ListTile(
              onTap: _showDeleteGiftDialog,
              leading: const Icon(Icons.delete_forever_rounded, color: Colors.cyanAccent),
              title: const Text('Löschen'),
            ),
          ],
        ),
      ),
    );
  }
}
