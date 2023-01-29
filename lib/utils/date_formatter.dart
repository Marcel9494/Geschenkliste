DateTime StringToSavedDateFormatYYYYMMDD(String inputDate) {
  String day = inputDate.substring(0, 2);
  String month = inputDate.substring(3, 5);
  String year = inputDate.substring(6, 10);
  return DateTime.parse('$year-$month-$day');
}
