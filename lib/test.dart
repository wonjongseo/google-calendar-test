import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_calendar_test/feature/edit_schedule/screen/edit_schedule_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';

void main() => runApp(MyApp());

final _googleSignIn = GoogleSignIn(
  scopes: [calendar.CalendarApi.calendarScope],
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Google Calendar App', home: CalendarPage());
  }
}

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  GoogleSignInAccount? _currentUser;
  late calendar.CalendarApi _calendarApi;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<calendar.Event> _eventsForSelectedDay = [];
  Map<DateTime, List<calendar.Event>> _eventMap = {};
  String _status = '';
  late Timer _syncTimer;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((account) async {
      if (account != null) {
        final authHeaders = await account.authHeaders;
        final client = GoogleHttpClient(authHeaders);
        _calendarApi = calendar.CalendarApi(client);

        setState(() {
          _currentUser = account;
          _status = '로그인 완료: ${account.email}';
        });

        _loadMonthlyEvents(DateTime.now());
        _startAutoSync();
      }
    });
    _googleSignIn.signInSilently();
  }

  void _startAutoSync() {
    _syncTimer = Timer.periodic(Duration(minutes: 10), (timer) {
      if (_selectedDay != null) {
        _loadMonthlyEvents(_selectedDay!);
      }
    });
  }

  @override
  void dispose() {
    _syncTimer.cancel();
    super.dispose();
  }

  Future<void> _loadMonthlyEvents(DateTime month) async {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(
      month.year,
      month.month + 1,
      0,
    ).add(Duration(days: 1));

    final events = await _calendarApi.events.list(
      "primary",
      timeMin: firstDay.toUtc(),
      timeMax: lastDay.toUtc(),
      singleEvents: true,
      orderBy: "startTime",
    );

    Map<DateTime, List<calendar.Event>> map = {};
    for (var event in events.items ?? []) {
      final date =
          event.start?.dateTime?.toLocal() ?? event.start?.date?.toLocal();
      if (date != null) {
        final key = DateTime(date.year, date.month, date.day);
        map.putIfAbsent(key, () => []).add(event);
      }
    }

    setState(() {
      _eventMap = map;
      _eventsForSelectedDay = map[_selectedDay] ?? [];
    });
  }

  List<calendar.Event> _getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _eventMap[key] ?? [];
  }

  Future<void> _insertEvent(
    String title,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final event =
        calendar.Event()
          ..summary = title
          ..start = calendar.EventDateTime(
            dateTime: startTime,
            timeZone: "Asia/Tokyo",
          )
          ..end = calendar.EventDateTime(
            dateTime: endTime,
            timeZone: "Asia/Tokyo",
          );

    await _calendarApi.events.insert(event, "primary");
    _loadMonthlyEvents(_focusedDay);
  }

  Future<void> _updateEvent(
    String eventId,
    String title,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final updated =
        calendar.Event()
          ..summary = title
          ..start = calendar.EventDateTime(
            dateTime: startTime,
            timeZone: "Asia/Tokyo",
          )
          ..end = calendar.EventDateTime(
            dateTime: endTime,
            timeZone: "Asia/Tokyo",
          );

    await _calendarApi.events.update(updated, "primary", eventId);
    _loadMonthlyEvents(_focusedDay);
  }

  Future<void> _deleteEvent(String eventId) async {
    await _calendarApi.events.delete("primary", eventId);
    _loadMonthlyEvents(_focusedDay);
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      setState(() {
        _status = '로그인 실패: $error';
      });
    }
  }

  Future<void> _handleSignOut() async {
    await _googleSignIn.disconnect();
    setState(() {
      _currentUser = null;
      _status = '로그아웃됨';
    });
  }

  void _navigateToEventForm({calendar.Event? event}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventFormPage(event: event)),
    );
    if (result is Map<String, dynamic>) {
      final title = result['title'] as String;
      final start = result['start'] as DateTime;
      final end = result['end'] as DateTime;
      if (event != null) {
        _updateEvent(event.id!, title, start, end);
      } else {
        _insertEvent(title, start, end);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Get.to(
                () => EditScheduleScreen(),
                binding: BindingsBuilder.put(
                  () => EditScheduleController(DateTime.now()),
                ),
              );
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                    _eventsForSelectedDay = _getEventsForDay(selected);
                  });
                },
                eventLoader: _getEventsForDay,
              ),

              // Row(
              //   children: [
              //     ElevatedButton(onPressed: _handleSignIn, child: Text('로그인')),
              //     ElevatedButton(
              //       onPressed: () => _navigateToEventForm(),
              //       child: Text('일정 추가'),
              //     ),
              //     ElevatedButton(
              //       onPressed: () {
              //         if (_eventsForSelectedDay.isNotEmpty) {
              //           _navigateToEventForm(event: _eventsForSelectedDay.first);
              //         }
              //       },
              //       child: Text('일정 수정'),
              //     ),
              //     ElevatedButton(
              //       onPressed: () {
              //         if (_eventsForSelectedDay.isNotEmpty) {
              //           _deleteEvent(_eventsForSelectedDay.first.id!);
              //         }
              //       },
              //       child: Text('일정 삭제'),
              //     ),
              //     ElevatedButton(onPressed: _handleSignOut, child: Text('로그아웃')),
              //   ],
              // ),
              // SizedBox(height: 10),
              // Text('일정 목록:'),
              Expanded(
                child: ListView.builder(
                  itemCount: _eventsForSelectedDay.length,
                  itemBuilder: (context, index) {
                    final event = _eventsForSelectedDay[index];
                    return ListTile(
                      title: Text(event.summary ?? '(제목 없음)'),
                      subtitle: Text(event.start?.dateTime?.toString() ?? ''),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              Text(_status),
            ],
          ),
        ),
      ),
    );
  }
}

class EventFormPage extends StatefulWidget {
  final calendar.Event? event;
  EventFormPage({this.event});

  @override
  _EventFormPageState createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _titleController = TextEditingController();
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(Duration(hours: 1));

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!.summary ?? '';
      _start = widget.event!.start?.dateTime?.toLocal() ?? DateTime.now();
      _end =
          widget.event!.end?.dateTime?.toLocal() ??
          DateTime.now().add(Duration(hours: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.event == null ? '일정 추가' : '일정 수정')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: '제목'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _start,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    _start = DateTime(
                      picked.year,
                      picked.month,
                      picked.day,
                      _start.hour,
                      _start.minute,
                    );
                    _end = _start.add(Duration(hours: 1));
                  });
                }
              },
              child: Text(
                '날짜 선택: ${_start.toLocal().toString().split(" ")[0]}',
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'title': _titleController.text,
                  'start': _start,
                  'end': _end,
                });
              },
              child: Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}

class GoogleHttpClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();
  GoogleHttpClient(this._headers);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }

  @override
  void close() => _client.close();
}
