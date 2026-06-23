import 'package:intl/intl.dart';

String formatWorkDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) return "Select Date";

  try {
    final utcDate = DateTime.parse(dateString).toUtc();
    final localDate = utcDate.toLocal();
    return DateFormat('MM/dd/yyyy').format(localDate);
  } catch (e) {
    return dateString;
  }
}

String formatWorkTime(String? timeString) {
  if (timeString == null || timeString.isEmpty) return "Select Time";

  try {
    final utcDate = DateTime.parse(timeString).toUtc();
    final localDate = utcDate.toLocal();
    return DateFormat('hh:mm a').format(localDate);
  } catch (e) {
    return timeString;
  }
}