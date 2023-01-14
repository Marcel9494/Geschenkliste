import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '/components/buttons/save_button.dart';

import '/utils/date_formatter.dart';

import '/models/gift.dart';
import '/models/contact.dart';
import '/models/enums/events.dart';
import '/models/screen_arguments/bottom_nav_bar_screen_arguments.dart';

typedef void StringCallback(String newContactname);

class CreateOrEditContactScreen extends StatefulWidget {
  final int contactBoxPosition;
  final bool backToCreateGiftScreen;
  final StringCallback newContactnameCallback;
  final StringCallback newBirthdayCallback;

  const CreateOrEditContactScreen({
    Key? key,
    required this.contactBoxPosition,
    required this.backToCreateGiftScreen,
    required this.newContactnameCallback,
    required this.newBirthdayCallback,
  }) : super(key: key);

  @override
  State<CreateOrEditContactScreen> createState() => _CreateOrEditContactScreenState();
}

class _CreateOrEditContactScreenState extends State<CreateOrEditContactScreen> {
  final TextEditingController _contactnameTextController = TextEditingController(text: '');
  final TextEditingController _birthdayTextController = TextEditingController(text: '');
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final DateFormat dateFormatter = DateFormat('dd.MM.yyyy');
  DateTime? parsedBirthdayDate;
  DateTime? formattedBirthday;
  String contactnameErrorText = '';
  String birthdayDateErrorText = '';
  late Contact loadedContact;
  String newContactname = '';
  set string(String value) => setState(() => newContactname = value);

  Future<Contact> _getContactData() async {
    var contactBox = await Hive.openBox('contacts');
    loadedContact = await contactBox.getAt(widget.contactBoxPosition);
    _contactnameTextController.text = loadedContact.contactname;
    if (loadedContact.birthday != null) {
      _birthdayTextController.text = dateFormatter.format(loadedContact.birthday!);
    }
    return loadedContact;
  }

  void _createOrUpdateContact() async {
    if (_contactnameTextController.text.trim().isEmpty) {
      setState(() {
        contactnameErrorText = 'Name darf nicht leer sein.';
        _setButtonAnimation(false);
      });
      return;
    }
    if (_birthdayTextController.text.isNotEmpty && RegExp(r'[0-9]{2}.[0-9]{2}.[0-9]{4}').hasMatch(_birthdayTextController.text) == false) {
      setState(() {
        birthdayDateErrorText = 'Ungültiges Datumsformat. Erlaubtes Format: dd.mm.yyyy';
        _setButtonAnimation(false);
      });
      return;
    }
    var contactBox = await Hive.openBox('contacts');
    if (_checkIfContactnameExists(contactBox)) {
      setState(() {
        contactnameErrorText = 'Name ist bereits vorhanden.';
        _setButtonAnimation(false);
      });
      return;
    }
    if (_birthdayTextController.text.isNotEmpty) {
      formattedBirthday = FormattingStringToYYYYMMDD(_birthdayTextController.text);
    }
    if (widget.contactBoxPosition == -1) {
      _addNewContact();
    } else {
      _updateContact();
      _updateGiftsFromContact();
    }
    _setButtonAnimation(true);
    Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(FocusNode());
        Navigator.pop(context);
        if (widget.backToCreateGiftScreen == false) {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/bottomNavBar', arguments: BottomNavBarScreenArguments(1));
        } else {
          widget.newContactnameCallback(_contactnameTextController.text.trim());
          widget.newBirthdayCallback(_birthdayTextController.text.trim());
        }
      }
    });
  }

  bool _checkIfContactnameExists(var contactBox) {
    for (int i = 0; i < contactBox.length; i++) {
      Contact contact = contactBox.getAt(i);
      if (widget.contactBoxPosition != -1 && loadedContact.contactname == _contactnameTextController.text.trim()) {
        break;
      }
      if (contact.contactname == _contactnameTextController.text.trim()) {
        return true;
      }
    }
    return false;
  }

  void _addNewContact() async {
    var contactBox = await Hive.openBox('contacts');
    Contact newContact = Contact()
      ..contactname = _contactnameTextController.text.trim()
      ..birthday = formattedBirthday
      ..archivedGiftsData = [];
    contactBox.add(newContact);
  }

  void _updateContact() async {
    var contactBox = await Hive.openBox('contacts');
    Contact updatedContact = Contact()
      ..contactname = _contactnameTextController.text.trim()
      ..birthday = formattedBirthday
      ..archivedGiftsData = loadedContact.archivedGiftsData;
    contactBox.putAt(widget.contactBoxPosition, updatedContact);
  }

  void _updateGiftsFromContact() async {
    var giftBox = await Hive.openBox('gifts');
    for (int i = 0; i < giftBox.length; i++) {
      Gift gift = giftBox.getAt(i);
      // TODO in gift Klasse auslagern als eigene Funktion?
      // TODO hier weitermachen was soll passieren wenn Kontakt gelöscht wird, aber es noch Geschenke für diesen Kontakt gibt?
      if (gift.contact.contactname == loadedContact.contactname || (gift.contact.contactname == loadedContact.contactname && gift.contact.birthday == loadedContact.birthday)) {
        gift.contact.contactname = _contactnameTextController.text.trim();
        gift.contact.birthday = formattedBirthday;
        if (gift.event.eventname == Events.birthday.name) {
          gift.event.eventDate = formattedBirthday;
        }
        Gift updatedGift = Gift()
          ..giftname = gift.giftname
          ..contact = gift.contact
          ..giftState = gift.giftState
          ..note = gift.note
          ..event = gift.event;
        giftBox.putAt(i, updatedGift);
      }
    }
  }

  void _clearBirthday() {
    _birthdayTextController.text = '';
    parsedBirthdayDate = null;
  }

  void _setButtonAnimation(bool successful) {
    successful ? _btnController.success() : _btnController.error();
    if (successful == false) {
      Timer(const Duration(seconds: 1), () {
        _btnController.reset();
      });
    }
  }

  Future<bool> goBack() async {
    FocusScope.of(context).requestFocus(FocusNode());
    Navigator.pop(context);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: goBack,
      child: Scaffold(
        appBar: AppBar(
          title: widget.contactBoxPosition == -1 ? const Text('Kontakt erstellen') : const Text('Kontakt bearbeiten'),
        ),
        body: FutureBuilder<Contact>(
          future: widget.contactBoxPosition == -1 ? null : _getContactData(),
          builder: (BuildContext context, AsyncSnapshot<Contact> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
              default:
                if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Kontakt konnte nicht geladen werden.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  );
                } else {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _contactnameTextController,
                        maxLength: 30,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Name',
                          prefixIcon: const IconTheme(
                            data: IconThemeData(color: Colors.cyanAccent),
                            child: Icon(Icons.person_rounded),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 42.0,
                            maxWidth: 42.0,
                          ),
                          counterText: '',
                          errorText: contactnameErrorText.isEmpty ? null : contactnameErrorText,
                        ),
                      ),
                      TextFormField(
                        controller: _birthdayTextController,
                        maxLength: 10,
                        readOnly: true,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: 'Geburtstag',
                          prefixIcon: const IconTheme(
                            data: IconThemeData(color: Colors.cyanAccent),
                            child: Icon(Icons.edit_calendar_rounded),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 42.0,
                            maxWidth: 42.0,
                          ),
                          suffixIcon: _birthdayTextController.text.isEmpty
                              ? null
                              : IconTheme(
                                  data: const IconThemeData(color: Colors.cyanAccent),
                                  child: IconButton(
                                    onPressed: _clearBirthday,
                                    icon: const Icon(Icons.highlight_remove_rounded),
                                  ),
                                ),
                          counterText: '',
                          errorText: birthdayDateErrorText.isEmpty ? null : birthdayDateErrorText,
                        ),
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          parsedBirthdayDate = await showDatePicker(
                            context: context,
                            locale: const Locale('de', 'DE'),
                            initialDate: DateTime(2000),
                            initialDatePickerMode: DatePickerMode.year,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2200),
                          );
                          _birthdayTextController.text = dateFormatter.format(parsedBirthdayDate!);
                        },
                      ),
                      SaveButton(
                        boxPosition: widget.contactBoxPosition,
                        callback: _createOrUpdateContact,
                        buttonController: _btnController,
                      ),
                    ],
                  );
                }
            }
          },
        ),
      ),
    );
  }
}
