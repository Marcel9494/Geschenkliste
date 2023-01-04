enum GiftState {
  idea,
  bought,
  packed,
  gifted,
}

extension GiftStateExtension on GiftState {
  String get name {
    switch (this) {
      case GiftState.idea:
        return 'Idee';
      case GiftState.bought:
        return 'Gekauft';
      case GiftState.packed:
        return 'Verpackt';
      case GiftState.gifted:
        return 'Geschenkt';
      default:
        return '';
    }
  }
}
