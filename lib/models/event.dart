import 'package:hive/hive.dart';

import '/models/enums/events.dart';

@HiveType(typeId: 2)
class Event extends HiveObject {
  Event({required this.eventname, this.eventDate, currentDate}) {
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

  late String eventname;
  late DateTime? eventDate;

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
