import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../models/contact.dart';
import '../../models/enums/gift_state.dart';
import '../modal_bottom_sheets/gift_options_bottom_sheet.dart';
import '../modal_bottom_sheets/change_state_options_bottom_sheet.dart';

import '/models/gift.dart';

class GiftCard extends StatefulWidget {
  final Gift gift;

  const GiftCard({
    Key? key,
    required this.gift,
  }) : super(key: key);

  @override
  State<GiftCard> createState() => _GiftCardState();
}

class _GiftCardState extends State<GiftCard> {
  List<bool> isGiftStateSelected = [false, false, false, false];
  String _string = '';
  set string(String value) => setState(() => _string = value);

  @override
  initState() {
    super.initState();
    getCurrentGiftState();
  }

  void getCurrentGiftState() async {
    var giftBox = await Hive.openBox('gifts');
    Gift gift = giftBox.getAt(widget.gift.boxPosition);
    for (int i = 0; i < isGiftStateSelected.length; i++) {
      if (gift.giftState == GiftStatus.values[i].name) {
        isGiftStateSelected[i] = true;
      } else {
        isGiftStateSelected[i] = false;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: Card(
        color: const Color(0x0fffffff),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      widget.gift.giftname,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  child: Chip(
                    labelPadding: const EdgeInsets.symmetric(vertical: -3.0, horizontal: 5.0),
                    avatar: CircleAvatar(
                      backgroundColor: Colors.grey.shade800,
                      child: const Icon(Icons.tips_and_updates_rounded, size: 13.0),
                    ),
                    label: SizedBox(
                      width: 60.0,
                      child: Center(
                        child: Text(_string == '' ? widget.gift.giftState : _string),
                      ),
                    ),
                  ),
                  onTap: () => showCupertinoModalBottomSheet(
                    context: context,
                    builder: (context) => ChangeStateOptionsBottomSheet(giftBoxPosition: widget.gift.boxPosition, callback: (val) => setState(() => _string = val)),
                  ),
                ),
                IconButton(
                  onPressed: () => showCupertinoModalBottomSheet(
                    context: context,
                    builder: (context) => GiftOptionsBottomSheet(giftBoxPosition: widget.gift.boxPosition),
                  ),
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6.0, left: 20.0, bottom: 2.0),
              child: Text(
                'Für ${widget.gift.contact.contactname}',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 18.0, left: 20.0, bottom: 12.0),
              child: Text(
                '${widget.gift.event.eventname} • ${widget.gift.event.eventDate?.day}.${widget.gift.event.eventDate?.month}.${widget.gift.event.eventDate?.year} • In X Tagen',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 18.0, left: 20.0, bottom: 12.0),
              child: Text(
                widget.gift.note.isEmpty ? 'Notizen: -' : 'Notizen: ${widget.gift.note}',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            /*Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ToggleButtons(
                  onPressed: (int index) {
                    setState(() {
                      for (int i = 0; i < isGiftStateSelected.length; i++) {
                        isGiftStateSelected[i] = i == index;
                        if (i == index) {
                          updateGiftState(GiftStatus.values[i].name);
                        }
                      }
                      if (isGiftStateSelected[3]) {
                        _showArchiveGiftDialog();
                      }
                    });
                  },
                  isSelected: isGiftStateSelected,
                  selectedColor: Colors.cyanAccent,
                  selectedBorderColor: Colors.cyanAccent,
                  borderRadius: BorderRadius.circular(4.0),
                  constraints: const BoxConstraints(minHeight: 36),
                  children: <Widget>[
                    StateButton(
                      text: 'Idee',
                      icon: Icons.tips_and_updates_rounded,
                      isSelected: isGiftStateSelected[0],
                    ),
                    StateButton(
                      text: 'Gekauft',
                      icon: Icons.shopping_cart,
                      isSelected: isGiftStateSelected[1],
                    ),
                    StateButton(
                      text: 'Verpackt',
                      icon: Icons.card_giftcard_rounded,
                      isSelected: isGiftStateSelected[2],
                    ),
                    StateButton(
                      text: 'Geschenkt',
                      icon: Icons.volunteer_activism_rounded,
                      isSelected: isGiftStateSelected[3],
                    ),
                  ],
                ),
              ],
            ),*/
          ],
        ),
      ),
    );
  }
}
