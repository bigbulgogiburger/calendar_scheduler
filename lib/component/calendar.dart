import 'package:calendar_scheduler/const/color.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatelessWidget {

  final DateTime? selectedDay;
  final DateTime focusedDay;
  final OnDaySelected onDaySelected;

  const Calendar({
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    final defaultBoxDeco = BoxDecoration(
        color: Colors.grey[200], borderRadius: BorderRadius.circular(6.0));

    final defaultTextStyle = TextStyle(
      color: Colors.grey[600],
      fontWeight: FontWeight.w700,
    );

    return TableCalendar(
      locale: 'ko_KR',
      focusedDay: focusedDay,
      firstDay: DateTime(1800),
      lastDay: DateTime(3000),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16.0,
        ),
      ),
      calendarStyle: CalendarStyle(
        isTodayHighlighted: false,
        defaultDecoration: defaultBoxDeco,
        weekendDecoration: defaultBoxDeco,
        selectedDecoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(color: PRIMARY_COLOR, width: 1.0)),
        outsideDecoration: BoxDecoration(shape: BoxShape.rectangle),
        defaultTextStyle: defaultTextStyle,
        weekendTextStyle: defaultTextStyle,
        selectedTextStyle: defaultTextStyle.copyWith(
          color: PRIMARY_COLOR,
        ),
      ),
      onDaySelected: onDaySelected,
      //

      selectedDayPredicate: (DateTime date) {
        if (selectedDay == null) {
          return false;
        }
        // date == selectedDay 이렇게는 시분초까지 같아야함.
        return date.year == selectedDay!.year &&
            date.month == selectedDay!.month &&
            date.day == selectedDay!.day;
      },
    );
  }
}
