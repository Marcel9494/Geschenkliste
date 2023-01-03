import 'package:flutter/material.dart';

class DayCard extends StatelessWidget {
  final int days;

  const DayCard({
    Key? key,
    required this.days,
  }) : super(key: key);

  Color _getRemainingDaysToBirthdayColor() {
    if (days == 9999) {
      return Colors.transparent;
    } else if (days >= 14) {
      return Colors.greenAccent;
    } else if (days < 14 && days >= 1) {
      return Colors.yellow.shade300;
    }
    return Colors.cyanAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.only(left: 6.0),
        child: Card(
          color: const Color(0x0fffffff),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
          ),
          child: ClipPath(
            clipper: ShapeBorderClipper(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: _getRemainingDaysToBirthdayColor(), width: 4)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: days == 9999
                        ? const TextSpan(
                            style: TextStyle(color: Colors.grey),
                            children: [
                              TextSpan(text: '-'),
                            ],
                          )
                        : TextSpan(
                            style: const TextStyle(color: Colors.grey),
                            children: [
                              TextSpan(text: days == 0 ? '' : 'Noch:\n'),
                              TextSpan(
                                text: days == 0
                                    ? 'Heute'
                                    : days == 1
                                        ? '$days Tag'
                                        : '$days Tage',
                                style: TextStyle(
                                  color: _getRemainingDaysToBirthdayColor(),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
