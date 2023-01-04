import 'package:flutter/material.dart';

import '../../models/enums/gift_state.dart';

typedef GiftFilterCallback = void Function(String giftState);

class FilterGiftOptionsBottomSheet extends StatefulWidget {
  final GiftFilterCallback giftFilterCallback;

  const FilterGiftOptionsBottomSheet({
    Key? key,
    required this.giftFilterCallback,
  }) : super(key: key);

  @override
  State<FilterGiftOptionsBottomSheet> createState() => _ChangeFilterGiftOptionsBottomSheet();
}

class _ChangeFilterGiftOptionsBottomSheet extends State<FilterGiftOptionsBottomSheet> {
  void _changeGiftFilter(String giftFilter) {
    widget.giftFilterCallback(giftFilter);
    Navigator.pop(context);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Material(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 4.0),
                child: Container(
                  width: 75,
                  height: 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16.0, bottom: 16.0, left: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: Text('Geschenk Filter:', style: TextStyle(fontSize: 16.0)),
              ),
            ),
            const Divider(height: 0, color: Colors.grey),
            ListTile(
              onTap: () => _changeGiftFilter('Alle'),
              leading: const Icon(Icons.all_inclusive_rounded, color: Colors.cyanAccent),
              title: const Text('Alle'),
            ),
            const Divider(height: 0, color: Colors.grey),
            ListTile(
              onTap: () => _changeGiftFilter(GiftState.values[0].name),
              leading: const Icon(Icons.tips_and_updates_rounded, color: Colors.cyanAccent),
              title: Text(GiftState.idea.name),
            ),
            const Divider(height: 0, color: Colors.grey),
            ListTile(
              onTap: () => _changeGiftFilter(GiftState.values[1].name),
              leading: const Icon(Icons.shopping_cart, color: Colors.cyanAccent),
              title: Text(GiftState.bought.name),
            ),
            const Divider(height: 0, color: Colors.grey),
            ListTile(
              onTap: () => _changeGiftFilter(GiftState.values[2].name),
              leading: const Icon(Icons.card_giftcard_rounded, color: Colors.cyanAccent),
              title: Text(GiftState.packed.name),
            ),
            const Divider(height: 0, color: Colors.grey),
            ListTile(
              onTap: () => _changeGiftFilter(GiftState.values[3].name),
              leading: const Icon(Icons.volunteer_activism_rounded, color: Colors.cyanAccent),
              title: Text(GiftState.gifted.name),
            ),
          ],
        ),
      ),
    );
  }
}
