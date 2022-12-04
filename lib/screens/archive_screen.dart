import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:timelines/timelines.dart';

import '/components/cards/archive_card.dart';

import '/models/contact.dart';
import '/models/archived_gift.dart';

class ArchiveScreen extends StatefulWidget {
  final String contactname;

  const ArchiveScreen({
    Key? key,
    required this.contactname,
  }) : super(key: key);

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  //List<String> archivedGifts = [];
  List<ArchivedGift> archivedGifts = [];

  @override
  initState() {
    super.initState();
    _getArchivedGiftsFromContact();
  }

  Future<List<ArchivedGift>> _getArchivedGiftsFromContact() async {
    List<Contact> contacts = [];
    var contactBox = await Hive.openBox('contacts');
    for (int i = 0; i < contactBox.length; i++) {
      contacts.add(contactBox.getAt(i));
      if (contacts[i].contactname == widget.contactname) {
        for (int j = 0; j < contacts[i].archivedGiftsData.length; j++) {
          //final splittedArchivedGiftEntries = contacts[i].archivedGiftsData.split('|');
          //for (int j = 0; j < splittedArchivedGiftEntries.length; j++) {
          //print(splittedArchivedGiftEntries[j]);
          //if (splittedArchivedGiftEntries[j].isEmpty) {
          //  continue;
          //}
          final splittedArchivedGiftData = contacts[i].archivedGiftsData[j].split(';');
          print(splittedArchivedGiftData);
          var archivedGift = ArchivedGift(
            giftname: splittedArchivedGiftData[0],
            eventname: splittedArchivedGiftData[1],
            eventDate: splittedArchivedGiftData[2],
            note: splittedArchivedGiftData[3],
            giftState: splittedArchivedGiftData[4],
          );
          archivedGifts.add(archivedGift);
        }
        break;
      }
    }
    //contactNames.sort((first, second) => first.compareTo(second));
    return archivedGifts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archiv'),
      ),
      body: Timeline.tileBuilder(
        theme: TimelineThemeData(
          nodePosition: 0,
          connectorTheme: const ConnectorThemeData(
            thickness: 3.0,
            color: Colors.grey,
          ),
          indicatorTheme: const IndicatorThemeData(
            size: 16.0,
            color: Colors.cyanAccent,
          ),
        ),
        builder: TimelineTileBuilder.fromStyle(
          itemCount: 1,
          contentsAlign: ContentsAlign.basic,
          contentsBuilder: (context, index) => FutureBuilder(
            future: _getArchivedGiftsFromContact(),
            builder: (BuildContext context, AsyncSnapshot<List<ArchivedGift>> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.cyanAccent),
                  );
                default:
                  if (snapshot.hasError) {
                    return const Center(child: Text('Archiv Geschenkliste konnte nicht geladen werden.'));
                  } else {
                    if (archivedGifts.isEmpty) {
                      return const Center(child: Text('Noch keine Geschenke im Archiv vorhanden.'));
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: ArchiveCard(
                          archivedGift: archivedGifts[index],
                        ),
                      );
                    }
                  }
              }
            },
          ),
        ),
      ),
    );
  }
}
