import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:intl/intl.dart';

import '../modal_bottom_sheets/archived_gift_options_bottom_sheet.dart';

import '/models/archived_gift.dart';

class ArchiveCard extends StatefulWidget {
  final int contactBoxPosition;
  final ArchivedGift archivedGift;

  const ArchiveCard({
    Key? key,
    required this.contactBoxPosition,
    required this.archivedGift,
  }) : super(key: key);

  @override
  State<ArchiveCard> createState() => _ArchiveCardState();
}

class _ArchiveCardState extends State<ArchiveCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: Card(
        color: const Color(0x0fffffff),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      widget.archivedGift.giftname,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => showCupertinoModalBottomSheet(
                    context: context,
                    builder: (context) => ArchivedGiftOptionsBottomSheet(contactBoxPosition: widget.contactBoxPosition, archivedGiftIndex: widget.archivedGift.index),
                  ),
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 8.0, 0.0, 14.0),
              child: Text(
                // TODO kann dies besser gemacht werden anstatt auf 'null' zu prüfen?
                '${widget.archivedGift.eventname} ${widget.archivedGift.eventDate == 'null' ? '' : '• ${DateFormat('dd.MM.yyyy').format(DateTime.parse(widget.archivedGift.eventDate))}'}',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 8.0, 0.0, 14.0),
              child: Text(
                widget.archivedGift.note.isEmpty ? 'Notiz: - ' : 'Notiz: ${widget.archivedGift.note}',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
