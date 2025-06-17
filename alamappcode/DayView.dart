import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'AddSchedulePage.dart';
import 'ScheduleDetailPage.dart';
import 'YearView.dart';
import 'WeekView.dart';
import 'ImportantView.dart';

class DayViewPage extends StatefulWidget {
  final Map<String, List<Map<String, String>>> schedules;
  final Function(String, Map<String, String>) onAddSchedule;

  DayViewPage({
    required this.schedules,
    required this.onAddSchedule,
  });

  @override
  _DayViewPageState createState() => _DayViewPageState();
}

class _DayViewPageState extends State<DayViewPage> {
  DateTime _selectedDate = DateTime.now();

  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(Duration(days: 1));
    });
  }

  void _goToNextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = DateFormat('M월 d일').format(_selectedDate);
    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final daySchedules = widget.schedules[dateKey] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        title: Text('일정 알리미', style: TextStyle(color: Colors.black, fontSize: 24)),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
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
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WeekViewPage(
                    schedules: widget.schedules,
                    onAddSchedule: widget.onAddSchedule,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('일별 달력'),
              onTap: () => Navigator.pop(context),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: Icon(Icons.arrow_left), onPressed: _goToPreviousDay),
                Text('$title 주요 일정', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                IconButton(icon: Icon(Icons.arrow_right), onPressed: _goToNextDay),
              ],
            ),
            Divider(thickness: 1),
            Expanded(
              child: daySchedules.isEmpty
                  ? Center(child: Text("오늘 등록된 일정이 없습니다.", style: TextStyle(fontSize: 16)))
                  : ListView.builder(
                itemCount: daySchedules.length,
                itemBuilder: (context, index) {
                  final item = daySchedules[index];
                  return ListTile(
                    title: Text("- ${item['title']}", style: TextStyle(fontSize: 16)),
                    subtitle: item['time'] != null ? Text(item['time']!) : null,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ScheduleDetailPage(schedule: item),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[200],
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddSchedulePage(selectedDate: _selectedDate),
            ),
          );

          if (result != null && result is Map<String, dynamic>) {
            final clean = Map<String, String>.from(result);
            final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);

            widget.onAddSchedule(dateKey, clean);
            setState(() {});
          }
        },
      ),
    );
  }
}