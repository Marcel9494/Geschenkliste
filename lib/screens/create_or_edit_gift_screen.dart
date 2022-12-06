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
    Event(eventname: Events.christmas.name, eventDate: DateTime(2023, 12, 24)), // TODO 2023 variabel machen
    Event(eventname: Events.nicholas.name, eventDate: DateTime(2023, 12, 6)), // TODO 2023 variabel machen
    Event(eventname: Events.easter.name, eventDate: DateTime(2023, 4, 9)), // TODO 2023 variabel machen
    Event(eventname: Events.anyDate.name),
  ];
  List<String> eventNames = [];
  List<Contact> contacts = [];
  List<String> contactNames = [];
  List<String> giftStateList = [];
  GiftStatus giftStatus = GiftStatus.idea;
  String selectedEvent = '';
  String selectedContact = '';
  String selectedGiftState = '';
  String giftnameErrorText = '';
  String contactnameErrorText = '';
  String eventDateErrorText = '';
  DateTime? parsedEventDate;
  late Gift gift;

  @override
  initState() {
    super.initState();
    for (int i = 0; i < GiftStatus.values.length; i++) {
      giftStateList.add(GiftStatus.values[i].name);
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
    var contactBox = await Hive.openBox('contacts');
    contacts.clear();
    for (int i = 0; i < contactBox.length; i++) {
      contacts.add(contactBox.getAt(i));
      contactNames.add(contacts[i].contactname);
    }
    contactNames.sort((first, second) => first.compareTo(second));
    setState(() {
      selectedContact = contactNames[0];
    });
    return contacts;
  }

  void _setBirthdayDateFromContact() async {
    for (int i = 0; i < contacts.length; i++) {
      if (selectedContact == contacts[i].contactname && contacts[i].birthday != null && contacts[i].nextBirthday != null) {
        setState(() {
          _eventDateTextController.text = dateFormatter.format(contacts[i].nextBirthday!);
        });
        break;
      }
    }
  }

  void _createGift() async {
    int selectedContactIndex = -1;
    int selectedEventIndex = -1;
    if (_giftnameTextController.text.isEmpty) {
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
    var gift = Gift()
      ..giftname = _giftnameTextController.text
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
        Navigator.pushNamed(context, '/bottomNavBar');
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
    _eventDateTextController.text = '';
    parsedEventDate = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.giftBoxPosition == -1 ? const Text('Geschenk erstellen') : const Text('Geschenk bearbeiten'),
      ),
      body: FutureBuilder<Gift>(
        future: widget.giftBoxPosition == -1 ? null : _getGiftData(),
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
                            onPressed: () => Navigator.pushNamed(context, '/createOrEditContact', arguments: CreateContactScreenArguments(-1)),
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
                            if (selectedEvent == Events.christmas.name) {
                              _eventDateTextController.text = '24.12.${DateTime.now().year}';
                            } else if (selectedEvent == Events.nicholas.name) {
                              _eventDateTextController.text = '06.12.${DateTime.now().year}';
                            } else if (selectedEvent == Events.easter.name) {
                              _eventDateTextController.text = '09.04.${DateTime.now().year}';
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
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2200),
                          );
                          _eventDateTextController.text = dateFormatter.format(parsedEventDate!);
                        },
                      ),
                      TextFormField(
                        controller: _notesTextController,
                        textAlignVertical: TextAlignVertical.center,
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
