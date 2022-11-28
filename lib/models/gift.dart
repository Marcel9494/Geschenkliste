import 'dart:core';

import 'package:hive/hive.dart';

import '/models/contact.dart';
import '/models/event.dart';
import 'enums/gift_status.dart';

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
  late String giftStatus;
  @HiveField(5)
  late int creationDate;
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
      ..giftStatus = reader.read()
      ..creationDate = reader.read();
  }

  @override
  void write(BinaryWriter writer, Gift obj) {
    writer.write(obj.giftname);
    writer.write(obj.contact);
    writer.write(obj.event);
    writer.write(obj.note);
    writer.write(obj.giftStatus);
    writer.write(obj.creationDate);
  }
}
