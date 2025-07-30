// import 'package:calendar_view/calendar_view.dart';
// import 'package:flutter/material.dart';
// import 'package:google_calendar_test/feature/edit_schedule/screen/edit_schedule_screen.dart';
// import 'package:google_calendar_test/feature/task_list/screen/task_list_screen.dart';
// import 'package:google_calendar_test/test.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:get/get.dart';

// import 'package:table_calendar/table_calendar.dart';
// import 'package:googleapis/calendar/v3.dart' as calendar;

// class GoogleOAuthController extends GetxController {
//   static GoogleOAuthController get to => Get.find<GoogleOAuthController>();
//   GoogleSignInAccount? currentUser;
//   final Rxn<calendar.CalendarApi> calendarApi = Rxn<calendar.CalendarApi>();

//   final _googleSignIn = GoogleSignIn(
//     scopes: [calendar.CalendarApi.calendarScope],
//   );
//   @override
//   void onInit() {
//     _googleSignIn.onCurrentUserChanged.listen((account) async {
//       if (account != null) {
//         final authHeaders = await account.authHeaders;
//         final client = GoogleHttpClient(authHeaders);
//         calendarApi.value = calendar.CalendarApi(client);

//         currentUser = account;
//       }
//     });
//     _googleSignIn.signInSilently();
//     super.onInit();
//   }
// }

// class CalendarController extends GetxController {
//   final GoogleOAuthController _googleOAuthController;
//   CalendarController(this._googleOAuthController);
//   final DateTime _today = DateTime.now();

//   late Rx<DateTime> focusedDay;
//   late Rx<DateTime> selectedDay;
//   calendar.CalendarApi? _calendarApi;

//   RxMap<DateTime, List<calendar.Event>> taskMap =
//       <DateTime, List<calendar.Event>>{}.obs;
//   // Map<DateTime, List<calendar.Event>> _eventMap = {};

//   List<calendar.Event> getEventsForDay(DateTime day) {
//     final key = DateTime(day.year, day.month, day.day);
//     return taskMap[key] ?? [];
//   }

//   final isLoading = false.obs;

//   @override
//   void onInit() {
//     focusedDay = _today.obs;
//     selectedDay = _today.obs;

//     ever(_googleOAuthController.calendarApi, (calendarApi) {
//       _calendarApi = calendarApi;
//       loadMonthlyEvents(DateTime.now());
//     });
//     super.onInit();
//   }

//   Future<void> loadMonthlyEvents(DateTime month) async {
//     if (_calendarApi == null) return;
//     try {
//       isLoading(true);
//       final firstDay = DateTime(month.year, month.month, 1);
//       final lastDay = DateTime(
//         month.year,
//         month.month + 1,
//         0,
//       ).add(Duration(days: 1));

//       final events = await _calendarApi!.events.list(
//         "primary",
//         timeMin: firstDay.toUtc(),
//         timeMax: lastDay.toUtc(),
//         singleEvents: true,
//         orderBy: "startTime",
//       );
//       Map<DateTime, List<calendar.Event>> map = {};
//       for (var event in events.items ?? []) {
//         final date =
//             event.start?.dateTime?.toLocal() ?? event.start?.date?.toLocal();
//         if (date != null) {
//           final key = DateTime(date.year, date.month, date.day);
//           map.putIfAbsent(key, () => []).add(event);
//         }
//       }

//       taskMap.assignAll(map);
//     } catch (e) {
//       print('e.toString(): ${e.toString()}');
//     } finally {
//       isLoading(false);
//     }
//   }

//   void onDaySelected(DateTime selected, DateTime focused) async {
//     focusedDay.value = focused;
//     selectedDay.value = selected;

//     if (_calendarApi == null) {
//       print("_calendarApi == null");
//       return;
//     }

//     DateTime dt = DateTime(selected.year, selected.month, selected.day);

//     if (taskMap[dt] != null && taskMap[dt]!.isNotEmpty) {
//       // 選択した日に予定がある
//       Get.to(() => TaskListScreen(tasks: taskMap[dt]!));
//       // _goToTaskListScreen();
//     } else {
//       _goToEditScreen();
//     }
//   }

//   void _goToEditScreen() async {
//     final event = await Get.to(
//       () => EditScheduleScreen(),
//       binding: BindingsBuilder.put(
//         () => EditScheduleController(selectedDay.value),
//       ),
//     );

//     print('event: ${event}');

//     if (event == null) return;
//     try {
//       isLoading(true);
//       await _calendarApi!.events.insert(event, "primary");
//     } catch (e) {
//       print('e.toString(): ${e.toString()}');
//     } finally {
//       isLoading(false);
//       loadMonthlyEvents(DateTime.now());
//     }
//   }
// }

// class CalendarScreen extends GetView<CalendarController> {
//   const CalendarScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Obx(
//       () => Scaffold(
//         backgroundColor: controller.isLoading.value ? Colors.grey : null,
//         body: SafeArea(
//           child: Stack(
//             children: [
//               if (1 == 1)
//                 MonthView(controller: EventController())
//               else
//                 TableCalendar(
//                   firstDay: DateTime.utc(2020, 1, 1),
//                   lastDay: DateTime.utc(2030, 12, 31),
//                   focusedDay: controller.focusedDay.value,
//                   locale: "ja-JP",
//                   selectedDayPredicate:
//                       (d) => isSameDay(controller.selectedDay.value, d),
//                   shouldFillViewport: true,
//                   onDaySelected: (selected, focused) {
//                     controller.onDaySelected(selected, focused);
//                   },
//                   eventLoader: controller.getEventsForDay,
//                 ),
//               if (controller.isLoading.value)
//                 Center(child: CircularProgressIndicator.adaptive()),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_calendar_test/feature/edit_schedule/screen/edit_schedule_screen.dart';
import 'package:google_calendar_test/feature/task_list/screen/task_list_screen.dart';
import 'package:google_calendar_test/test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

class GoogleOAuthController extends GetxController {
  static GoogleOAuthController get to => Get.find<GoogleOAuthController>();
  GoogleSignInAccount? currentUser;
  final Rxn<calendar.CalendarApi> calendarApi = Rxn<calendar.CalendarApi>();

  final _googleSignIn = GoogleSignIn(
    scopes: [calendar.CalendarApi.calendarScope],
  );
  @override
  void onInit() {
    _googleSignIn.onCurrentUserChanged.listen((account) async {
      if (account != null) {
        final authHeaders = await account.authHeaders;
        final client = GoogleHttpClient(authHeaders);
        calendarApi.value = calendar.CalendarApi(client);

        currentUser = account;
      }
    });
    _googleSignIn.signInSilently();
    super.onInit();
  }
}

class CalendarController extends GetxController {
  final GoogleOAuthController _googleOAuthController;
  CalendarController(this._googleOAuthController);

  final allEvents = <calendar.Event>[].obs;
  final isLoading = false.obs;
  calendar.CalendarApi? _calendarApi;
  DateTime selectedDate = DateTime.now();
  @override
  void onInit() {
    ever(_googleOAuthController.calendarApi, (calendarApi) {
      _calendarApi = calendarApi;
      loadMonthlyEvents(DateTime.now());
    });
    super.onInit();
  }

  Future<void> loadMonthlyEvents(DateTime month) async {
    if (_calendarApi == null) return;
    try {
      isLoading(true);
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(
        month.year,
        month.month + 1,
        0,
      ).add(Duration(days: 1));

      final events = await _calendarApi!.events.list(
        "primary",
        timeMin: firstDay.toUtc(),
        timeMax: lastDay.toUtc(),
        singleEvents: true,
        orderBy: "startTime",
      );

      allEvents.value.assignAll(events.items ?? []);
    } catch (e) {
      print('e.toString(): ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  void onDateTapped(DateTime selectedDate) {
    final selectedEvents =
        allEvents.where((event) {
          final date =
              event.start?.dateTime?.toLocal() ?? event.start?.date?.toLocal();
          return date != null &&
              date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;
        }).toList();

    if (selectedEvents.isNotEmpty) {
      Get.to(() => TaskListScreen(tasks: selectedEvents));
    } else {
      _goToEditScreen(selectedDate);
    }
  }

  void _goToEditScreen(DateTime selectedDay) async {
    final event = await Get.to(
      () => EditScheduleScreen(),
      binding: BindingsBuilder.put(() => EditScheduleController(selectedDay)),
    );

    if (event == null) return;
    try {
      isLoading(true);
      await _calendarApi!.events.insert(event, "primary");
    } catch (e) {
      print('e.toString(): ${e.toString()}');
    } finally {
      isLoading(false);
      loadMonthlyEvents(DateTime.now());
    }
  }

  final showDayView = false.obs;

  void toggleDay(DateTime selected) {
    selectedDate = selected;
    showDayView.value = !showDayView.value;
  }
}

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CalendarController>();

    return Obx(
      () => Scaffold(
        backgroundColor: controller.isLoading.value ? Colors.grey : null,
        body: SafeArea(
          child: Stack(
            children: [
              if (controller.showDayView.value)
                DayView(
                  initialDay: controller.selectedDate,
                  controller:
                      EventController()
                        ..addAll(_toCalendarEvents(controller.allEvents)),
                )
              else
                MonthView(
                  // headerBuilder: (date) {
                  //   return Text(date.toString());
                  // },
                  // weekDayBuilder: (int dayIndex) {
                  //   const weekdaysJa = ['日', '月', '火', '水', '木', '金', '土'];
                  //   return Center(
                  //     child: Text(
                  //       weekdaysJa[dayIndex % 7],
                  //       style: TextStyle(fontWeight: FontWeight.bold),
                  //     ),
                  //   );
                  // },
                  // onCellTap: (events, date) => controller.onDateTapped(date),
                  onCellTap: (events, date) {
                    controller.toggleDay(date);
                  },
                  controller:
                      EventController()
                        ..addAll(_toCalendarEvents(controller.allEvents)),
                ),
              if (controller.isLoading.value)
                Center(child: CircularProgressIndicator.adaptive()),
            ],
          ),
        ),
      ),
    );
  }

  List<CalendarEventData> _toCalendarEvents(List<calendar.Event> googleEvents) {
    return googleEvents.map((event) {
      final start =
          event.start?.dateTime?.toLocal() ??
          event.start?.date?.toLocal() ??
          DateTime.now();
      final end =
          event.end?.dateTime?.toLocal() ??
          event.end?.date?.toLocal() ??
          start.add(Duration(hours: 1));

      return CalendarEventData(
        title: event.summary ?? '제목 없음',
        date: start,
        startTime: start,
        endTime: end,
      );
    }).toList();
  }
}
