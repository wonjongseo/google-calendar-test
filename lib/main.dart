import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_calendar_test/CalendarExample.dart';
import 'package:google_calendar_test/WhisperExamplePage.dart';
import 'package:google_calendar_test/feature/calendar/screen/calendar_screen.dart';
import 'package:google_calendar_test/feature/edit_schedule/screen/edit_schedule_screen.dart';
import 'package:google_calendar_test/test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // home: CalendarPage(),
      home: CalendarScreen(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      initialBinding: InitialBinding(),
    );
  }
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GoogleOAuthController());
    Get.lazyPut(() => CalendarController(Get.find()));
  }
}
