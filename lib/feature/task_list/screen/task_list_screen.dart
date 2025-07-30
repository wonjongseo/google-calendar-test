import 'package:google_calendar_test/core/utilities/datetime_helper.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:flutter/material.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key, required this.tasks});

  final List<calendar.Event> tasks;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: Column(
            children: List.generate(tasks.length, (index) {
              final task = tasks[index];
              return ListTile(
                title: Text(task.summary ?? "（タイトル無し）"),
                isThreeLine: true,
                trailing: Icon(Icons.arrow_right),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DatetimeHelper.dateTime2YYYYMMDDHhMM(
                        task.start?.dateTime,
                      ),
                    ),
                    Text(
                      DatetimeHelper.dateTime2YYYYMMDDHhMM(task.end?.dateTime),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
