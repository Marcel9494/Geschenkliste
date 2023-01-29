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
  final TextEditingController _giftnameTextController = TextEditingController(text: 'Noch keine Idee');
  final TextEditingController _contactnameTextController = TextEditingController(text: '');
  final TextEditingController _notesTextController = TextEditingController(text: '');
  final TextEditingController _eventDateTextController = TextEditingController(text: '');
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final DateFormat dateFormatter = DateFormat('dd.MM.yyyy');
  final FocusNode giftnameFocusNode = FocusNode();
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
  String selectedEvent = '';
  String selectedContact = '';
  String selectedBirthday = '';
  String newContactname = '';
  String newBirthday = '';
  String selectedGiftState = '';
  String giftnameErrorText = '';
  String contactnameErrorText = '';
  String eventErrorText = '';
  String eventDateErrorText = '';
  bool isContactEdited = false;
  bool isEventDateEdited = false;
  bool isGiftnameEdited = false;
  bool isGiftInCreationProgress = false;
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
    _getContactList().then((_) => _setBirthdayDateFromContact());
  }

  Future<List<Contact>> _getContactList() async {
    var contactBox = await Hive.openBox('contacts');
    contacts.clear();
    contactNames.clear();
    for (int i = 0; i < contactBox.length; i++) {
      contacts.add(contactBox.getAt(i));
      contacts[i].nextBirthday = contacts[i].getNextBirthday();
      contacts[i].birthdayAge = contacts[i].getBirthdayAge();
      contactNames.add(contacts[i].contactname);
    }
    contactNames.sort((first, second) => first.compareTo(second));
    contacts.sort((first, second) => first.contactname.compareTo(second.contactname));
    setState(() {
      if (contacts.isEmpty) {
        contactnameErrorText = 'Bitte erstellen Sie zuerst einen Kontakt.';
        return;
      }
      contactnameErrorText = '';
      if (newBirthday.isEmpty) {
        selectedBirthday = dateFormatter.format(contacts[0].birthday!);
      }
      if (newContactname.isEmpty) {
        selectedContact = contactNames[0];
      } else {
        for (int i = 0; i < contactNames.length; i++) {
          if (newContactname == contactNames[i]) {
            selectedContact = contactNames[i];
            selectedBirthday = dateFormatter.format(contacts[i].birthday!);
            break;
          }
        }
      }
    });
    return contacts;
  }

  void _setBirthdayDateFromContact() async {
    for (int i = 0; i < contacts.length; i++) {
      if (selectedContact == contacts[i].contactname && contacts[i].birthday != null && contacts[i].nextBirthday != null) {
        _eventDateTextController.text = dateFormatter.format(contacts[i].nextBirthday!) + ' • ${contacts[i].birthdayAge}. Geburtstag';
        selectedBirthday = dateFormatter.format(contacts[i].birthday!);
        break;
      }
      _eventDateTextController.text = '';
      selectedBirthday = '';
    }
    setState(() {});
  }

  Future<Gift> _loadGiftData() async {
    var giftBox = await Hive.openBox('gifts');
    gift = await giftBox.getAt(widget.giftBoxPosition);
    _giftnameTextController.text = gift.giftname;
    _contactnameTextController.text = gift.contact.contactname;
    _notesTextController.text = gift.note;
    if (gift.event.eventDate != null) {
      if (selectedEvent == Events.birthday.name) {
        _eventDateTextController.text = dateFormatter.format(gift.event.eventDate!) + ' • ${gift.contact.getBirthdayAge()}. Geburtstag';
      } else {
        _eventDateTextController.text = dateFormatter.format(gift.event.eventDate!);
      }
    } else {
      _eventDateTextController.text = '';
    }
    selectedEvent = gift.event.eventname;
    selectedContact = gift.contact.contactname;
    if (gift.contact.birthday != null) {
      selectedBirthday = dateFormatter.format(gift.contact.birthday!);
    }
    selectedGiftState = gift.giftState;
    return gift;
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
    if (selectedContactIndex == -1) {
      setState(() {
        contactnameErrorText = 'Bitte erstellen oder wählen Sie einen Kontakt aus.';
        _setButtonAnimation(false);
      });
      return;
    }
    if (selectedEventIndex == -1) {
      setState(() {
        eventErrorText = 'Bitte wählen Sie ein Event aus.';
        _setButtonAnimation(false);
      });
      return;
    }
    var giftBox = await Hive.openBox('gifts');
    if (_eventDateTextController.text.isNotEmpty) {
      events[selectedEventIndex].eventDate = StringToSavedDateFormatYYYYMMDD(_eventDateTextController.text.substring(0, 10));
    }
    Gift gift = Gift()
      ..giftname = _giftnameTextController.text.trim()
      ..contact = contacts[selectedContactIndex]
      ..giftState = selectedGiftState
      ..note = _notesTextController.text.trim()
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
      isEventDateEdited = true;
    });
  }

  void _clearGiftname() {
    setState(() {
      _giftnameTextController.text = '';
      isGiftnameEdited = true;
      FocusScope.of(context).requestFocus(giftnameFocusNode);
    });
  }

  Future<bool> showGoBackDialogWhenGiftEdited() async {
    isGiftInCreationProgress
        ? showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: widget.giftBoxPosition == -1 ? const Text('Geschenk erstellen wirklich abbrechen?') : const Text('Geschenk bearbeiten wirklich abbrechen?'),
                actions: <Widget>[
                  TextButton(
                    child: const Text(
                      'Nein',
                      style: TextStyle(
                        color: Colors.cyanAccent,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.cyanAccent,
                      onPrimary: Colors.black87,
                    ),
                    child: const Text('Ja'),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.popAndPushNamed(context, '/bottomNavBar', arguments: BottomNavBarScreenArguments(0));
                    },
                  ),
                ],
              );
            },
          )
        : null;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: showGoBackDialogWhenGiftEdited,
      child: Scaffold(
        appBar: AppBar(
          title: widget.giftBoxPosition == -1 ? const Text('Geschenk erstellen') : const Text('Geschenk bearbeiten'),
        ),
        body: FutureBuilder<Gift>(
          future: widget.giftBoxPosition == -1
              ? null
              : isContactEdited || isEventDateEdited || isGiftnameEdited
                  ? null
                  : _loadGiftData(),
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
                          focusNode: giftnameFocusNode,
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
                            suffixIcon: _giftnameTextController.text.isEmpty
                                ? null
                                : IconTheme(
                                    data: const IconThemeData(color: Colors.cyanAccent),
                                    child: IconButton(
                                      onPressed: _clearGiftname,
                                      icon: const Icon(Icons.highlight_remove_rounded),
                                    ),
                                  ),
                            counterText: '',
                            errorText: giftnameErrorText.isEmpty ? null : giftnameErrorText,
                          ),
                          onChanged: (_) => {
                            isGiftInCreationProgress = true,
                          },
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                value: selectedContact,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                elevation: 16,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.person_rounded),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.cyanAccent, width: 2.0),
                                  ),
                                  errorText: contactnameErrorText.isEmpty ? null : contactnameErrorText,
                                ),
                                onChanged: (String? newContactname) {
                                  setState(() {
                                    selectedContact = newContactname!;
                                    isContactEdited = true;
                                    isGiftInCreationProgress = true;
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
                            Expanded(
                              child: IconButton(
                                onPressed: () => Navigator.pushNamed(context, '/createOrEditContact',
                                        arguments: CreateContactScreenArguments(
                                            -1, true, (contactname) => setState(() => newContactname = contactname), (birthday) => setState(() => newBirthday = birthday)))
                                    .then((_) => _getContactList().then((_) => _setBirthdayDateFromContact())),
                                icon: const Icon(Icons.person_add_rounded),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                value: selectedEvent,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                elevation: 16,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.only(left: 4.0),
                                    child: Icon(Icons.event_rounded),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.cyanAccent, width: 2.0),
                                  ),
                                  errorText: eventErrorText.isEmpty ? null : eventErrorText,
                                ),
                                onChanged: (String? newEvent) {
                                  setState(() {
                                    selectedEvent = newEvent!;
                                    isContactEdited = true;
                                    isGiftInCreationProgress = true;
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
                            ),
                            Expanded(
                              child: Text(
                                selectedEvent == Events.birthday.name ? selectedBirthday : '',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                          ],
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
                            DateTime? parsedEventDate = await showDatePicker(
                              context: context,
                              locale: const Locale('de', 'DE'),
                              initialDate: DateTime.now(),
                              initialDatePickerMode: DatePickerMode.day,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (parsedEventDate != null) {
                              _eventDateTextController.text = dateFormatter.format(parsedEventDate);
                              isContactEdited = true;
                              setState(() {
                                isGiftInCreationProgress = true;
                              });
                            }
                          },
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
                              isGiftInCreationProgress = true;
                            });
                          },
                          items: giftStateList.map<DropdownMenuItem<String>>((String event) {
                            return DropdownMenuItem<String>(
                              value: event,
                              child: Text(event),
                            );
                          }).toList(),
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
                          onChanged: (_) => {
                            isGiftInCreationProgress = true,
                          },
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
      ),
    );
  }
}
