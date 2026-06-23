import 'package:intl/intl.dart';

String formatDate(String? date) {
  if (date == null) return "";

  try {

    final localDate =
    DateTime.parse(date).toLocal();

    return DateFormat("MMM d")
        .format(localDate);

  } catch (e) {

    return date;
  }
}


String formatSchedule(
    String? date,
    String? time,
    ) {

  if (date == null) return "";

  try {

    final localDate =
    DateTime.parse(date).toLocal();

    final formattedDate =
    DateFormat("MMM d")
        .format(localDate);

    return "$formattedDate, ${time ?? ""}";

  } catch (e) {

    return "$date ${time ?? ""}";
  }
}