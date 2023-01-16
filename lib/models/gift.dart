import 'dart:core';

import 'package:geschenkliste/models/enums/gift_state.dart';
import 'package:hive/hive.dart';

import '/models/contact.dart';
import '/models/event.dart';

import '/models/enums/events.dart';

@HiveType(typeId: 0)
class Gift extends HiveObject {
  late int boxPosition;
  late bool showInFilteredList;
  late int remainingDaysToEvent;
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
      Gift gift = giftBox.getAt(i);
      if (gift.contact.contactname.toLowerCase().contains(searchTerm.toLowerCase()) || gift.giftname.toLowerCase().contains(searchTerm.toLowerCase())) {
        if (stateFilter == 'Alle' || gift.giftState.toLowerCase().contains(stateFilter.toLowerCase())) {
          gifts.add(giftBox.getAt(i));
          gifts[giftNumber].boxPosition = giftNumber;
          gifts[giftNumber].remainingDaysToEvent = gift.getRemainingDaysToEvent();
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
    gifts.sort((first, second) => first.remainingDaysToEvent.compareTo(second.remainingDaysToEvent));
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

  int getRemainingDaysToEvent() {
    if (event.eventDate == null) {
      return 9999;
    }
    DateTime eventDate = DateTime(event.eventDate!.year, event.eventDate!.month, event.eventDate!.day);
    DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return (eventDate.difference(today).inHours / 24).round();
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
