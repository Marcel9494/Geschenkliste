import 'dart:core';

import 'package:hive/hive.dart';

import 'gift.dart';

@HiveType(typeId: 1)
class Contact extends HiveObject {
  late int boxPosition;
  @HiveField(0)
  late String contactname;
  @HiveField(1)
  late DateTime? birthday;
  late DateTime? nextBirthday;
  late int remainingDays;
  late int birthdayAge;
  @HiveField(2)
  late List<Gift> archivedGifts;

  Contact();
}

class ContactAdapter extends TypeAdapter<Contact> {
  @override
  final typeId = 1;

  @override
  Contact read(BinaryReader reader) {
    return Contact()
      ..contactname = reader.read()
      ..birthday = reader.read()
      ..archivedGifts = reader.read();
  }

  @override
  void write(BinaryWriter writer, Contact obj) {
    writer.write(obj.contactname);
    writer.write(obj.birthday);
    writer.write(obj.archivedGifts);
  }
}
