import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:geschenkliste/components/cards/archive_card.dart';

import 'package:timelines/timelines.dart';

import '/models/gift.dart';
import '/models/contact.dart';

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
  List<Gift> archivedGifts = [];

  Future<List<Gift>> _getArchivedGiftsFromContact() async {
    List<Contact> contacts = [];
    var contactBox = await Hive.openBox('contacts');
    archivedGifts.clear();
    for (int i = 0; i < contactBox.length; i++) {
      contacts.add(contactBox.getAt(i));
      if (contacts[i].contactname == widget.contactname) {
        for (int j = 0; j < contacts[i].archivedGifts.length; j++) {
          archivedGifts.add(contacts[i].archivedGifts[j]);
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
          itemCount: archivedGifts.length,
          contentsAlign: ContentsAlign.basic,
          contentsBuilder: (context, index) => FutureBuilder(
            future: _getArchivedGiftsFromContact(),
            builder: (BuildContext context, AsyncSnapshot<List<Gift>> snapshot) {
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
                      return Expanded(
                        child: ListView.builder(
                          itemCount: archivedGifts.length,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: ArchiveCard(
                                gift: archivedGifts[index],
                              ),
                            );
                          },
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
