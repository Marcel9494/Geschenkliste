enum Events {
  birthday,
  christmas,
  easter,
  anyDate,
}

extension EventsExtension on Events {
  String get name {
    switch (this) {
      case Events.birthday:
        return 'Geburtstag';
      case Events.christmas:
        return 'Weihnachtsabend';
      case Events.easter:
        return 'Ostern';
      case Events.anyDate:
        return 'Beliebiges Datum';
      default:
        return '';
    }
  }
}
