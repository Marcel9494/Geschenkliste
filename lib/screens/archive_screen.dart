import 'package:flutter/material.dart';
import 'package:geschenkliste/components/texts/centered_text.dart';
import 'package:hive/hive.dart';
import 'package:timelines/timelines.dart';

import '/components/cards/archive_card.dart';

import '/models/contact.dart';
import '/models/archived_gift.dart';

class ArchiveScreen extends StatefulWidget {
  final Contact contact;

  const ArchiveScreen({
    Key? key,
    required this.contact,
  }) : super(key: key);

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  List<ArchivedGift> archivedGifts = [];

  Future<List<ArchivedGift>> _getArchivedGiftsFromContact() async {
    List<Contact> contacts = [];
    var contactBox = await Hive.openBox('contacts');
    for (int i = 0; i < contactBox.length; i++) {
      contacts.add(contactBox.getAt(i));
      if (contacts[i].contactname == widget.contact.contactname) {
        for (int j = 0; j < contacts[i].archivedGiftsData.length; j++) {
          final splittedArchivedGiftData = contacts[i].archivedGiftsData[j].split(';');
          var archivedGift = ArchivedGift(
            index: j,
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
    // TODO archivedGifts nach Eventdatum sortieren contactNames.sort((first, second) => first.compareTo(second));
    return archivedGifts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Archiv von ${widget.contact.contactname}'),
      ),
      body: FutureBuilder(
        future: _getArchivedGiftsFromContact(),
        builder: (BuildContext context, AsyncSnapshot<List<ArchivedGift>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(color: Colors.cyanAccent),
              );
            default:
              if (snapshot.hasError) {
                return const CenteredText(text: 'Archiv Geschenkliste konnte nicht geladen werden.');
              } else {
                if (archivedGifts.isEmpty) {
                  return const CenteredText(text: 'Noch keine Geschenke im Archiv vorhanden.');
                } else {
                  return Timeline.tileBuilder(
                    padding: const EdgeInsets.only(left: 20.0),
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
                      itemCount: archivedGifts.length,
                      contentsAlign: ContentsAlign.basic,
                      contentsBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ArchiveCard(
                          contactBoxPosition: widget.contact.boxPosition,
                          archivedGift: archivedGifts[index],
                        ),
                      ),
                    ),
                  );
                }
              }
          }
        },
      ),
    );
  }
}
