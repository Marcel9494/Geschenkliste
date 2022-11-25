import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '/models/gift.dart';

import '/components/chips/event_filter_chip.dart';
import '/components/cards/day_card.dart';
import '/components/cards/gift_card.dart';

class GiftListScreen extends StatefulWidget {
  const GiftListScreen({Key? key}) : super(key: key);

  @override
  State<GiftListScreen> createState() => _GiftListScreenState();
}

class _GiftListScreenState extends State<GiftListScreen> {
  List<String> eventFilter = ['Alle', 'Geburtstage', 'Weihnachten', 'Ostern'];
  late List<Gift> gifts = [];

  Future<List<Gift>> _getGiftList() async {
    var giftBox = await Hive.openBox('gifts');
    gifts.clear();
    for (int i = 0; i < giftBox.length; i++) {
      gifts.add(giftBox.getAt(i));
      gifts[i].boxPosition = i;
    }
    return gifts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geschenke'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: Icon(Icons.settings_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Padding(
                padding: EdgeInsets.fromLTRB(12.0, 12.0, 0.0, 0.0),
                child: Text(
                  'Events:',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 60,
            child: ListView.builder(
              itemCount: eventFilter.length,
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return EventFilterChip(eventText: eventFilter[index]);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Padding(
                padding: EdgeInsets.fromLTRB(12.0, 4.0, 0.0, 8.0),
                child: Text(
                  'Geschenkliste:',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ],
          ),
          FutureBuilder<List<Gift>>(
            future: _getGiftList(),
            builder: (BuildContext context, AsyncSnapshot<List<Gift>> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return SizedBox(
                    height: MediaQuery.of(context).size.height / 2,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.cyanAccent),
                    ),
                  );
                default:
                  if (snapshot.hasError) {
                    return const Center(child: Text('Geschenkliste konnte nicht geladen werden.'));
                  } else {
                    if (gifts.isEmpty) {
                      return const Center(child: Text('Noch keine Geschenke vorhanden.'));
                    } else {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: gifts.length,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return Row(
                              children: [
                                const DayCard(days: 1),
                                GiftCard(gift: gifts[index]),
                              ],
                            );
                          },
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
