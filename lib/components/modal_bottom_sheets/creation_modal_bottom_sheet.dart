import 'package:flutter/material.dart';

import '/models/screen_arguments/create_gift_screen_arguments.dart';
import '/models/screen_arguments/create_contact_screen_arguments.dart';

class CreationModalBottomSheet extends StatefulWidget {
  const CreationModalBottomSheet({Key? key}) : super(key: key);

  @override
  State<CreationModalBottomSheet> createState() => _CreationModalBottomSheetState();
}

class _CreationModalBottomSheetState extends State<CreationModalBottomSheet> {
  void _showCreateGiftScreen() {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/createOrEditGift', arguments: CreateGiftScreenArguments(-1));
  }

  void _showCreateContactScreen() {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/createOrEditContact', arguments: CreateContactScreenArguments(-1));
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
                child: Text('Erstellen:', style: TextStyle(fontSize: 16.0)),
              ),
            ),
            const Divider(height: 0, color: Colors.grey),
            ListTile(
              onTap: _showCreateGiftScreen,
              leading: const Icon(Icons.card_giftcard_rounded, color: Colors.cyanAccent),
              title: const Text('Geschenk'),
            ),
            const Divider(height: 0, color: Colors.grey),
            ListTile(
              onTap: _showCreateContactScreen,
              leading: const Icon(Icons.contacts_rounded, color: Colors.cyanAccent),
              title: const Text('Kontakt'),
            ),
          ],
        ),
      ),
    );
  }
}
