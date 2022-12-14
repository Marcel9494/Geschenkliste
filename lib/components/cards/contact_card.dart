import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../modal_bottom_sheets/contact_options_bottom_sheet.dart';

import '/models/contact.dart';
import '/models/screen_arguments/archive_screen_arguments.dart';

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
  String birthdayString = '';

  @override
  initState() {
    super.initState();
    DateFormat dateFormatter = DateFormat('EE, dd. LLL.', 'de');
    birthdayString = widget.contact.nextBirthday != null && widget.contact.nextBirthday!.year != 0 ? dateFormatter.format(widget.contact.nextBirthday!) : '-';
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.only(left: 6.0),
        child: GestureDetector(
          onTap: () => {
            Navigator.pushNamed(context, '/archive', arguments: ArchiveScreenArguments(widget.contact)),
            FocusScope.of(context).unfocus(),
          },
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
                  padding: const EdgeInsets.fromLTRB(20.0, 16.0, 0.0, 14.0),
                  child: widget.contact.birthday != null
                      ? Text(
                          '${widget.contact.birthdayAge}. Geburtstag am $birthdayString',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        )
                      : const Text(
                          'Geburtstag: -',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
