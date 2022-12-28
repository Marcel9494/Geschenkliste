import 'package:test/test.dart';

import 'package:geschenkliste/models/event.dart';

void main() {
  test('Test, ob Filternamen von Events wie erwartet zurückgegeben wird.', () async {
    List<String> events = Event.getEventFilterNames();

    expect(events, ['Alle', 'Geburtstag', 'Heiligabend', 'Nikolaus', 'Ostern']);
  });
}
