import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '/models/contact.dart';
import '/models/screen_arguments/archive_screen_arguments.dart';
import '/models/screen_arguments/create_contact_screen_arguments.dart';

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
    Navigator.pushNamed(context, '/createOrEditContact', arguments: CreateContactScreenArguments(widget.contactBoxPosition));
    FocusScope.of(context).unfocus();
  }

  void _deleteContact() async {
    var contactBox = await Hive.openBox('contacts');
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
                Navigator.pop(context),
                Navigator.popAndPushNamed(context, '/bottomNavBar'),
                FocusScope.of(context).unfocus(),
              },
              child: const Text('Ja'),
            ),
          ],
        );
      },
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
              leading: const Icon(Icons.delete_rounded, color: Colors.cyanAccent),
              title: const Text('Löschen'),
            ),
          ],
        ),
      ),
    );
  }
}
