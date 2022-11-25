import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class Event extends HiveObject {
  Event({required this.eventname, this.eventDate});

  late String eventname;
  late DateTime? eventDate;
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
