enum GiftStatus {
  idea,
  bought,
  packed,
  gifted,
}

extension GiftStatusExtension on GiftStatus {
  String get name {
    switch (this) {
      case GiftStatus.idea:
        return 'Idee';
      case GiftStatus.bought:
        return 'Gekauft';
      case GiftStatus.packed:
        return 'Verpackt';
      case GiftStatus.gifted:
        return 'Geschenkt';
      default:
        return '';
    }
  }
}
