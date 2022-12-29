import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '/components/buttons/save_button.dart';

import '/models/contact.dart';
import '/models/archived_gift.dart';
import '/models/screen_arguments/archive_screen_arguments.dart';

class EditArchivedGiftScreen extends StatefulWidget {
  final int contactBoxPosition;
  final int archivedGiftIndex;

  const EditArchivedGiftScreen({
    Key? key,
    required this.contactBoxPosition,
    required this.archivedGiftIndex,
  }) : super(key: key);

  @override
  State<EditArchivedGiftScreen> createState() => _EditArchivedGiftScreenState();
}

class _EditArchivedGiftScreenState extends State<EditArchivedGiftScreen> {
  final TextEditingController _archivedGiftNoteTextController = TextEditingController(text: '');
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  late Contact contactWithArchivedGift;

  Future<ArchivedGift> _getArchivedGiftData() async {
    var contactBox = await Hive.openBox('contacts');
    contactWithArchivedGift = await contactBox.getAt(widget.contactBoxPosition);
    final splittedArchivedGiftData = contactWithArchivedGift.archivedGiftsData[widget.archivedGiftIndex].split(';');
    ArchivedGift archivedGift = ArchivedGift(
      index: widget.archivedGiftIndex,
      giftname: splittedArchivedGiftData[0],
      eventname: splittedArchivedGiftData[1],
      eventDate: splittedArchivedGiftData[2],
      note: splittedArchivedGiftData[3],
      giftState: splittedArchivedGiftData[4],
    );
    _archivedGiftNoteTextController.text = archivedGift.note;
    return archivedGift;
  }

  void _updateArchivedGift() async {
    var contactBox = await Hive.openBox('contacts');
    final splittedArchivedGiftData = contactWithArchivedGift.archivedGiftsData[widget.archivedGiftIndex].split(';');
    contactWithArchivedGift.archivedGiftsData[widget.archivedGiftIndex] =
        '${splittedArchivedGiftData[0]};${splittedArchivedGiftData[1]};${splittedArchivedGiftData[2]};${_archivedGiftNoteTextController.text};${splittedArchivedGiftData[4]}';
    Contact contactWithUpdatedArchivedGift = Contact()
      ..boxPosition = contactWithArchivedGift.boxPosition
      ..contactname = contactWithArchivedGift.contactname
      ..birthday = contactWithArchivedGift.birthday
      ..archivedGiftsData = contactWithArchivedGift.archivedGiftsData
      ..nextBirthday = contactWithArchivedGift.nextBirthday
      ..remainingDays = contactWithArchivedGift.remainingDays
      ..birthdayAge = contactWithArchivedGift.birthdayAge;
    contactBox.putAt(widget.contactBoxPosition, contactWithUpdatedArchivedGift);
    _setButtonAnimation(true);
    Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(FocusNode());
        Navigator.pop(context);
        Navigator.popAndPushNamed(context, '/archive', arguments: ArchiveScreenArguments(contactWithArchivedGift));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geschenk bearbeiten'),
      ),
      body: FutureBuilder<ArchivedGift>(
        future: _getArchivedGiftData(),
        builder: (BuildContext context, AsyncSnapshot<ArchivedGift> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Archiviertes Geschenk konnte nicht geladen werden.',
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
                      controller: _archivedGiftNoteTextController,
                      maxLength: 300,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Notiz',
                        prefixIcon: IconTheme(
                          data: IconThemeData(color: Colors.cyanAccent),
                          child: Icon(Icons.sticky_note_2_rounded),
                        ),
                        prefixIconConstraints: BoxConstraints(
                          minWidth: 42.0,
                          maxWidth: 42.0,
                        ),
                        counterText: '',
                      ),
                    ),
                    SaveButton(
                      boxPosition: widget.contactBoxPosition,
                      callback: _updateArchivedGift,
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
