import 'dart:async';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:contestify/Credentials/supabase_credentials.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import '../View/select_sound.dart';
import '../View_Models/contest_view_model.dart';
import '../main.dart';
import '../models/contest.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'dart:io';
import 'package:timezone/timezone.dart' as tz;
import 'error_widget.dart';

class ContestCard extends StatefulWidget {
  final Contest contest;
  final ContestViewModel contestViewModel;
  final bool show;

  ContestCard({required this.contest, required this.contestViewModel, required this.show});

  @override
  State<ContestCard> createState() => _ContestCardState();
}


class _ContestCardState extends State<ContestCard> {

  Map<String,int> notificationIds = {
    "action1" : 1,
    "action2" : 2,
    "alarm" : 3
  };

  bool isAlarmSet = false;
  DateTime? alarmDateTime;

  bool isTimerNotificationSet = false;
  DateTime? timerNotificationDateTime;

  bool alarmNotificationSet = false;
  DateTime? alarmNotificationDateTime;

  String? alarmPath;


  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestPermissions();
      loadAlarmPath();
      if(widget.show) {
        _initializeStateVariables();
      }
    });
  }

  void loadAlarmPath() async {
    final response = await SupabaseCredentials.supabaseClient
        .from('alarm')
        .select()
        .eq('email', SupabaseCredentials.supabaseClient.auth.currentUser!.email!)
        .single();

    if (response['soundPath']!=null) {
      setState(() {
        alarmPath = response['soundPath'];
      });
    }
    else{

      showMessage(context, 'Please select a sound for your alarm', 'warning');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SoundPickerScreen(contestViewModel: widget.contestViewModel),
        ),
      );
    }
  }

  Future<void> _initializeStateVariables() async {
    try {
      print("FETCHING REMINDERS");
      print(SupabaseCredentials.supabaseClient.auth.currentUser!.email);
      print(widget.contest.id);


      final response = await SupabaseCredentials.supabaseClient
          .from('timings')
          .select()
          .eq('email',SupabaseCredentials.supabaseClient.auth.currentUser!.email!)
          .eq('contestId', widget.contest.id)
          .single();

      final DateTime now = DateTime.now();

      print("NOW TIME: $now");

      bool A=false;
      bool T=false;

      late Map<String, dynamic> data;

      setState(() {
        if (response['alarmTime'] != null) {
          DateTime temp_alarmDateTime = DateTime.parse(response['alarmTime'].toString().substring(0,19));
          DateTime new_temp_alarmDateTime = temp_alarmDateTime.add(Duration(minutes: 1));
          print(widget.contest.id + " " + new_temp_alarmDateTime.toString());
          if (new_temp_alarmDateTime.isAfter(now)) {
            print("ALARM SET");
            isAlarmSet = true;
            alarmDateTime = temp_alarmDateTime;
          }
          else{
            print("ALARM NOT SET");
            A=true;
          }
        }

        if (response['timerTime'] != null) {
          DateTime temp_timerNotificationDateTime = DateTime.parse(response['timerTime'].toString().substring(0,19));

          if(temp_timerNotificationDateTime.isAfter(now)){
            print("TIMER SET");
            isTimerNotificationSet = true;
            timerNotificationDateTime = temp_timerNotificationDateTime;
          }
          else{
            print("TIMER NOT SET");
            T=true;
          }
        }

        if(A&&T){
          data={
            'alarmTime': null,
            'timerTime': null
          };
        }
        else if(A){
          data={
            'alarmTime': null,
          };
        }
        else if(T){
          data = {
            'timerTime': null
          };
        }
      });

      if(T||A) {
        print("CHANGING THE DATA");
        print(data);

        try {
          await SupabaseCredentials.supabaseClient
              .from('timings')
              .update(data)
              .eq('contestId', widget.contest.id)
              .eq('email',
              SupabaseCredentials.supabaseClient.auth.currentUser!.email!);
        }
        catch (e) {
          print("ERROR IN UPDATING THE DATA");
        }
      }
      else{
        print("NO NEED TO CHANGE THE DATA");
      }
    } catch (e) {
      print("FROM INIT FOR FETCHING REMINDERS:- No data found or error in fetching data: $e");
    }
  }



  Future<void> _checkAndRequestPermissions() async {
    await isAndroidPersmissionGranted();
    await _requestPermissions();
  }

  bool isPermissionGranted = false;

  Future<void> isAndroidPersmissionGranted() async {
    if(Platform.isAndroid){

    }
    final bool result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled() ?? false;

    setState(() {
      isPermissionGranted = result;
    });
    print('Permission status: $result');

  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotificationPermission =
      await androidImplementation?.requestNotificationsPermission();
      setState(() {
        isPermissionGranted = grantedNotificationPermission ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    DateTime startTime = DateTime.parse(formatDateTimeToIST(widget.contest.start));
    DateTime endTime = DateTime.parse(formatDateTimeToIST(widget.contest.end));

    String s_day = DateFormat('d').format(startTime);
    String s_monthYear = DateFormat('MMM yy').format(startTime);
    String s_time = DateFormat('h:mma').format(startTime).toLowerCase();

    String e_day = DateFormat('d').format(endTime);
    String e_monthYear = DateFormat('MMM yy').format(endTime);
    String e_time = DateFormat('h:mma').format(endTime).toLowerCase();

    print("alarm path is : $alarmPath");
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Increased padding for better spacing
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Ensures the card doesn't take extra vertical space
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.contest.event,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Added spacer to push the icon to the right
                  ElevatedButton(
                    onPressed: () => _launchURL(widget.contest.href),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.remove_red_eye, size: 16),
                        SizedBox(width: 2),
                        Text('View Contest'),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      textStyle: TextStyle(fontSize: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Adjusts the curve radius
                      ),
                    ),
                  ),
                ]),
            SizedBox(height: 8), // Increased spacing between sections
            Text(
              'Hosted by: ${widget.contest.resource}', // Added label for better clarity
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 8), // Increased spacing between sections
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: MediaQuery.of(context).size.width*0.018),
                        Container(
                          width: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Container(width: 90,height: 12,decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.green)),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(s_time,style: TextStyle(color: Colors.black)),
                                      Text(s_day,style: TextStyle(color: Colors.black)),
                                      Text(s_monthYear,style: TextStyle(color: Colors.black)),
                                    ],
                                  )
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 30,
                          child: Divider(
                            color: Colors.white,
                            thickness: 2,
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            // border: Border.all(color: Colors.deepPurple,width: 2),
                          ),
                          child: Column(
                            children: [
                              Text(((widget.contest.duration/60).floor()).toString(),style: TextStyle(color: Colors.black)),
                              Text("Min",style: TextStyle(color: Colors.black))
                            ],
                          )
                        ),
                        SizedBox(
                          width: 30,
                          child: Divider(
                            color: Colors.white,
                            thickness: 2,
                          ),
                        ),
                        Container(
                          width: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Container(width: 90,height: 10,decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.red)),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(e_time,style: TextStyle(color: Colors.black)),
                                        Text(e_day,style: TextStyle(color: Colors.black)),
                                        Text(e_monthYear,style: TextStyle(color: Colors.black)),
                                      ],
                                    )
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]
                                    )])]),
            SizedBox(height: 8),
            widget.show ? Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showNotificationWithActions(contestName: widget.contest.event, contestLink: widget.contest.href, start: widget.contest.start),
                    child: isTimerNotificationSet ? Column(
                      children: [
                        Text(timerNotificationDateTime.toString().substring(0,10)),
                        Text(timerNotificationDateTime.toString().substring(10,16)),
                        Text("Reset Timer"),
                      ],
                    ) : Text('Notification'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      textStyle: TextStyle(fontSize: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Adjusts the curve radius
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _setMyAlarm(),
                    child: isAlarmSet? Column(
                      children: [
                        Text(alarmDateTime.toString().substring(0,10)),
                        Text(alarmDateTime.toString().substring(10,16)),
                        Text("Reset Alarm"),
                      ],
                    ): Text('Alarm'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      textStyle: TextStyle(fontSize: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Adjusts the curve radius
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8), // Add some space between the buttons
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _addToCalendar(context),
                    child: Text('Calendar'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      textStyle: TextStyle(fontSize: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Adjusts the curve radius
                      ),
                    ),
                  ),
                )
              ],
            ) : Text(""),
          ],
        ),
      ),
    );
  }


  String formatDateTimeToIST(String utcDateTime) {
    final utcTime = DateTime.parse(utcDateTime).toUtc();
    final istTime = utcTime.add(Duration(hours: 5, minutes: 30));
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss'); // Customize your format as needed
    return formatter.format(istTime);
  }


  Future<void> _showNotificationWithActions({required String start, required String contestName, required String contestLink}) async {

    if(isTimerNotificationSet){
      await flutterLocalNotificationsPlugin.cancel(notificationIds['action2']!);
      setState(() {
        isTimerNotificationSet = false;
        timerNotificationDateTime = null;
      });


      try{
        final data = {
          'timerTime': null,
        };

        await SupabaseCredentials.supabaseClient
            .from('timings')
            .update(data)
            .eq('contestId', widget.contest.id)
            .eq('email',
            SupabaseCredentials.supabaseClient.auth.currentUser!.email!);
      }
      catch(e){
        print("ERROR IN  REMOVING TIMER FROM SUPABASE ");
      }

    }
    else {

      if(isPermissionGranted==false){
        showMessage(context, 'Please enable notifications to set alarm', 'warning');
        _requestPermissions();
        return;
      }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime scheduledDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if(scheduledDateTime.isBefore(DateTime.now())){
          showMessage(context, "Please select a future time", "error");
          return;
        }

        DateTime contestStart = DateTime.parse(start);

        _scheduleNotification(contestStart, contestName, contestLink, "action1");
        _scheduleNotification(
            scheduledDateTime, widget.contest.event, widget.contest.href,"action2");

        setState(() {
          isTimerNotificationSet = true;
          timerNotificationDateTime = scheduledDateTime;
        });

        final DateFormat formatter = DateFormat('yyyy-MM-ddTHH:mm:ss');
        String x = formatter.format(scheduledDateTime);
        String y = formatter.format(
            DateTime.parse(formatDateTimeToIST(widget.contest.start)));

        final data = {
          'email': SupabaseCredentials.supabaseClient.auth
              .currentUser!.email,
          'timerTime': x,
          'contestId': widget.contest.id,
          'contestStartTime': y
        };

        try {
          final response = await SupabaseCredentials.supabaseClient
              .from('timings')
              .select()
              .eq('email',
              SupabaseCredentials.supabaseClient.auth.currentUser!.email!)
              .eq('contestId', widget.contest.id)
              .single();

          await SupabaseCredentials.supabaseClient
              .from('timings')
              .update(data)
              .eq('contestId', widget.contest.id)
              .eq('email',
              SupabaseCredentials.supabaseClient.auth.currentUser!.email!);
        }
        catch (e) {
          print("ERROR IN FETCHING THE DATA OR THAT ROW IS NOT PRESENT NOW");

          try {
            await SupabaseCredentials.supabaseClient
                .from('timings')
                .insert(data);

            print("DONE INSERTING DATA");
          }
          catch (e) {
            print("ERROR IN INSERTING THE DATA");
          }
        }
      }
    }
    }
  }

  Future<void> _scheduleAlarm(DateTime scheduledDateTime) async {
    print("PRINTING ALARMPATH IN SCHEDULE ALARM: $alarmPath");
    final alarmSettings = AlarmSettings(
        id: 100,
        dateTime: scheduledDateTime,
        assetAudioPath:  alarmPath ?? 'assets/audios/alert.mp3',
        loopAudio: false,
        vibrate: true,
        fadeDuration: 3.0,
        notificationTitle: '',
        notificationBody: '',
        enableNotificationOnKill: true,
        androidFullScreenIntent: true
    );

    setState(() {
      isAlarmSet = true;
      alarmDateTime = scheduledDateTime;
    });

    await Alarm.set(alarmSettings: alarmSettings);
    print("ALARM SET");
  }

  Future<void> _setMyAlarm() async {

    if(isAlarmSet){
      Alarm.stop(100);
      await flutterLocalNotificationsPlugin.cancel(notificationIds['alarm']!);

      setState(() {
        isAlarmSet = false;
        alarmDateTime = null;
      });

      try{
        final data = {
          'alarmTime': null,
        };

        await SupabaseCredentials.supabaseClient
            .from('timings')
            .update(data)
            .eq('contestId', widget.contest.id)
            .eq('email',
            SupabaseCredentials.supabaseClient.auth.currentUser!.email!);
      }
      catch(e){
        print("ERROR IN  REMOVING ALARM FROM SUPABASE ");
      }

    }
    else {

      if(isPermissionGranted==false){
        showMessage(context, 'Please enable notifications to set alarm', 'warning');
        _requestPermissions();
        return;
      }

      if(alarmPath!=null) {

        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );

        if (pickedDate != null) {
          final TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );

          if (pickedTime != null) {
            final DateTime scheduledDateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );

            if (scheduledDateTime.isBefore(DateTime.now())) {
              showMessage(context, "Please select a future time", "error");
              return;
            }

            print("CALLED SCHEDULE ALARM");
            await _scheduleAlarm(scheduledDateTime);
            print("NOTIFICATION DURING THE ALARM");
            await _scheduleNotification(
                scheduledDateTime, widget.contest.event, 'alarm_', "alarm");

            setState(() {
              alarmNotificationSet = true;
              alarmNotificationDateTime = scheduledDateTime;
            });

            final DateFormat formatter = DateFormat('yyyy-MM-ddTHH:mm:ss');
            String x = formatter.format(scheduledDateTime);
            String y = formatter.format(
                DateTime.parse(formatDateTimeToIST(widget.contest.start)));

            final data = {
              'email': SupabaseCredentials.supabaseClient.auth
                  .currentUser!.email,
              'alarmTime': x,
              'contestId': widget.contest.id,
              'contestStartTime': y
            };

            try {
              final response = await SupabaseCredentials.supabaseClient
                  .from('timings')
                  .select()
                  .eq('email',
                  SupabaseCredentials.supabaseClient.auth.currentUser!.email!)
                  .eq('contestId', widget.contest.id)
                  .single();

              await SupabaseCredentials.supabaseClient
                  .from('timings')
                  .update(data)
                  .eq('contestId', widget.contest.id)
                  .eq('email',
                  SupabaseCredentials.supabaseClient.auth.currentUser!.email!);
            }
            catch (e) {
              print(
                  "ERROR IN FETCHING THE DATA OR THAT ROW IS NOT PRESENT NOW");

              try {
                await SupabaseCredentials.supabaseClient
                    .from('timings')
                    .insert(data);

                print("DONE INSERTING DATA");
              }
              catch (e) {
                print("ERROR IN INSERTING THE DATA");
              }
            }
          }
        }
      }
      else{
        showMessage(context, 'Please select a sound for your alarm', 'warning');
      }
    }
  }

  Future<void> _scheduleNotification(DateTime scheduledDateTime, String contestName, String contestLink, String msg) async {

    final tz.TZDateTime tzScheduledDateTime = tz.TZDateTime.from(scheduledDateTime, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationIds[msg]!,
      'Contest Reminder',
      msg=="alarm" ? "Tap to stop the alarm, $contestName is about to start!!" : '$contestName is about to start!',
      tzScheduledDateTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'ch-1',
          'Contest Reminder',
          channelDescription: 'on time reminder',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          actions: msg=="alarm"? null : <AndroidNotificationAction>[
            AndroidNotificationAction(
                'act-1',
                'Join Contest',
                icon: DrawableResourceAndroidBitmap('mipmap/ic_launcher'),
                contextual: true,
                showsUserInterface: true
            )
          ],
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: contestLink,
    );

  }

  void _addToCalendar(BuildContext context) {
    final Event event = Event(
      title: widget.contest.event,
      description: 'Contest on ${widget.contest.host}',
      location: widget.contest.href,
      startDate: DateTime.parse(widget.contest.start),
      endDate: DateTime.parse(widget.contest.end),
    );

    Add2Calendar.addEvent2Cal(event).then((success) {
      showMessage(context, success ? 'Adding contest to the Calender!' : 'Failed to add event to calendar', success ? 'success' : 'error');
    });
  }

  void _launchURL(String url) async {
    print("LAUNCHING URL");
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url),mode: LaunchMode.inAppBrowserView);
      print("LAUNCHED URL");
    } else {
      throw 'Could not launch $url';
    }
  }


}