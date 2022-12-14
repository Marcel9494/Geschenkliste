import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '/components/buttons/save_button.dart';

import '/models/gift.dart';
import '/models/event.dart';
import '/models/contact.dart';
import '/models/enums/events.dart';
import '/models/enums/gift_state.dart';
import '/models/screen_arguments/create_contact_screen_arguments.dart';
import '/models/screen_arguments/bottom_nav_bar_screen_arguments.dart';

import '/utils/date_formatter.dart';

class CreateOrEditGiftScreen extends StatefulWidget {
  final int giftBoxPosition;

  const CreateOrEditGiftScreen({
    Key? key,
    required this.giftBoxPosition,
  }) : super(key: key);

  @override
  State<CreateOrEditGiftScreen> createState() => _CreateOrEditGiftScreenState();
}

class _CreateOrEditGiftScreenState extends State<CreateOrEditGiftScreen> {
  final TextEditingController _giftnameTextController = TextEditingController(text: '');
  final TextEditingController _contactnameTextController = TextEditingController(text: '');
  final TextEditingController _notesTextController = TextEditingController(text: '');
  final TextEditingController _eventDateTextController = TextEditingController(text: '');
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final DateFormat dateFormatter = DateFormat('dd.MM.yyyy');
  List<Event> events = [
    Event(eventname: Events.birthday.name),
    Event(eventname: Events.wedding.name),
    Event(eventname: Events.christmas.name, eventDate: DateTime(2023, 12, 24), currentDate: DateTime.now()),
    Event(eventname: Events.nicholas.name, eventDate: DateTime(2023, 12, 6), currentDate: DateTime.now()),
    Event(eventname: Events.easter.name, currentDate: DateTime.now()),
    Event(eventname: Events.anyDate.name),
  ];
  List<String> eventNames = [];
  List<Contact> contacts = [];
  List<String> contactNames = [];
  List<String> giftStateList = [];
  GiftState giftStatus = GiftState.idea;
  String selectedEvent = '';
  String selectedContact = '';
  String newContactname = '';
  String selectedGiftState = '';
  String giftnameErrorText = '';
  String contactnameErrorText = '';
  String eventDateErrorText = '';
  DateTime? parsedEventDate;
  bool isContactEdited = false;
  bool isEventDateEdited = false;
  late Gift gift;

  @override
  initState() {
    super.initState();
    for (int i = 0; i < GiftState.values.length; i++) {
      giftStateList.add(GiftState.values[i].name);
    }
    selectedGiftState = giftStateList[0];
    for (int i = 0; i < events.length; i++) {
      eventNames.add(events[i].eventname);
    }
    selectedEvent = events[0].eventname;
    _getContactList();
  }

  Future<Gift> _getGiftData() async {
    var giftBox = await Hive.openBox('gifts');
    gift = await giftBox.getAt(widget.giftBoxPosition);
    _giftnameTextController.text = gift.giftname;
    _contactnameTextController.text = gift.contact.contactname;
    _notesTextController.text = gift.note;
    // TODO hier weitermachen und EventDate Datenhaltung vereinfachen abgespeichertes Format in Hive ist jetzt: YYYY-MM-DD und Anzeige ist: DD.MM.YYYY
    parsedEventDate = gift.event.eventDate;
    if (gift.event.eventDate != null) {
      _eventDateTextController.text = dateFormatter.format(gift.event.eventDate!);
    }
    selectedEvent = gift.event.eventname;
    selectedContact = gift.contact.contactname;
    selectedGiftState = gift.giftState;
    return gift;
  }

  Future<List<Contact>> _getContactList() async {
    print(selectedContact);
    var contactBox = await Hive.openBox('contacts');
    contacts.clear();
    contactNames.clear();
    for (int i = 0; i < contactBox.length; i++) {
      contacts.add(contactBox.getAt(i));
      contactNames.add(contacts[i].contactname);
    }
    contactNames.sort((first, second) => first.compareTo(second));
    setState(() {
      if (newContactname.isEmpty) {
        selectedContact = contactNames[0];
      } else {
        for (int i = 0; i < contactNames.length; i++) {
          if (newContactname == contactNames[i]) {
            selectedContact = contactNames[i];
          }
        }
      }
    });
    return contacts;
  }

  void _setBirthdayDateFromContact() async {
    for (int i = 0; i < contacts.length; i++) {
      if (selectedContact == contacts[i].contactname && contacts[i].birthday != null && contacts[i].nextBirthday != null) {
        _eventDateTextController.text = dateFormatter.format(contacts[i].nextBirthday!);
        break;
      }
      _eventDateTextController.text = '';
    }
    setState(() {});
  }

  void _createGift() async {
    int selectedContactIndex = -1;
    int selectedEventIndex = -1;
    if (_giftnameTextController.text.trim().isEmpty) {
      setState(() {
        giftnameErrorText = 'Geschenkname / Idee darf nicht leer sein.';
        _setButtonAnimation(false);
      });
      return;
    }
    for (int i = 0; i < contacts.length; i++) {
      if (contacts[i].contactname == selectedContact) {
        selectedContactIndex = i;
        break;
      }
    }
    for (int i = 0; i < events.length; i++) {
      if (events[i].eventname == selectedEvent) {
        selectedEventIndex = i;
        break;
      }
    }
    // TODO Fehler abfangen selectedContactIndex == -1 || selectedEventIndex == -1
    var giftBox = await Hive.openBox('gifts');
    if (_eventDateTextController.text.isNotEmpty) {
      events[selectedEventIndex].eventDate = FormattingStringToYYYYMMDD(_eventDateTextController.text);
    }
    Gift gift = Gift()
      ..giftname = _giftnameTextController.text.trim()
      ..contact = contacts[selectedContactIndex]
      ..giftState = selectedGiftState
      ..note = _notesTextController.text
      ..event = events[selectedEventIndex];
    if (widget.giftBoxPosition == -1) {
      giftBox.add(gift);
    } else {
      giftBox.putAt(widget.giftBoxPosition, gift);
    }
    _setButtonAnimation(true);
    Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(FocusNode());
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pushNamed(context, '/bottomNavBar', arguments: BottomNavBarScreenArguments(0));
      }
    });
  }

  void _setButtonAnimation(bool successful) {
    successful ? _btnController.success() : _btnController.error();
    if (successful == false) {
      Timer(const Duration(seconds: 1), () {
        _btnController.reset();
      });
    }
  }

  void _clearEventDate() {
    setState(() {
      _eventDateTextController.text = '';
      parsedEventDate = null;
      isEventDateEdited = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.giftBoxPosition == -1 ? const Text('Geschenk erstellen') : const Text('Geschenk bearbeiten'),
      ),
      body: FutureBuilder<Gift>(
        future: widget.giftBoxPosition == -1
            ? null
            : isContactEdited || isEventDateEdited
                ? null
                : _getGiftData(),
        builder: (BuildContext context, AsyncSnapshot<Gift> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Geschenk konnte nicht geladen werden.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                );
              } else {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _giftnameTextController,
                        textAlignVertical: TextAlignVertical.center,
                        maxLength: 35,
                        decoration: InputDecoration(
                          hintText: 'Geschenkname / Idee',
                          hintStyle: const TextStyle(color: Colors.white),
                          contentPadding: const EdgeInsets.only(top: 2.0),
                          prefixIcon: const IconTheme(
                            data: IconThemeData(color: Colors.grey),
                            child: Icon(Icons.card_giftcard_rounded),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyanAccent, width: 2.0),
                          ),
                          counterText: '',
                          errorText: giftnameErrorText.isEmpty ? null : giftnameErrorText,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedContact,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded),
                              elevation: 16,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.person_rounded),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.cyanAccent, width: 2.0),
                                ),
                              ),
                              onChanged: (String? contact) {
                                setState(() {
                                  selectedContact = contact!;
                                  isContactEdited = true;
                                  if (selectedEvent == Events.birthday.name) {
                                    _setBirthdayDateFromContact();
                                  }
                                });
                              },
                              items: contactNames.map<DropdownMenuItem<String>>((String contact) {
                                return DropdownMenuItem<String>(
                                  value: contact,
                                  child: Text(contact),
                                );
                              }).toList(),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pushNamed(context, '/createOrEditContact',
                                arguments: CreateContactScreenArguments(-1, true, (contactname) => setState(() => newContactname = contactname))).then((_) => _getContactList()),
                            icon: const Icon(Icons.person_add_rounded),
                          ),
                        ],
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedGiftState,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        elevation: 16,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(left: 4.0),
                            child: Icon(Icons.tips_and_updates_rounded),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyanAccent, width: 2.0),
                          ),
                        ),
                        onChanged: (String? newGiftState) {
                          setState(() {
                            selectedGiftState = newGiftState!;
                            isContactEdited = true;
                          });
                        },
                        items: giftStateList.map<DropdownMenuItem<String>>((String event) {
                          return DropdownMenuItem<String>(
                            value: event,
                            child: Text(event),
                          );
                        }).toList(),
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedEvent,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        elevation: 16,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(left: 4.0),
                            child: Icon(Icons.event_rounded),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyanAccent, width: 2.0),
                          ),
                        ),
                        onChanged: (String? newEvent) {
                          setState(() {
                            selectedEvent = newEvent!;
                            isContactEdited = true;
                            if (selectedEvent == Events.birthday.name) {
                              _setBirthdayDateFromContact();
                            } else if (selectedEvent == Events.christmas.name) {
                              _eventDateTextController.text = dateFormatter.format(events[2].eventDate as DateTime);
                            } else if (selectedEvent == Events.nicholas.name) {
                              _eventDateTextController.text = dateFormatter.format(events[3].eventDate as DateTime);
                            } else if (selectedEvent == Events.easter.name) {
                              _eventDateTextController.text = dateFormatter.format(events[4].eventDate as DateTime);
                            } else if (selectedEvent == Events.wedding.name || selectedEvent == Events.anyDate.name) {
                              _eventDateTextController.text = '';
                            }
                          });
                        },
                        items: eventNames.map<DropdownMenuItem<String>>((String event) {
                          return DropdownMenuItem<String>(
                            value: event,
                            child: Text(event),
                          );
                        }).toList(),
                      ),
                      TextFormField(
                        controller: _eventDateTextController,
                        maxLength: 10,
                        readOnly: true,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: 'Eventdatum',
                          hintStyle: const TextStyle(color: Colors.white),
                          prefixIcon: const IconTheme(
                            data: IconThemeData(color: Colors.grey),
                            child: Padding(
                              padding: EdgeInsets.only(left: 6.0),
                              child: Icon(Icons.edit_calendar_rounded),
                            ),
                          ),
                          suffixIcon: _eventDateTextController.text.isEmpty
                              ? null
                              : IconTheme(
                                  data: const IconThemeData(color: Colors.cyanAccent),
                                  child: IconButton(
                                    onPressed: _clearEventDate,
                                    icon: const Icon(Icons.highlight_remove_rounded),
                                  ),
                                ),
                          counterText: '',
                          errorText: eventDateErrorText.isEmpty ? null : eventDateErrorText,
                        ),
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          parsedEventDate = await showDatePicker(
                            context: context,
                            locale: const Locale('de', 'DE'),
                            initialDate: DateTime.now(),
                            initialDatePickerMode: DatePickerMode.year,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2200),
                          );
                          _eventDateTextController.text = dateFormatter.format(parsedEventDate!);
                          isContactEdited = true;
                        },
                      ),
                      TextFormField(
                        controller: _notesTextController,
                        textAlignVertical: TextAlignVertical.center,
                        maxLength: 300,
                        decoration: const InputDecoration(
                          hintText: 'Notizen',
                          hintStyle: TextStyle(color: Colors.white),
                          contentPadding: EdgeInsets.only(top: 2.0),
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(left: 4.0),
                            child: IconTheme(
                              data: IconThemeData(color: Colors.grey),
                              child: Icon(Icons.sticky_note_2_rounded),
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyanAccent, width: 2.0),
                          ),
                          counterText: '',
                        ),
                      ),
                      SaveButton(
                        boxPosition: widget.giftBoxPosition,
                        callback: _createGift,
                        buttonController: _btnController,
                      ),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}
