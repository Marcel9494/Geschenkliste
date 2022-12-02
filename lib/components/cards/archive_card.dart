import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '/models/gift.dart';

class ArchiveCard extends StatefulWidget {
  final Gift gift;

  const ArchiveCard({
    Key? key,
    required this.gift,
  }) : super(key: key);

  @override
  State<ArchiveCard> createState() => _ArchiveCardState();
}

class _ArchiveCardState extends State<ArchiveCard> {
  String? selectedMenuItem;
  String birthdayString = '';
  String yearOfBirthString = '';

  @override
  initState() {
    super.initState();
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
                    /*onPressed: () => showCupertinoModalBottomSheet(
                      context: context,
                      builder: (context) => ContactOptionsBottomSheet(contactBoxPosition: widget.contact.boxPosition),
                    ),*/
                    onPressed: () => {},
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 8.0, 0.0, 14.0),
                child: Text(widget.gift.event.eventDate.toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
