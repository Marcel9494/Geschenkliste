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
  //String _updatedGiftState = '';
  set updatedGiftState(String value) => setState(() => widget.gift.giftState = value);

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

  Icon getIcon() {
    if (widget.gift.giftState == 'Idee') {
      return const Icon(Icons.tips_and_updates_rounded, size: 12.0, color: Colors.cyanAccent);
    } else if (widget.gift.giftState == 'Gekauft') {
      return const Icon(Icons.shopping_cart, size: 12.0, color: Colors.cyanAccent);
    } else if (widget.gift.giftState == 'Verpackt') {
      return const Icon(Icons.card_giftcard_rounded, size: 12.0, color: Colors.cyanAccent);
    }
    return const Icon(Icons.volunteer_activism_rounded, size: 12.0, color: Colors.cyanAccent);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: Card(
        color: const Color(0x0fffffff),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0.0, 10.0, 0.0),
                    child: Text(
                      'Für ${widget.gift.contact.contactname}',
                      overflow: TextOverflow.fade,
                      softWrap: false,
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
                      child: getIcon(),
                    ),
                    label: SizedBox(
                      width: 70.0,
                      child: Center(
                        child: Text(
                          widget.gift.giftState,
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  onTap: () => showCupertinoModalBottomSheet(
                    context: context,
                    builder: (context) => ChangeStateOptionsBottomSheet(
                      giftBoxPosition: widget.gift.boxPosition,
                      updatedGiftStateCallback: (newGiftSate) => setState(
                        () => widget.gift.giftState = newGiftSate,
                      ),
                    ),
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
              padding: const EdgeInsets.only(top: 8.0, left: 20.0),
              child: Text(
                widget.gift.giftname,
                style: TextStyle(
                  color: Colors.grey.shade300,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
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
            const Divider(thickness: 2.0),
            Padding(
              padding: const EdgeInsets.only(top: 6.0, left: 20.0, bottom: 14.0),
              child: Text(
                '${widget.gift.event.eventname} • ${widget.gift.event.eventDate?.day}.${widget.gift.event.eventDate?.month}.${widget.gift.event.eventDate?.year} • Noch X Tage',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
