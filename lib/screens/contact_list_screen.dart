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
      Contact tempContact = contactBox.getAt(i);
      if (tempContact.contactname.toLowerCase().contains(searchedContactname.toLowerCase())) {
        contacts.add(contactBox.getAt(i));
        contacts[contactNumber].remainingDays = _getRemainingDaysToEvent(contactNumber);
        contacts[contactNumber].nextBirthday = _getNextBirthday(contactNumber);
        contacts[contactNumber].birthdayAge = _getBirthdayAge(contactNumber);
        contacts[contactNumber].boxPosition = contactNumber;
        contactNumber++;
      }
    }
    contacts.sort((first, second) => first.remainingDays.compareTo(second.remainingDays));
    return contacts;
  }

  int _getRemainingDaysToEvent(final int index) {
    if (contacts[index].birthday == null) {
      return 9999;
    }
    DateTime eventDate = DateTime(DateTime.now().year + 1, contacts[index].birthday!.month, contacts[index].birthday!.day);
    DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return (eventDate.difference(today).inHours / 24).round() % 365; // TODO Schaltjahre mit berücksichtigen (366 Tage)
  }

  int _getBirthdayAge(final int index) {
    if (contacts[index].birthday == null) {
      return 0;
    }
    if (contacts[index].birthday!.month >= DateTime.now().month) {
      if (contacts[index].birthday!.day >= DateTime.now().day) {
        return DateTime.now().year - contacts[index].birthday!.year;
      }
      return (DateTime.now().year + 1) - contacts[index].birthday!.year;
    }
    return (DateTime.now().year + 1) - contacts[index].birthday!.year;
  }

  DateTime _getNextBirthday(final int index) {
    if (contacts[index].birthday == null) {
      return DateTime(1, 0, 0);
    }
    if (contacts[index].birthday!.month >= DateTime.now().month) {
      if (contacts[index].birthday!.day >= DateTime.now().day) {
        return DateTime(DateTime.now().year, contacts[index].birthday!.month, contacts[index].birthday!.day);
      }
      return DateTime(DateTime.now().year + 1, contacts[index].birthday!.month, contacts[index].birthday!.day);
    }
    return DateTime(DateTime.now().year + 1, contacts[index].birthday!.month, contacts[index].birthday!.day);
  }

  void _clearSearchField() {
    _searchedContactnameTextController.text = '';
    _getContactList(_searchedContactnameTextController.text);
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: SizedBox(
          height: 38.0,
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
                borderRadius: BorderRadius.circular(8.0),
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
        actions: [
          IconButton(
            onPressed: () => {
              Navigator.pushNamed(context, '/createOrEditContact', arguments: CreateContactScreenArguments(-1)),
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                          onRefresh: () {
                            var contacts = _getContactList(_searchedContactnameTextController.text);
                            setState(() {});
                            return contacts;
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
                                              padding: const EdgeInsets.fromLTRB(100.0, 12.0, 0.0, 12.0),
                                              child: Text(
                                                '${dateFormatter.format(contacts[0].nextBirthday!)} - ${contacts[0].nextBirthday!.year}',
                                                style: const TextStyle(
                                                  fontSize: 16.0,
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
                                                  padding: const EdgeInsets.fromLTRB(100.0, 12.0, 0.0, 12.0),
                                                  child: Text(
                                                    contacts[index + 1].nextBirthday!.year == 0
                                                        ? 'Kein Geburtstag eingetragen'
                                                        : '${dateFormatter.format(contacts[index + 1].nextBirthday!)} - ${contacts[index + 1].nextBirthday!.year}',
                                                    style: const TextStyle(
                                                      fontSize: 16.0,
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
    );
  }
}
