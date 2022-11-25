import 'package:flutter/material.dart';

class EventFilterChip extends StatelessWidget {
  final String eventText;

  const EventFilterChip({
    Key? key,
    required this.eventText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 4.0, 0.0, 4.0),
      child: FilterChip(
        label: Text(eventText),
        onSelected: (_) => {},
      ),
    );
  }
}
