import 'dart:ui';

import 'package:intl/intl.dart';

String getCurrentDatetime() {
  final now = DateTime.now().toUtc();
  final DateFormat formatter = DateFormat('yyyy-MM-ddTHH:mm:ss');
  return formatter.format(now);
}

String getNextDayStartDatetime() {
  final now = DateTime.now().toUtc();
  final nextDay = DateTime.utc(now.year, now.month, now.day + 1);
  final DateFormat formatter = DateFormat('yyyy-MM-ddTHH:mm:ss');
  return formatter.format(nextDay);
}

class Constants {

  static Color MyPrimaryColor = Color(0xFF7935D9FF);

  static String getUpcomingContests(){
  String nextDayStartDatetime = getNextDayStartDatetime();
  return 'https://clist.by/api/v4/contest/?upcoming=true&resource_id__in=1%2C2%2C12%2C26%2C63%2C73%2C93%2C102%2C126&start__gte=$nextDayStartDatetime';
  }

  static String getOngoingContests() {
    String currentDatetime = getCurrentDatetime();
    return 'https://clist.by/api/v4/contest/?resource_id__in=1%2C2%2C12%2C26%2C63%2C73%2C93%2C102%2C126&start__lt=$currentDatetime&end__gt=$currentDatetime';
  }

  static String getFurtherDayContests() {
    String currentDatetime = getCurrentDatetime();
    String nextDayStartDatetime = getNextDayStartDatetime();
    return 'https://clist.by/api/v4/contest/?upcoming=true&&resource_id__in=1%2C2%2C12%2C26%2C63%2C73%2C93%2C102%2C126&start__gt=$currentDatetime&end__lt=$nextDayStartDatetime';
  }

  static bool isValidEmail(String email) {
    // Define the regular expression for a valid email.
    final RegExp emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    // Use the regex to check if the email matches the pattern.
    return emailRegex.hasMatch(email);
  }


}

// print(Constants.upcomingContests);
// print(Constants.getOngoingContests());