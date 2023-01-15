import 'package:flutter/material.dart';

class CenteredText extends StatelessWidget {
  final String text;
  final double divider;

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16.0),
          ),
        ),
      ),
    );
  }
}
