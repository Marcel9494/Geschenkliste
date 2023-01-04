import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '/models/contact.dart';
import '/models/screen_arguments/create_contact_screen_arguments.dart';

import '/components/cards/day_card.dart';
import '/components/cards/contact_card.dart';
import '/components/texts/centered_text.dart';

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({Key? key}) : super(key: key);

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  final TextEditingController _searchedContactnameTextController = TextEditingController(text: '');
  late List<Contact> contacts = [];
  late DateFormat dateFormatter;

  @override
  initState() {
    super.initState();
    dateFormatter = DateFormat('LLLL', 'de');
  }

  Future<List<Contact>> _getContactList(String searchedContactname) async {
    int contactNumber = 0;
    var contactBox = await Hive.openBox('contacts');
    contacts.clear();
    for (int i = 0; i < contactBox.length; i++) {
      Contact contact = contactBox.getAt(i);
      if (contact.contactname.toLowerCase().contains(searchedContactname.toLowerCase())) {
        contacts.add(contactBox.getAt(i));
        contacts[contactNumber].remainingDays = contact.getRemainingDaysToBirthday();
        contacts[contactNumber].nextBirthday = contact.getNextBirthday();
        contacts[contactNumber].birthdayAge = contact.getBirthdayAge();
        contacts[contactNumber].boxPosition = contactNumber;
        contactNumber++;
      }
    }
    contacts.sort((first, second) => first.remainingDays.compareTo(second.remainingDays));
    return contacts;
  }

  void _clearSearchField() {
    _searchedContactnameTextController.text = '';
    _getContactList(_searchedContactnameTextController.text);
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF202020),
              Color(0xFF171717),
            ],
            stops: [0.0, 0.4],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 11.0, 0.0, 14.0),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 42.0,
                        child: TextFormField(
                          controller: _searchedContactnameTextController,
                          onChanged: (String searchedContactname) {
                            setState(() {
                              _getContactList(searchedContactname);
                            });
                          },
                          decoration: InputDecoration(
                            filled: true,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            fillColor: const Color(0x0fffffff),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14.0),
                              borderSide: BorderSide.none,
                            ),
                            hintText: 'Suchen...',
                            prefixIcon: const Icon(Icons.search_rounded, size: 24.0),
                            suffixIcon: _searchedContactnameTextController.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () => setState(() {
                                      _clearSearchField();
                                    }),
                                    icon: const Icon(Icons.cancel_outlined, size: 20.0),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => {
                        Navigator.pushNamed(context, '/createOrEditContact', arguments: CreateContactScreenArguments(-1, false)),
                        FocusScope.of(context).unfocus(),
                      },
                      icon: const Icon(
                        Icons.person_add_rounded,
                        size: 26.0,
                      ),
                    ),
                    IconButton(
                      onPressed: () => {
                        Navigator.pushNamed(context, '/settings'),
                        FocusScope.of(context).unfocus(),
                      },
                      icon: const Icon(Icons.settings_rounded),
                    ),
                  ],
                ),
              ),
              FutureBuilder<List<Contact>>(
                future: _getContactList(_searchedContactnameTextController.text),
                builder: (BuildContext context, AsyncSnapshot<List<Contact>> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
                    default:
                      if (snapshot.hasError) {
                        return const CenteredText(text: 'Kontakte konnten nicht geladen werden.', divider: 2);
                      } else {
                        if (contacts.isEmpty) {
                          return const CenteredText(text: 'Noch keine Kontakte vorhanden.', divider: 2);
                        } else {
                          return Expanded(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                contacts = await _getContactList(_searchedContactnameTextController.text);
                                setState(() {});
                                return;
                              },
                              color: Colors.cyanAccent,
                              child: ListView.builder(
                                itemCount: contacts.length,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(
                                    children: [
                                      index == 0
                                          ? Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.fromLTRB(120.0, 12.0, 0.0, 12.0),
                                                  child: Text(
                                                    '${contacts[0].nextBirthday!.year} • ${dateFormatter.format(contacts[0].nextBirthday!)}',
                                                    style: const TextStyle(
                                                      fontSize: 21.0,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : const SizedBox.shrink(),
                                      Row(
                                        children: [
                                          DayCard(days: contacts[index].remainingDays),
                                          ContactCard(contact: contacts[index]),
                                        ],
                                      ),
                                      index + 1 < contacts.length && contacts[index].nextBirthday != null && contacts[index + 1].nextBirthday != null
                                          ? contacts[index].nextBirthday?.month != contacts[index + 1].nextBirthday?.month
                                              ? Row(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.fromLTRB(120.0, 12.0, 0.0, 12.0),
                                                      child: Text(
                                                        contacts[index + 1].nextBirthday!.year == 0
                                                            ? 'Kein Geburtstag'
                                                            : '${contacts[index + 1].nextBirthday!.year} • ${dateFormatter.format(contacts[index + 1].nextBirthday!)}',
                                                        style: const TextStyle(
                                                          fontSize: 21.0,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : const SizedBox.shrink()
                                          : const SizedBox.shrink(),
                                    ],
                                  );
                                },
                              ),
                            ),
                          );
                        }
                      }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
