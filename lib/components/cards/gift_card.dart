import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../modal_bottom_sheets/gift_options_bottom_sheet.dart';

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
  String? selectedMenuItem;
  List<bool> isSelected = [true, false, false, false];

  void _showNotes() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Notizen'),
          content: Text(widget.gift.note),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.cyanAccent,
                onPrimary: Colors.black87,
              ),
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.only(left: 6.0),
        child: Card(
          color: const Color(0xFF272727),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12.0, left: 20.0),
                      child: Text(widget.gift.giftname),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: SizedBox(
                      height: 30,
                      width: 90,
                      child: CustomPaint(
                        size: const Size(90, 30),
                        painter: MyLabelPainter(),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Text(
                              widget.gift.giftStatus,
                              style: const TextStyle(color: Colors.white, fontSize: 12.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12.0, left: 20.0, bottom: 2.0),
                      child: Text('Für ${widget.gift.contact.contactname}'),
                    ),
                  ),
                  IconButton(
                    padding: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 4.0),
                    constraints: const BoxConstraints(),
                    onPressed: () => _showNotes(),
                    icon: const Icon(Icons.event_note_rounded),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 20.0),
                      child: Text(widget.gift.event.eventname),
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
              Row(
                children: [
                  ToggleButtons(
                    onPressed: (int index) {
                      setState(() {
                        for (int i = 0; i < isSelected.length; i++) {
                          isSelected[i] = i == index;
                        }
                      });
                    },
                    isSelected: isSelected,
                    selectedColor: Colors.cyanAccent,
                    selectedBorderColor: Colors.cyanAccent,
                    borderRadius: BorderRadius.circular(4.0),
                    constraints: const BoxConstraints(minHeight: 30),
                    children: const <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 9.0),
                        child: Text(
                          'Idee',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 9.0),
                        child: Text(
                          'Gekauft',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 9.0),
                        child: Text(
                          'Verpackt',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 9.0),
                        child: Text(
                          'Geschenkt',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyLabelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 0.5;
    canvas.drawLine(const Offset(0, 0), const Offset(90, 0), paint);
    canvas.drawLine(const Offset(90, 30), const Offset(0, 30), paint);
    canvas.drawLine(const Offset(0, 30), const Offset(15, 15), paint);
    canvas.drawLine(const Offset(15, 15), const Offset(0, 0), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
