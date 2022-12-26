import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '/models/gift.dart';
import '/models/enums/events.dart';

import '/components/cards/gift_card.dart';
import '/components/texts/centered_text.dart';
import '/components/modal_bottom_sheets/filter_gift_options_bottom_sheet.dart';

class GiftListScreen extends StatefulWidget {
  const GiftListScreen({Key? key}) : super(key: key);

  @override
  State<GiftListScreen> createState() => _GiftListScreenState();
}

class _GiftListScreenState extends State<GiftListScreen> with TickerProviderStateMixin {
  final TextEditingController _searchTermTextController = TextEditingController(text: '');
  List<String> eventFilter = [];
  late List<Gift> gifts = [];
  int selectedFilterIndex = 0;
  String giftFilter = 'Alle'; // TODO Eigenes Enum für Geschenkfilter anlegen oder in Geschenk Status integrieren?
  late Animation<double> _cardFadeInAnimation;

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

  Future<List<Gift>> _getGiftList(String searchTerm, String stateFilter) async {
    int giftNumber = 0;
    var giftBox = await Hive.openBox('gifts');
    gifts.clear();
    for (int i = 0; i < giftBox.length; i++) {
      Gift tempGift = giftBox.getAt(i);
      if (tempGift.contact.contactname.toLowerCase().contains(searchTerm.toLowerCase()) || tempGift.giftname.toLowerCase().contains(searchTerm.toLowerCase())) {
        if (stateFilter == 'Alle' || tempGift.giftState.toLowerCase().contains(stateFilter.toLowerCase())) {
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
    }
    _startCardFadeInAnimation();
    return gifts;
  }

  void _startCardFadeInAnimation() {
    AnimationController fadeInAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _cardFadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(fadeInAnimation);
    fadeInAnimation.forward();
  }

  void _clearSearchField() {
    _searchTermTextController.text = '';
    _getGiftList(_searchTermTextController.text, giftFilter);
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 14.0, 18.0, 14.0),
              child: SizedBox(
                height: 42.0,
                child: TextFormField(
                  controller: _searchTermTextController,
                  onChanged: (String searchedContactname) {
                    setState(() {
                      _getGiftList(searchedContactname, giftFilter);
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    fillColor: const Color(0x0fffffff),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
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
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(12.0, 8.0, 0.0, 8.0),
                  child: Text(
                    'Geschenkliste:',
                    style: TextStyle(fontSize: 21.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: TextButton.icon(
                    label: Text(
                      giftFilter,
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 16.0,
                      ),
                    ),
                    icon: const Icon(
                      Icons.filter_list_rounded,
                      color: Colors.cyanAccent,
                      size: 24.0,
                    ),
                    onPressed: () => showCupertinoModalBottomSheet(
                      context: context,
                      builder: (context) => FilterGiftOptionsBottomSheet(
                        giftFilterCallback: (newGiftFilter) => setState(
                          () => giftFilter = newGiftFilter,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 54,
              child: ListView.builder(
                itemCount: eventFilter.length,
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 4.0),
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
            FutureBuilder<List<Gift>>(
              future: _getGiftList(_searchTermTextController.text, giftFilter),
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
                          child: RefreshIndicator(
                            onRefresh: () {
                              var gifts = _getGiftList(_searchTermTextController.text, giftFilter);
                              setState(() {});
                              return gifts;
                            },
                            color: Colors.cyanAccent,
                            child: ListView.builder(
                              itemCount: gifts.length,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                return gifts[index].showInFilteredList
                                    ? FadeTransition(
                                        opacity: _cardFadeInAnimation,
                                        child: GiftCard(
                                          gift: gifts[index],
                                        ),
                                      )
                                    : const SizedBox.shrink();
                              },
                            ),
                          ),
                        );
                      }
                    }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
