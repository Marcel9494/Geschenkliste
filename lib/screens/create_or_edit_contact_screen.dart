import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '/components/buttons/save_button.dart';

import '/models/contact.dart';

class CreateOrEditContactScreen extends StatefulWidget {
  final int contactBoxPosition;

  const CreateOrEditContactScreen({
    Key? key,
    required this.contactBoxPosition,
  }) : super(key: key);

  @override
  State<CreateOrEditContactScreen> createState() => _CreateOrEditContactScreenState();
}

class _CreateOrEditContactScreenState extends State<CreateOrEditContactScreen> {
  final TextEditingController _contactnameTextController = TextEditingController(text: '');
  final TextEditingController _birthdayTextController = TextEditingController(text: '');
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  DateTime? parsedBirthdayDate;
  String contactnameText = '';
  String contactnameErrorText = '';
  String birthdayDate = '';
  String birthdayDateErrorText = '';
  late Contact contact;

  Future<Contact> _getContactData() async {
    var contactBox = await Hive.openBox('contacts');
    contact = await contactBox.getAt(widget.contactBoxPosition);
    _contactnameTextController.text = contact.contactname;
    final DateFormat dateFormatter = DateFormat('dd.MM.yyyy');
    parsedBirthdayDate = contact.birthday;
    String formattedBirthday = dateFormatter.format(contact.birthday!);
    _birthdayTextController.text = formattedBirthday;
    return contact;
  }

  void _createContact() async {
    if (_contactnameTextController.text.isEmpty) {
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
    for (int i = 0; i < contactBox.length; i++) {
      Contact contact = contactBox.getAt(i);
      if (contact.contactname == _contactnameTextController.text) {
        setState(() {
          contactnameErrorText = 'Name ist bereits vorhanden.';
          _setButtonAnimation(false);
        });
        return;
      }
    }
    var contact = Contact()
      ..contactname = _contactnameTextController.text
      ..birthday = parsedBirthdayDate
      ..archivedGiftsData = '';
    if (widget.contactBoxPosition == -1) {
      contactBox.add(contact);
    } else {
      contactBox.putAt(widget.contactBoxPosition, contact);
    }
    _setButtonAnimation(true);
    Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(FocusNode());
        Navigator.pop(context);
        Navigator.pop(context);
        // TODO auch wieder zurück auf Geschenk erstellen Seite leiten oder nur Navigator.pop(context)? Beide Fälle müssen abgedeckt werden.
        Navigator.pushNamed(context, '/bottomNavBar');
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        final DateFormat dateFormatter = DateFormat('dd.MM.yyyy');
                        String formattedBirthday = dateFormatter.format(parsedBirthdayDate!);
                        _birthdayTextController.text = formattedBirthday;
                      },
                    ),
                    SaveButton(
                      boxPosition: widget.contactBoxPosition,
                      callback: _createContact,
                      buttonController: _btnController,
                    ),
                  ],
                );
              }
          }
        },
      ),
    );
  }
}
