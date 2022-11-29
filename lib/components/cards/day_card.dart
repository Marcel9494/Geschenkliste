import 'package:flutter/material.dart';

class DayCard extends StatelessWidget {
  final int days;

  const DayCard({
    Key? key,
    required this.days,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.only(left: 6.0),
        child: Card(
          color: const Color(0x0fffffff),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            child: Center(
              child: Text(
                days == 9999
                    ? '-'
                    : days == 0
                        ? 'Heute'
                        : 'Noch\n${days.toString()} ${days != 1 ? 'Tage' : 'Tag'}',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
