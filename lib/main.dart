import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:alarm/alarm.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Provider/auth_notifier.dart';
import 'View/signing_options.dart';
import 'View_Models/contest_view_model.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void _launchURL(String url) async {
  if (await canLaunchUrl(Uri.parse(url),)) {
    await launchUrl(Uri.parse(url),mode: LaunchMode.platformDefault);
    print("LAUNCED URL");
  } else {
    throw 'Could not launch $url';
  }
}


void _createNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'ch-1', // unique ID
    'Contest Reminders', // name
    description: 'Channel for contest reminders', // description
    importance: Importance.max,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

const _kShouldTestAsyncErrorOnInit = false;
const _kTestingCrashlytics = true;

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Future.delayed(Duration(milliseconds: 200));
  FlutterNativeSplash.remove();

  MobileAds.instance.initialize();

  await Supabase.initialize(
      url: dotenv.env['supabaseUrl']!,
      anonKey: dotenv.env['anonKey']!,
      authOptions: FlutterAuthClientOptions(
          pkceAsyncStorage: SecureStorage()
      )
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
  DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );



  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
      if (notificationResponse.payload != null) {
        if(notificationResponse.payload!.startsWith('alarm_')){
          await Alarm.stop(100);
        }
        else {
          print("PAYLOAD IS ${notificationResponse.payload}");
          _launchURL(notificationResponse.payload!);
          print("LAUNCHED URL");
        }

      }
      else{
        print("PAYLOAD IS NULL");
      }
    },
  );

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

  _createNotificationChannel();
  await Alarm.init();

  const fatalError = true;
  FlutterError.onError = (errorDetails) {
    if (fatalError) {
      // If you want to record a "fatal" exception
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      // ignore: dead_code
    } else {
      // If you want to record a "non-fatal" exception
      FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (fatalError) {
      // If you want to record a "fatal" exception
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      // ignore: dead_code
    } else {
      // If you want to record a "non-fatal" exception
      FirebaseCrashlytics.instance.recordError(error, stack);
    }
    return true;
  };

  runApp(MyApp());

}


class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<void> _initializeFlutterFireFuture;

  Future<void> _testAsyncErrorOnInit() async {
    Future<void>.delayed(const Duration(seconds: 2), () {
      final List<int> list = <int>[];
      print(list[100]);
    });
  }

  Future<void> _initializeFlutterFire() async {
    if (_kTestingCrashlytics) {
      // Force enable crashlytics collection enabled if we're testing it.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      // Else only enable it in non-debug builds.
      // You could additionally extend this to allow users to opt-in.
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
    }

    if (_kShouldTestAsyncErrorOnInit) {
      await _testAsyncErrorOnInit();
    }
  }

  void initState() {
    super.initState();
    _initializeFlutterFireFuture = _initializeFlutterFire();
  }


  @override
  Widget build(BuildContext context) {
    return  MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ContestViewModel()),
        ChangeNotifierProvider(create: (_) => AuthNotifier()),
      ],
      child: MaterialApp(
        // initialRoute: AppRoutes.SigningOptionsRoute,
        // routes: AppRoutes.routes,
        debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.dark,
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.deepPurple,
            scaffoldBackgroundColor: Colors.black,
            cardColor: Colors.grey[900],
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.black,
            ),
          ),
        title: 'Contest App',
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Consumer<ContestViewModel>(
                builder: (context, contestViewModel, _) => Consumer<AuthNotifier>(
                    builder: (context, authNotifier, _) => SigningOptions(
                      authNotifier: authNotifier, contestViewModel: contestViewModel,
                    )
                ),
              ),
            );
            },
        )
      )
    );
  }
}

class SecureStorage extends GotrueAsyncStorage {
  final _secureStorage = const FlutterSecureStorage();

  @override
  Future<String?> getItem({required String key}) async {
    return await _secureStorage.read(key: key);
  }

  @override
  Future<void> setItem({required String key, required String value}) async {
    await _secureStorage.write(key: key, value: value);
  }

  @override
  Future<void> removeItem({required String key}) async {
    await _secureStorage.delete(key: key);
  }

  @override
  Future<void> clear() async {
    await _secureStorage.deleteAll();
  }
}