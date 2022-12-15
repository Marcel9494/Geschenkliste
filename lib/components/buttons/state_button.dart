import 'package:flutter/material.dart';

class StateButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isSelected;

  const StateButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isSelected ? Icon(icon, size: 14.0) : const SizedBox.shrink(),
          Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: Text(
              text,
              style: const TextStyle(fontSize: 12.0),
            ),
          ),
        ],
      ),
    );
  }
}
