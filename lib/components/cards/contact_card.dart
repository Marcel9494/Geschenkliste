import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../models/screen_arguments/archive_screen_arguments.dart';
import '../modal_bottom_sheets/contact_options_bottom_sheet.dart';

import '/models/contact.dart';

class ContactCard extends StatefulWidget {
  final Contact contact;

  const ContactCard({
    Key? key,
    required this.contact,
  }) : super(key: key);

  @override
  State<ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<ContactCard> {
  String? selectedMenuItem;
  late DateFormat dateFormatter;
  String birthdayString = '';
  String yearOfBirthString = '';

  @override
  initState() {
    super.initState();
    dateFormatter = DateFormat('EE dd.MM.yy', 'de');
    birthdayString = widget.contact.nextBirthday != null && widget.contact.nextBirthday!.year != 0 ? dateFormatter.format(widget.contact.nextBirthday!) : '-';
    yearOfBirthString = widget.contact.birthday != null ? widget.contact.birthday!.year.toString() : '';
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.only(left: 6.0),
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/archive', arguments: ArchiveScreenArguments(widget.contact)),
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
                          widget.contact.contactname,
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
                        builder: (context) => ContactOptionsBottomSheet(contactBoxPosition: widget.contact.boxPosition),
                      ),
                      icon: const Icon(Icons.more_vert),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 8.0, 0.0, 14.0),
                  child: widget.contact.birthday != null ? Text('${widget.contact.birthdayAge}. Geburtstag am $birthdayString') : const Text('Geburtstag: -'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
