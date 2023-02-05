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
  late List<String> archivedGiftsData;
  late DateTime? nextBirthday;
  late int remainingDays;
  late int birthdayAge;

  Contact();

  int getBirthdayAge() {
    if (birthday == null) {
      return 0;
    }
    if (birthday!.month > DateTime.now().month) {
      birthdayAge = DateTime.now().year - birthday!.year;
    } else if (birthday!.month == DateTime.now().month) {
      if (birthday!.day > DateTime.now().day) {
        birthdayAge = DateTime.now().year - birthday!.year;
      } else {
        birthdayAge = (DateTime.now().year + 1) - birthday!.year;
      }
    } else {
      birthdayAge = (DateTime.now().year + 1) - birthday!.year;
    }
    return birthdayAge;
  }

  DateTime? getNextBirthday() {
    if (birthday == null) {
      return DateTime(1, 0, 0);
    }
    if (birthday!.month > DateTime.now().month) {
      nextBirthday = DateTime(DateTime.now().year, birthday!.month, birthday!.day);
    } else if (birthday!.month == DateTime.now().month) {
      if (birthday!.day > DateTime.now().day) {
        nextBirthday = DateTime(DateTime.now().year, birthday!.month, birthday!.day);
      } else {
        nextBirthday = DateTime(DateTime.now().year + 1, birthday!.month, birthday!.day);
      }
    } else {
      nextBirthday = DateTime(DateTime.now().year + 1, birthday!.month, birthday!.day);
    }
    return nextBirthday;
  }

  int getRemainingDaysToBirthday() {
    if (birthday == null) {
      return 9999;
    }
    DateTime eventDate = DateTime(DateTime.now().year + 1, birthday!.month, birthday!.day);
    DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    int daysPerYear = 365;
    if (birthday!.year % 4 == 0) {
      daysPerYear = 366; // Schaltjahr
    }
    return (eventDate.difference(today).inHours / 24).round() % daysPerYear;
  }
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
