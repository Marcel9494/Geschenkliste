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
    List<String> eventFilter = Event.getEventNames();
    List<Gift> gifts = [];
    int giftNumber = 0;
    var giftBox = await Hive.openBox('gifts');
    gifts.clear();
    for (int i = 0; i < giftBox.length; i++) {
      Gift tempGift = giftBox.getAt(i);
      if (tempGift.contact.contactname.toLowerCase().contains(searchTerm.toLowerCase()) || tempGift.giftname.toLowerCase().contains(searchTerm.toLowerCase())) {
        // TODO stateFilter um Alle erweitern?
        if (stateFilter == 'Alle' || tempGift.giftState.toLowerCase().contains(stateFilter.toLowerCase())) {
          gifts.add(giftBox.getAt(i));
          gifts[giftNumber].boxPosition = giftNumber;
          if (eventFilter[selectedFilterIndex] == Events.anyDate.name) {
            gifts[giftNumber].showInFilteredList = true;
          } else if (gifts[giftNumber].event.eventname == eventFilter[selectedFilterIndex]) {
            gifts[giftNumber].showInFilteredList = true;
          } else {
            gifts[giftNumber].showInFilteredList = false;
          }
          giftNumber++;
        }
      }
    }
    return gifts;
  }

  static bool checkIfFilteredGiftListIsEmpty(List<Gift> giftList) {
    for (int i = 0; i < giftList.length; i++) {
      if (giftList[i].showInFilteredList == true) {
        return false;
      }
    }
    return true;
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
