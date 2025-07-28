import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';

class GoogleCalendarTablePage extends StatefulWidget {
  const GoogleCalendarTablePage({super.key});

  @override
  State<GoogleCalendarTablePage> createState() =>
      _GoogleCalendarTablePageState();
}

class _GoogleCalendarTablePageState extends State<GoogleCalendarTablePage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      calendar.CalendarApi.calendarScope, // 수정 가능 권한
    ],
  );

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<calendar.Event> _events = [];
  calendar.CalendarApi? _calendarApi;

  Future<void> _signIn({bool silent = false}) async {
    GoogleSignInAccount? account;

    try {
      if (silent) {
        account = await _googleSignIn.signInSilently();
      } else {
        account = await _googleSignIn.signIn();
      }

      if (account == null) return;

      final headers = await account.authHeaders;
      final client = GoogleAuthClient(headers);
      _calendarApi = calendar.CalendarApi(client);

      _loadEvents(_selectedDay ?? _focusedDay);
    } catch (e) {
      debugPrint("Google Sign-In error: $e");
    }
  }

  Future<void> _loadEvents(DateTime date) async {
    if (_calendarApi == null) return;
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final events = await _calendarApi!.events.list(
      "primary",
      timeMin: start.toUtc(),
      timeMax: end.toUtc(),
      singleEvents: true,
      orderBy: "startTime",
    );

    setState(() {
      _events = events.items ?? [];
    });
  }

  Future<void> _addEvent() async {
    if (_calendarApi == null) return;
    final now = _selectedDay ?? _focusedDay;

    final event = calendar.Event(
      summary: "New Event from Flutter",
      start: calendar.EventDateTime(
        dateTime: DateTime(now.year, now.month, now.day, 10),
        timeZone: "Asia/Tokyo",
      ),
      end: calendar.EventDateTime(
        dateTime: DateTime(now.year, now.month, now.day, 11),
        timeZone: "Asia/Tokyo",
      ),
    );

    await _calendarApi!.events.insert(event, "primary");
    await _loadEvents(now);
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _signIn(silent: true); // 자동 로그인 시도
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Calendar + TableCalendar"),
        actions: [
          IconButton(icon: const Icon(Icons.login), onPressed: _signIn),
          IconButton(icon: const Icon(Icons.add), onPressed: _addEvent),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
              _loadEvents(selected);
            },
            calendarFormat: CalendarFormat.month,
          ),
          const SizedBox(height: 10),
          Expanded(
            child:
                _events.isEmpty
                    ? const Center(child: Text("No Events"))
                    : ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        final e = _events[index];
                        final time =
                            e.start?.dateTime?.toLocal().toString().substring(
                              0,
                              16,
                            ) ??
                            'No Time';
                        return ListTile(
                          title: Text(e.summary ?? 'No Title'),
                          subtitle: Text(time),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
