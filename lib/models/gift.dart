import 'dart:core';

import 'package:hive/hive.dart';

import '/models/contact.dart';
import '/models/event.dart';

import '/models/enums/events.dart';

@HiveType(typeId: 0)
class Gift extends HiveObject {
  late int boxPosition;
  late bool showInFilteredList;
  @HiveField(0)
  late String giftname;
  @HiveField(1)
  late Contact contact;
  @HiveField(2)
  late Event event;
  @HiveField(3)
  late String note;
  @HiveField(4)
  late String giftState;

  static Future<List<Gift>> getGiftList(String searchTerm, String stateFilter, int selectedFilterIndex) async {
    List<String> eventFilter = Event.getEventFilterNames();
    List<Gift> gifts = [];
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
    return gifts;
  }
}

class GiftAdapter extends TypeAdapter<Gift> {
  @override
  final typeId = 0;

  @override
  Gift read(BinaryReader reader) {
    return Gift()
      ..giftname = reader.read()
      ..contact = reader.read()
      ..event = reader.read()
      ..note = reader.read()
      ..giftState = reader.read();
  }

  @override
  void write(BinaryWriter writer, Gift obj) {
    writer.write(obj.giftname);
    writer.write(obj.contact);
    writer.write(obj.event);
    writer.write(obj.note);
    writer.write(obj.giftState);
  }
}
