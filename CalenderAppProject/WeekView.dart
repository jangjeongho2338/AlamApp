import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'AddSchedulePage.dart';
import 'ScheduleDetailPage.dart';
import 'YearView.dart';
import 'DayView.dart';
import 'ImportantView.dart';

class WeekViewPage extends StatefulWidget {
  final Map<String, List<Map<String, String>>> schedules;
  final Function(String, Map<String, String>) onAddSchedule;

  WeekViewPage({required this.schedules, required this.onAddSchedule});

  @override
  _WeekViewPageState createState() => _WeekViewPageState();
}

class _WeekViewPageState extends State<WeekViewPage> {
  DateTime _focusedWeekStartDate = _getStartOfWeek(DateTime.now());

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

  static DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  void _goToPreviousWeek() {
    setState(() {
      _focusedWeekStartDate = _focusedWeekStartDate.subtract(Duration(days: 7));
    });
  }

  void _goToNextWeek() {
    setState(() {
      _focusedWeekStartDate = _focusedWeekStartDate.add(Duration(days: 7));
    });
  }

  List<DateTime> _getCurrentWeekDates() {
    return List.generate(7, (index) => _focusedWeekStartDate.add(Duration(days: index)));
  }

  List<Widget> _buildWeeklyScheduleItems() {
    final weekDates = _getCurrentWeekDates();
    final items = <Widget>[];

    for (final date in weekDates) {
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final daySchedules = widget.schedules[dateKey] ?? [];

      for (final entry in daySchedules) {
        items.add(
          ListTile(
            title: Text("${entry['title']} - ${date.month}월 ${date.day}일 ${entry['time'] ?? ''}"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ScheduleDetailPage(schedule: entry),
                ),
              );
            },
          ),
        );
      }
    }

    if (items.isEmpty) {
      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text("이번 주는 등록된 주요 일정이 없습니다."),
        ),
      );
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = _getCurrentWeekDates();
    final weekNumber = ((_focusedWeekStartDate.day - 1) / 7).floor() + 1;

    return Scaffold(
      backgroundColor: Colors.white,
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
                    schedules: widget.schedules,
                    onAddSchedule: widget.onAddSchedule,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('월별 달력'),
              onTap: () {
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('주별 달력'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('일별 달력'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DayViewPage(
                    schedules: widget.schedules,
                    onAddSchedule: widget.onAddSchedule,
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
                    schedules: widget.schedules,
                    onAddSchedule: widget.onAddSchedule,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        title: Text("일정 알리미", style: TextStyle(color: Colors.black, fontSize: 24)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: Icon(Icons.arrow_left), onPressed: _goToPreviousWeek),
                Text("${_focusedWeekStartDate.month}월 ${weekNumber}주차",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                IconButton(icon: Icon(Icons.arrow_right), onPressed: _goToNextWeek),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              height: 150,
              child: GridView.count(
                crossAxisCount: 7,
                childAspectRatio: 1,
                physics: NeverScrollableScrollPhysics(),
                children: _getCurrentWeekDates().map((date) {
                  final dateKey = DateFormat('yyyy-MM-dd').format(date);
                  final daySchedules = widget.schedules[dateKey] ?? [];

                  final mmdd = DateFormat('MM-dd').format(date);
                  final holidayName = _holidays[mmdd];
                  final isHoliday = holidayName != null;
                  final hasHolidayType = daySchedules.any((s) => s['type'] == '휴가' || s['type'] == '휴일');

                  final color = (isHoliday || hasHolidayType || date.weekday == DateTime.sunday)
                      ? Colors.red
                      : (date.weekday == DateTime.saturday ? Colors.blue : Colors.black);


                  final isHolidayType = daySchedules.any((e) => e['type'] == '휴일' || e['type'] == '휴가');

                  final titleWidget = daySchedules.isNotEmpty
                      ? Text(
                    "- ${daySchedules.first['title']}",
                    style: TextStyle(
                      fontSize: 10,
                      color: isHolidayType ? Colors.red : Colors.black, // ✅ 휴일/휴가면 빨간 글자
                    ),
                  )
                      : SizedBox.shrink();


                  return GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddSchedulePage(selectedDate: date),
                        ),
                      );

                      if (result != null && result is Map<String, dynamic>) {
                        final clean = Map<String, String>.from(result);
                        widget.onAddSchedule(dateKey, clean);
                        setState(() {});
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade600, width: 1),
                      ),
                      padding: EdgeInsets.all(4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${date.day}", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                          if (holidayName != null)
                            Text(holidayName, style: TextStyle(fontSize: 10, color: Colors.red)),
                          titleWidget,
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Divider(),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Text("주요 일정", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView(children: _buildWeeklyScheduleItems()),
          )
        ],
      ),
    );
  }
}
