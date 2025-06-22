import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'main.dart'; // CalendarPage
import 'WeekView.dart';
import 'DayView.dart';
import 'ImportantView.dart';

class YearViewPage extends StatefulWidget {
  final Map<String, List<Map<String, String>>> schedules;
  final Function(String, Map<String, String>) onAddSchedule;

  YearViewPage({required this.schedules, required this.onAddSchedule});

  @override
  _YearViewPageState createState() => _YearViewPageState();
}

class _YearViewPageState extends State<YearViewPage> {
  int _selectedYear = DateTime.now().year;

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

  void _goToPreviousYear() => setState(() => _selectedYear--);
  void _goToNextYear() => setState(() => _selectedYear++);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        title: Text("일정 알리미", style: TextStyle(color: Colors.black, fontSize: 24)),
        centerTitle: true,
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
              onTap: () => Navigator.pushReplacement(
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
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => CalendarPage()),
              ),
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
      body: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: Icon(Icons.arrow_left), onPressed: _goToPreviousYear),
              Text('$_selectedYear년', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              IconButton(icon: Icon(Icons.arrow_right), onPressed: _goToNextYear),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              itemCount: 12,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 24,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                final month = index + 1;
                return _buildMiniCalendar(month);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCalendar(int month) {
    final firstDay = DateTime(_selectedYear, month, 1);
    final daysInMonth = DateTime(_selectedYear, month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;

    final List<Widget> cells = [];
    final days = ['일', '월', '화', '수', '목', '금', '토'];

    cells.addAll(days.map((d) => Center(
      child: Text(d, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    )));

    for (int i = 0; i < startWeekday; i++) {
      cells.add(SizedBox.shrink());
    }

    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(_selectedYear, month, i);
      final mmdd = "${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final weekday = date.weekday % 7;
      final isHoliday = _holidays.containsKey(mmdd);

      final hasHolidayType = (widget.schedules[DateFormat('yyyy-MM-dd').format(date)] ?? [])
          .any((s) => s['type'] == '휴가' || s['type'] == '휴일');

      final color = isHoliday || hasHolidayType || weekday == 0
          ? Colors.red
          : (weekday == 6 ? Colors.blue : Colors.black);

      cells.add(Center(
        child: Text('$i', style: TextStyle(fontSize: 10, color: color)),
      ));
    }

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CalendarPage(
              year: _selectedYear,
              month: month,
              schedules: widget.schedules,
              onAddSchedule: (dateKey, schedule) {
                setState(() {
                  widget.schedules.putIfAbsent(dateKey, () => []).add(schedule);
                });
                widget.onAddSchedule(dateKey, schedule);
              },
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text('$month월', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            Expanded(
              child: GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                childAspectRatio: 1.0,
                children: cells,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
