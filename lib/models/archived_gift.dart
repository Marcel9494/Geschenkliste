class ArchivedGift {
  late int index;
  late String giftname;
  late String eventname;
  late String eventDate; // TODO Datentyp zu DateTime umändern?
  late String note;
  late String giftState;

  ArchivedGift({
    required this.index,
    required this.giftname,
    required this.eventname,
    required this.eventDate,
    required this.note,
    required this.giftState,
  });
}