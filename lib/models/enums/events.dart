enum Events {
  anyDate,
  birthday,
  christmas,
  nicholas,
  easter,
}

extension EventsExtension on Events {
  String get name {
    switch (this) {
      case Events.birthday:
        return 'Geburtstag';
      case Events.christmas:
        return 'Heiligabend';
      case Events.nicholas:
        return 'Nikolaus';
      case Events.easter:
        return 'Ostern';
      case Events.anyDate:
        return 'Beliebiges Datum';
      default:
        return '';
    }
  }

  String get filterName {
    switch (this) {
      case Events.birthday:
        return 'Geburtstag';
      case Events.christmas:
        return 'Heiligabend';
      case Events.nicholas:
        return 'Nikolaus';
      case Events.easter:
        return 'Ostern';
      case Events.anyDate:
        return 'Alle';
      default:
        return '';
    }
  }
}
