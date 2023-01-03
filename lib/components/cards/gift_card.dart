import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../modal_bottom_sheets/gift_options_bottom_sheet.dart';
import '../modal_bottom_sheets/change_state_options_bottom_sheet.dart';

import '/models/gift.dart';
import '/models/enums/gift_state.dart';

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
  set updatedGiftState(String value) => (widget.gift.giftState = value);
  String eventDateString = '';

  @override
  initState() {
    super.initState();
    getCurrentGiftState();
    DateFormat dateFormatter = DateFormat('EE, dd. LLL.', 'de');
    eventDateString = widget.gift.event.eventDate == null ? '' : dateFormatter.format(widget.gift.event.eventDate!);
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
    if (widget.gift.giftState == GiftStatus.idea.name) {
      return Icon(Icons.tips_and_updates_rounded, size: 12.0, color: Colors.cyanAccent, key: ValueKey(widget.gift.giftState));
    } else if (widget.gift.giftState == GiftStatus.bought.name) {
      return Icon(Icons.shopping_cart, size: 12.0, color: Colors.cyanAccent, key: ValueKey(widget.gift.giftState));
    } else if (widget.gift.giftState == GiftStatus.packed.name) {
      return Icon(Icons.card_giftcard_rounded, size: 12.0, color: Colors.cyanAccent, key: ValueKey(widget.gift.giftState));
    }
    return Icon(Icons.volunteer_activism_rounded, size: 12.0, color: Colors.cyanAccent, key: ValueKey(widget.gift.giftState));
  }

  int _getRemainingDaysToEvent() {
    if (widget.gift.event.eventDate == null) {
      return 9999;
    }
    DateTime eventDate = DateTime(DateTime.now().year + 1, widget.gift.event.eventDate!.month, widget.gift.event.eventDate!.day);
    DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return (eventDate.difference(today).inHours / 24).round() % 365; // TODO Schaltjahre mit berücksichtigen (366 Tage)
  }

  Color _getRemainingDaysColor() {
    int remainingDays = _getRemainingDaysToEvent();
    if (remainingDays == 9999) {
      return Colors.cyanAccent;
    } else if (remainingDays >= 14) {
      return Colors.greenAccent;
    } else if (remainingDays < 14 && remainingDays >= 1) {
      return Colors.yellow.shade300;
    }
    return Colors.red.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: Card(
        color: const Color(0x0fffffff),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: ClipPath(
          clipper: ShapeBorderClipper(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: _getRemainingDaysColor(), width: 5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Chip(
                          labelPadding: const EdgeInsets.symmetric(vertical: -3.0, horizontal: 5.0),
                          avatar: CircleAvatar(
                            backgroundColor: Colors.grey.shade800,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 600),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return ScaleTransition(scale: animation, child: child);
                              },
                              child: getIcon(),
                            ),
                          ),
                          label: SizedBox(
                            width: 80.0,
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 600),
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  return ScaleTransition(scale: animation, child: child);
                                },
                                child: Text(
                                  widget.gift.giftState,
                                  key: ValueKey(widget.gift.giftState),
                                  style: const TextStyle(
                                    letterSpacing: 1.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      onTap: () => showCupertinoModalBottomSheet(
                        context: context,
                        builder: (context) => ChangeStateOptionsBottomSheet(
                          giftBoxPosition: widget.gift.boxPosition,
                          updatedGiftStateCallback: (newGiftSate) => setState(() => widget.gift.giftState = newGiftSate),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14.0, 0.0, 10.0, 0.0),
                        child: Text(
                          'Für ${widget.gift.contact.contactname}',
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
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
                  padding: const EdgeInsets.only(top: 16.0, left: 20.0),
                  child: Text(
                    widget.gift.giftname,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 22.0, left: 20.0, bottom: 16.0),
                  child: Text(
                    widget.gift.note.isEmpty ? 'Notizen: -' : 'Notizen: ${widget.gift.note}',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, left: 20.0, bottom: 16.0, right: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.gift.event.eventname,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        widget.gift.event.eventDate == null ? '' : '•',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        eventDateString,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        widget.gift.event.eventDate == null ? '' : '•',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      RichText(
                        text: widget.gift.event.eventDate == null
                            ? const TextSpan(children: [])
                            : TextSpan(
                                style: const TextStyle(color: Colors.grey),
                                children: [
                                  const TextSpan(text: 'Noch: '),
                                  TextSpan(
                                    text: _getRemainingDaysToEvent() == 1 ? '${_getRemainingDaysToEvent()} Tag' : '${_getRemainingDaysToEvent()} Tage',
                                    style: TextStyle(
                                      color: _getRemainingDaysColor(),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
