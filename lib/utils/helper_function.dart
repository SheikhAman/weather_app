import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String getFormattedDateTime(num dt, String pattern) {
  return DateFormat(pattern)
      .format(DateTime.fromMicrosecondsSinceEpoch(dt.toInt() * 1000));
}

String getFormattedDate(num date, String? pattern) {
  return DateFormat.yMMMd()
      .format(DateTime.fromMillisecondsSinceEpoch(date.toInt() * 1000));
}

String getFormattedTime(num date, String? pattern) {
  return DateFormat.jm()
      .format(DateTime.fromMillisecondsSinceEpoch(date.toInt() * 1000));
}

void showMsg(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg)),
  );
}

void showMsgWithAction(
    {required BuildContext context,
    required String msg,
    required VoidCallback callback}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(days: 365),
      content: Text(msg),
      action: SnackBarAction(
          label: 'Go to Settings',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            callback();
          }),
    ),
  );
}
