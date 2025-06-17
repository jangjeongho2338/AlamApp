import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'AddSchedulePage.dart';
import 'ScheduleDetailPage.dart';
import 'YearView.dart';
import 'WeekView.dart';
import 'DayView.dart';
import 'ImportantView.dart';
import 'Schedule.dart'; // Hive 메소드

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  Hive.registerAdapter(ScheduleAdapter());

  await Hive.deleteBoxFromDisk('schedules'); // ✅ 이 줄 추가: 기존 데이터 삭제
  await Hive.openBox<Schedule>('schedules');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '일정 알리미',
      home: CalendarPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalendarPage extends StatefulWidget {
  final int? year;
  final int? month;
  final Map<String, List<Map<String, String>>>? schedules;
  final Function(String, Map<String, String>)? onAddSchedule;

  const CalendarPage({
    this.year,
    this.month,
    this.schedules,
    this.onAddSchedule,
    super.key,
  });

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime? _selectedDateForView;
  late DateTime _focusedDate;
  late Map<String, List<Map<String, String>>> _schedules;

  final Map<String, String> _holidays = {
    '01-01': '신정',
    '03-01': '삼일절',
    '05-05': '어린이날',
    '06-06': '현충일',
    '08-15': '광복절',
    '10-03': '개천절',
    '10-09': '한글날',
    '12-25': '성탄절',
  };

  List<String> weekDays = ['일 Sun', '월 Mon', '화 Tue', '수 Wed', '목 Thu', '금 Fri', '토 Sat'];

  @override
  void initState() {
    super.initState();
    _focusedDate = DateTime(
      widget.year ?? DateTime.now().year,
      widget.month ?? DateTime.now().month,
    );
    _schedules = widget.schedules ?? {};
    _selectedDateForView = DateTime.now();
  }
  List<Widget> _buildCalendar(DateTime date) {
    List<Widget> dayWidgets = [];
    DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
    int startWeekday = firstDayOfMonth.weekday % 7;
    int daysInMonth = DateTime(date.year, date.month + 1, 0).day;

    for (var day in weekDays) {
      dayWidgets.add(Container(
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
        child: Text(
          day,
          style: TextStyle(
            fontSize: 12,
            color: day.startsWith('일') ? Colors.red : day.startsWith('토') ? Colors.blue : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ));
    }

    for (int i = 0; i < startWeekday; i++) {
      dayWidgets.add(Container(decoration: BoxDecoration(border: Border.all(color: Colors.grey))));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final currentDate = DateTime(date.year, date.month, day);
      final dateKey = DateFormat('yyyy-MM-dd').format(currentDate);
      final weekday = currentDate.weekday % 7;

      final mmdd = DateFormat('MM-dd').format(currentDate);
      final holiday = _holidays[mmdd];

      final isHolidayType = _schedules[dateKey]?.any(
            (e) => e['type'] == '휴가' || e['type'] == '휴일',
      ) ?? false;

      final color = (holiday != null || isHolidayType || weekday == 0)
          ? Colors.red
          : (weekday == 6 ? Colors.blue : Colors.black);
      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDateForView = currentDate;
            });
          },
          onLongPress: () {
            final schedules = _schedules[dateKey];
            if (schedules != null && schedules.isNotEmpty) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text("${DateFormat('yyyy-MM-dd').format(currentDate)} 일정"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: schedules.map((e) => ListTile(
                      title: Text("- ${e['title']}"),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ScheduleDetailPage(schedule: e),
                          ),
                        );
                      },
                    )).toList(),
                  ),
                ),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              color: _selectedDateForView != null &&
                  _selectedDateForView!.year == currentDate.year &&
                  _selectedDateForView!.month == currentDate.month &&
                  _selectedDateForView!.day == currentDate.day
                  ? Colors.lightBlue[100]
                  : Colors.white,
            ),
            padding: EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$day', style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                if (holiday != null)
                  Text(holiday, style: TextStyle(fontSize: 10, color: Colors.red)),
                ...?_schedules[dateKey]?.map((event) {
                  final title = event['title'] ?? '';
                  final type = event['type'] ?? '';
                  final isRed = type == '휴가' || type == '휴일';
                  final itemColor = isRed
                      ? Colors.red
                      : (weekday == 0 ? Colors.red : (weekday == 6 ? Colors.blue : Colors.black));
                  return Text(
                    "- $title",
                    style: TextStyle(fontSize: 10, color: itemColor),
                    overflow: TextOverflow.ellipsis,
                  );
                }),
              ],
            ),
          ),
        ),
      );
    }

    return dayWidgets;
  }
  void _goToPreviousMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    String title = DateFormat('yyyy년 M월').format(_focusedDate);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        title: Text("일정 알리미", style: TextStyle(color: Colors.black, fontSize: 28)),
        centerTitle: true,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.black, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue[100]),
              child: Text('달력 옵션', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('연도별 달력'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => YearViewPage(
                    schedules: _schedules,
                    onAddSchedule: (dateKey, schedule) {
                      setState(() {
                        _schedules.putIfAbsent(dateKey, () => []).add(schedule);
                      });
                    },
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('주별 달력'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WeekViewPage(
                    schedules: _schedules,
                    onAddSchedule: (dateKey, schedule) {
                      setState(() {
                        _schedules.putIfAbsent(dateKey, () => []).add(schedule);
                      });
                    },
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('일별 달력'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DayViewPage(
                    schedules: _schedules,
                    onAddSchedule: (dateKey, schedule) {
                      setState(() {
                        _schedules.putIfAbsent(dateKey, () => []).add(schedule);
                      });
                    },
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.star),
              title: Text('전체 일정 보기'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ImportantViewPage(
                    schedules: _schedules,
                    onAddSchedule: (dateKey, schedule) {
                      setState(() {
                        _schedules.putIfAbsent(dateKey, () => []).add(schedule);
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: Icon(Icons.arrow_left), onPressed: _goToPreviousMonth),
                Text(title, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                IconButton(icon: Icon(Icons.arrow_right), onPressed: _goToNextMonth),
              ],
            ),
            SizedBox(height: 6),
            Flexible(
              flex: 8,
              child: GridView.count(
                crossAxisCount: 7,
                childAspectRatio: 0.95,
                physics: NeverScrollableScrollPhysics(),
                children: _buildCalendar(_focusedDate),
              ),
            ),
            if (_selectedDateForView != null) ...[
              Divider(thickness: 1),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  "${_selectedDateForView!.month}월 ${_selectedDateForView!.day}일 "
                      "${["일", "월", "화", "수", "목", "금", "토"][_selectedDateForView!.weekday % 7]}요일 주요일정",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Flexible(
                flex: 3,
                child: ListView(
                  padding: EdgeInsets.only(bottom: 12),
                  children: [
                    ...?_schedules[DateFormat('yyyy-MM-dd').format(_selectedDateForView!)]?.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("${e['start'] ?? ''} ~ ${e['end'] ?? ''}", style: TextStyle(fontSize: 14)),
                          SizedBox(width: 10),
                          Text("${e['type'] ?? ''}", style: TextStyle(fontSize: 14)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "${e['title'] ?? ''}",
                              style: TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ScheduleDetailPage(schedule: e),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 245, 238, 255),
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              textStyle: TextStyle(fontSize: 14),
                            ),
                            child: Text("상세 보기"),
                          ),
                        ],
                      ),
                    )) ??
                        [],
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddSchedulePage(selectedDate: _selectedDateForView!),
                            ),
                          );
                          if (result != null && result is Map<String, dynamic>) {
                            final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDateForView!);
                            final data = Map<String, String>.from(result);
                            setState(() {
                              _schedules.putIfAbsent(dateKey, () => []).add(data);
                            });
                            final box = Hive.box<Schedule>('schedules');
                            box.add(Schedule.fromMap(data)); // ✅ 이렇게 고치세요
                          }
                        },
                        child: Text("새로운 일정 생성"),
                      ),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

