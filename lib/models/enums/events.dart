enum Events {
  anyDate,
  birthday,
  wedding,
  christmas,
  nicholas,
  easter,
}

extension EventsExtension on Events {
  String get name {
    switch (this) {
      case Events.birthday:
        return 'Geburtstag';
      case Events.wedding:
        return 'Hochzeit';
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
        return 'Geburtstage';
      case Events.wedding:
        return 'Hochzeiten';
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
