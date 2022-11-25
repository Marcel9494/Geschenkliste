import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class SaveButton extends StatelessWidget {
  final int boxPosition;
  final Function callback;
  final RoundedLoadingButtonController buttonController;

  const SaveButton({
    Key? key,
    required this.boxPosition,
    required this.callback,
    required this.buttonController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: RoundedLoadingButton(
        controller: buttonController,
        onPressed: () => callback(),
        color: Colors.cyanAccent,
        successColor: Colors.green,
        height: 40.0,
        child: Text(
          boxPosition == -1 ? 'Erstellen' : 'Speichern',
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
