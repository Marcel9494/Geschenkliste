typedef void StringCallback(String newContactname);

class CreateContactScreenArguments {
  final int contactBoxPosition;
  final bool backToCreateGiftScreen;
  final StringCallback newContactnameCallback;
  final StringCallback newBirthdayCallback;

  CreateContactScreenArguments(
    this.contactBoxPosition,
    this.backToCreateGiftScreen,
    this.newContactnameCallback,
    this.newBirthdayCallback,
  );
}
