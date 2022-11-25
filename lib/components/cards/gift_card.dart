import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../modal_bottom_sheets/gift_options_bottom_sheet.dart';

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
  String? selectedMenuItem;

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

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.only(left: 6.0),
        child: Card(
          color: const Color(0xFF272727),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(widget.gift.giftname),
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
                padding: const EdgeInsets.only(left: 20.0, bottom: 14.0),
                child: Text('Für ${widget.gift.contact.contactname}'),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, bottom: 18.0),
                child: Row(
                  children: [
                    const Icon(Icons.event_rounded),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(widget.gift.event.eventname),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
