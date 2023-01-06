import 'package:hive/hive.dart';

import '/models/enums/events.dart';

@HiveType(typeId: 2)
class Event extends HiveObject {
  late String eventname;
  late DateTime? eventDate;

  Event({required this.eventname, this.eventDate, currentDate}) {
    if (eventname == Events.easter.name) {
      eventDate = _easterCalculation(currentDate.year);
      if (eventDate!.month <= currentDate.month) {
        if (eventDate!.day <= currentDate.day) {
          eventDate = _easterCalculation(currentDate.year + 1);
        }
      }
      return;
    }
    if (eventDate == null) {
      return;
    }
    if (eventDate!.month >= currentDate.month) {
      if (eventDate!.day <= currentDate.day) {
        eventDate = DateTime(currentDate.year + 1, eventDate!.month, eventDate!.day);
        return;
      }
    }
    eventDate = DateTime(currentDate.year, eventDate!.month, eventDate!.day);
  }

  // Gaußsche Osterformel für die Jahre 2000 bis 2099 => M = 24 und N = 5
  DateTime? _easterCalculation(int year) {
    int a = year % 4;
    int b = year % 7;
    int c = year % 19;
    int d = (19 * c + 24) % 30;
    int e = (2 * a + 4 * b + 6 * d + 5) % 7;
    double f = (c + 11 * d + 22 * e) / 451;
    int easterSunday = 22 + d + e;
    if (easterSunday <= 31) {
      eventDate = DateTime(year, 3, easterSunday);
    } else {
      easterSunday = d + e - 9;
      eventDate = DateTime(year, 4, easterSunday);
    }
    return eventDate;
  }

  static List<String> getEventNames() {
    List<String> eventList = [];
    for (int i = 0; i < Events.values.length; i++) {
      eventList.add(Events.values[i].name);
    }
    return eventList;
  }

  static List<String> getEventFilterNames() {
    List<String> eventList = [];
    for (int i = 0; i < Events.values.length; i++) {
      eventList.add(Events.values[i].filterName);
    }
    return eventList;
  }
}

class EventAdapter extends TypeAdapter<Event> {
  @override
  final typeId = 2;

  @override
  Event read(BinaryReader reader) {
    return Event(eventname: '')
      ..eventname = reader.read()
      ..eventDate = reader.read();
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer.write(obj.eventname);
    writer.write(obj.eventDate);
  }
}
