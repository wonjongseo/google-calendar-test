import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' as m;
import 'package:intl/intl.dart';

class DatetimeHelper {
  static Future<DateTime?> showDatePicker(
    BuildContext context, {
    DateTime? initialDate,
  }) async {
    return m.showDatePicker(
      locale: const Locale("ja"),
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2018),
      lastDate: DateTime.now().add(Duration(days: 360)),
    );
  }

  static Future<m.TimeOfDay?> showTimePicker(
    BuildContext context, {
    m.TimeOfDay? timeOfDay,
  }) async {
    return m.showTimePicker(
      context: context,
      initialTime: timeOfDay ?? m.TimeOfDay.now(),
    );
  }

  static String dateTime2YYYYMMDDHhMM(DateTime? dt) {
    if (dt == null) return "";
    return DateFormat("yyyy/MM/dd hh:mm").format(dt);
  }

  static String dateTime2YYYYMMDD(DateTime? dt) {
    if (dt == null) return "";
    return DateFormat("yyyy/MM/dd").format(dt);
  }

  static String dateTime2HhMM(DateTime dt) {
    return DateFormat.Hm().format(dt);
  }
}
