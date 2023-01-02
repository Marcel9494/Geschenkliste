import 'package:test/test.dart';
import 'package:intl/intl.dart';

import 'package:geschenkliste/models/event.dart';
import 'package:geschenkliste/models/contact.dart';
import 'package:geschenkliste/models/enums/events.dart';

void main() {
  test('Ein Tag vor Heiligabend. Es muss das aktuelle Jahr angezeigt werden.', () async {
    Event event = Event(eventname: Events.christmas.name, eventDate: DateTime(2023, 12, 24), currentDate: DateTime(2023, 12, 23));
    final DateFormat dateFormatter = DateFormat('dd.MM.yyyy');
    String formattedEventDate = dateFormatter.format(event.eventDate as DateTime);

    expect(event.eventname, 'Heiligabend');
    expect(formattedEventDate, '24.12.${DateTime.now().year}');
  });

  test('Erster Tag nach Heiligabend. Es muss das nächste Jahr angezeigt werden.', () async {
    Event event = Event(eventname: Events.christmas.name, eventDate: DateTime(2023, 12, 24), currentDate: DateTime(2023, 12, 25));
    final DateFormat dateFormatter = DateFormat('dd.MM.yyyy');
    String formattedEventDate = dateFormatter.format(event.eventDate as DateTime);

    expect(event.eventname, 'Heiligabend');
    expect(formattedEventDate, '24.12.${DateTime.now().year + 1}');
  });

  test('Test, ob Filternamen von Events wie erwartet zurückgegeben wird.', () async {
    List<String> events = Event.getEventFilterNames();

    expect(events, ['Alle', 'Geburtstage', 'Hochzeiten', 'Heiligabend', 'Nikolaus', 'Ostern']);
  });

  test('Temporärer Test', () async {
    Contact contact = Contact();
    contact.birthday = DateTime(1994, 07, 30);
    int birthdayAge = contact.getBirthdayAge();

    expect(birthdayAge, 29);
  });

  test('Temporärer Test', () async {
    Contact contact = Contact();
    contact.birthday = DateTime(1994, 01, 01);
    int birthdayAge = contact.getBirthdayAge();

    expect(birthdayAge, 30);
  });
}
