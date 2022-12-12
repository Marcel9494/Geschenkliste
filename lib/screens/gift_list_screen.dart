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
  final TextEditingController _searchTermTextController = TextEditingController(text: '');
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

  Future<List<Gift>> _getGiftList(String searchTerm) async {
    int giftNumber = 0;
    var giftBox = await Hive.openBox('gifts');
    gifts.clear();
    for (int i = 0; i < giftBox.length; i++) {
      Gift tempGift = giftBox.getAt(i);
      if (tempGift.contact.contactname.toLowerCase().contains(searchTerm.toLowerCase()) || tempGift.giftname.toLowerCase().contains(searchTerm.toLowerCase())) {
        gifts.add(giftBox.getAt(i));
        gifts[giftNumber].boxPosition = giftNumber;
        gifts[giftNumber].showInFilteredList = true;
        if (eventFilter[selectedFilterIndex] != Events.anyDate.filterName) {
          if (gifts[giftNumber].event.eventname != eventFilter[selectedFilterIndex]) {
            gifts[giftNumber].showInFilteredList = false;
          }
        }
        giftNumber++;
      }
    }
    return gifts;
  }

  void _clearSearchField() {
    _searchTermTextController.text = '';
    _getGiftList(_searchTermTextController.text);
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: SizedBox(
          height: 38.0,
          child: TextFormField(
            controller: _searchTermTextController,
            onChanged: (String searchedContactname) {
              setState(() {
                _getGiftList(searchedContactname);
              });
            },
            decoration: InputDecoration(
              filled: true,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              fillColor: const Color(0x0fffffff),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              hintText: 'Suchen...',
              prefixIcon: const Icon(Icons.search_rounded, size: 24.0),
              suffixIcon: _searchTermTextController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () => setState(() {
                        _clearSearchField();
                      }),
                      icon: const Icon(Icons.cancel_outlined),
                    )
                  : null,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            icon: const Icon(Icons.settings_rounded),
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
                    selectedColor: Colors.cyanAccent.shade400,
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
            future: _getGiftList(_searchTermTextController.text),
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
