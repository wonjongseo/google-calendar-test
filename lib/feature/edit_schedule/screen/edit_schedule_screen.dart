import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:google_calendar_test/core/utilities/datetime_helper.dart';
import 'package:google_calendar_test/core/widgets/custom_test_field.dart';
import 'package:google_calendar_test/feature/calendar/screen/calendar_screen.dart';
import 'package:google_calendar_test/feature/edit_schedule/screen/widgets/change_date_button.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

class EditScheduleController extends GetxController {
  late Rx<DateTime> _startDateTime;
  late Rx<DateTime> _endDateTime;

  String get startDate =>
      DatetimeHelper.dateTime2YYYYMMDD(_startDateTime.value);
  String get endDate => DatetimeHelper.dateTime2YYYYMMDD(_endDateTime.value);

  String get startTime => DatetimeHelper.dateTime2HhMM(_startDateTime.value);
  String get endTime => DatetimeHelper.dateTime2HhMM(_endDateTime.value);

  late TextEditingController titleTeCtl;

  // final calendar.CalendarApi _calendarApi;
  final DateTime selectedDay;
  EditScheduleController(this.selectedDay);

  @override
  void onInit() {
    titleTeCtl = TextEditingController();
    DateTime dt = selectedDay;
    DateTime now = DateTime.now();
    _startDateTime = DateTime(dt.year, dt.month, dt.day, now.hour).obs;
    _endDateTime = DateTime(dt.year, dt.month, dt.day, now.hour + 1).obs;
    super.onInit();
  }

  @override
  void dispose() {
    titleTeCtl.dispose();
    super.dispose();
  }

  void onChangeDate(BuildContext context, {required bool isStartDate}) async {
    DateTime? dt = await DatetimeHelper.showDatePicker(
      context,
      initialDate: isStartDate ? _startDateTime.value : _endDateTime.value,
    );
    if (dt != null) {
      isStartDate ? _startDateTime.value = dt : _endDateTime.value = dt;
    }
  }

  void onChangeTime(BuildContext context, {required bool isStartTime}) async {
    TimeOfDay timeOfDay =
        isStartTime
            ? TimeOfDay.fromDateTime(_startDateTime.value)
            : TimeOfDay.fromDateTime(_endDateTime.value);

    TimeOfDay? td = await DatetimeHelper.showTimePicker(
      context,
      timeOfDay: timeOfDay,
    );

    if (td != null) {
      DateTime dt = isStartTime ? _startDateTime.value : _endDateTime.value;

      if (isStartTime) {
        _startDateTime.value = DateTime(
          dt.year,
          dt.month,
          dt.day,
          td.hour,
          td.minute,
        );
      } else {
        _endDateTime.value = DateTime(
          dt.year,
          dt.month,
          dt.day,
          td.hour,
          td.minute,
        );
      }
    }
  }

  void saveSchedule() async {
    print('startDateTime: ${_startDateTime.value}');
    print('endDateTime: ${_endDateTime.value}');

    var difference = _endDateTime.value.difference(_startDateTime.value);
    if (difference.isNegative) {
      print("InValid!!");
      return;
    }

    String title = titleTeCtl.text.trim();
    if (title.isEmpty) {
      print("title is isEmpty, InValid!!");
      return;
    }

    final event =
        calendar.Event()
          ..summary = title
          ..start = calendar.EventDateTime(
            dateTime: _startDateTime.value,
            timeZone: "Asia/Tokyo",
          )
          ..end = calendar.EventDateTime(
            dateTime: _endDateTime.value,
            timeZone: "Asia/Tokyo",
          );
    Get.back(result: event);
    return;
    // await GoogleOAuthController.to.calendarApi.value?.events.insert(
    //   event,
    //   "primary",
    // );
    // calendar.Event()..summary =
  }
}

class EditScheduleScreen extends GetView<EditScheduleController> {
  const EditScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => controller.saveSchedule(),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12),
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "保存",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Obx(
            () => Column(
              children: [
                CustomTestField(
                  hintText: "タイトル",
                  controller: controller.titleTeCtl,
                ),
                CustomTestField(
                  hintText: "開始",
                  readOnly: true,
                  widget: Row(
                    children: [
                      ChangeDateButton(
                        onTap:
                            () => controller.onChangeDate(
                              context,
                              isStartDate: true,
                            ),
                        label: controller.startDate,
                      ),
                      SizedBox(width: 10),
                      ChangeDateButton(
                        onTap:
                            () => controller.onChangeTime(
                              context,
                              isStartTime: true,
                            ),

                        label: controller.startTime,
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
                CustomTestField(
                  hintText: "終了",
                  readOnly: true,
                  widget: Row(
                    children: [
                      ChangeDateButton(
                        onTap:
                            () => controller.onChangeDate(
                              context,
                              isStartDate: false,
                            ),
                        label: controller.endDate,
                      ),
                      SizedBox(width: 10),
                      ChangeDateButton(
                        onTap:
                            () => controller.onChangeTime(
                              context,
                              isStartTime: false,
                            ),

                        label: controller.endTime,
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
                CustomTestField(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
