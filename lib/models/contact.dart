import 'dart:core';

import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Contact extends HiveObject {
  late int boxPosition;
  @HiveField(0)
  late String contactname;
  @HiveField(1)
  late DateTime? birthday;
  @HiveField(2)
  late List<String> archivedGiftsData; // TODO https://github.com/hivedb/hive/issues/33
  late DateTime? nextBirthday;
  late int remainingDays;
  late int birthdayAge;

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
      ..archivedGiftsData = reader.read();
  }

  @override
  void write(BinaryWriter writer, Contact obj) {
    writer.write(obj.contactname);
    writer.write(obj.birthday);
    writer.write(obj.archivedGiftsData);
  }
}
