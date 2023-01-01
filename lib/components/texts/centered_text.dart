import 'package:flutter/material.dart';

class CenteredText extends StatelessWidget {
  final String text;
  final int divider;

  const CenteredText({
    Key? key,
    required this.text,
    this.divider = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / divider,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }
}
