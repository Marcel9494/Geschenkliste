typedef void StringCallback(String newContactname);

class CreateContactScreenArguments {
  final int contactBoxPosition;
  final bool backToCreateGiftScreen;
  final StringCallback newContactnameCallback;

  CreateContactScreenArguments(
    this.contactBoxPosition,
    this.backToCreateGiftScreen,
    this.newContactnameCallback,
  );
}
