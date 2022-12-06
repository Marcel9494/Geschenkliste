import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '/models/gift.dart';
import '/models/enums/events.dart';

import '/components/cards/day_card.dart';
import '/components/cards/gift_card.dart';
import '/components/texts/centered_text.dart';

class GiftListScreen extends StatefulWidget {
  const GiftListScreen({Key? key}) : super(key: key);

  @override
  State<GiftListScreen> createState() => _GiftListScreenState();
}

class _GiftListScreenState extends State<GiftListScreen> {
  List<String> eventFilter = [];
  late List<Gift> gifts = [];
  int selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    _getEventFilter();
  }

  void _getEventFilter() {
    for (int i = 0; i < Events.values.length; i++) {
      eventFilter.add(Events.values[i].filterName);
    }
  }

  Future<List<Gift>> _getGiftList() async {
    var giftBox = await Hive.openBox('gifts');
    gifts.clear();
    for (int i = 0; i < giftBox.length; i++) {
      gifts.add(giftBox.getAt(i));
      gifts[i].boxPosition = i;
      gifts[i].showInFilteredList = true;
      if (eventFilter[selectedFilterIndex] != Events.anyDate.filterName) {
        if (gifts[i].event.eventname != eventFilter[selectedFilterIndex]) {
          gifts[i].showInFilteredList = false;
        }
      }
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
                return Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 4.0, 0.0, 4.0),
                  child: ChoiceChip(
                    label: Text(
                      eventFilter[index],
                      style: TextStyle(color: selectedFilterIndex == index ? Colors.black87 : Colors.white),
                    ),
                    selected: selectedFilterIndex == index,
                    selectedColor: Colors.cyanAccent,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedFilterIndex = index;
                        }
                      });
                    },
                  ),
                );
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
                  return eventFilter[selectedFilterIndex] == 'Alle'
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height / 2,
                          child: const Center(
                            child: CircularProgressIndicator(color: Colors.cyanAccent),
                          ),
                        )
                      : const SizedBox.shrink();
                default:
                  if (snapshot.hasError) {
                    return const CenteredText(text: 'Geschenkliste konnte nicht geladen werden.', divider: 2);
                  } else {
                    if (gifts.isEmpty) {
                      return const CenteredText(text: 'Noch keine Geschenke vorhanden.', divider: 2);
                    } else {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: gifts.length,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return gifts[index].showInFilteredList
                                ? Row(
                                    children: [
                                      const DayCard(days: 1),
                                      GiftCard(gift: gifts[index]),
                                    ],
                                  )
                                : const SizedBox.shrink();
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
