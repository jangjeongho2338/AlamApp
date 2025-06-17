import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'AddSchedulePage.dart';
import 'ScheduleDetailPage.dart';
import 'YearView.dart';
import 'WeekView.dart';
import 'DayView.dart';

class ImportantViewPage extends StatefulWidget {
  final Map<String, List<Map<String, String>>> schedules;
  final Function(String, Map<String, String>) onAddSchedule;

  const ImportantViewPage({
    super.key,
    required this.schedules,
    required this.onAddSchedule,
  });

  @override
  State<ImportantViewPage> createState() => _ImportantViewPageState();
}

class _ImportantViewPageState extends State<ImportantViewPage> {
  String _searchKeyword = '';

  @override
  Widget build(BuildContext context) {
    final allSchedules = widget.schedules.entries
        .expand((entry) => entry.value.map((e) => {
      'date': entry.key,
      ...e,
    }))
        .where((schedule) =>
    _searchKeyword.isEmpty ||
        (schedule['title']
            ?.toLowerCase()
            .contains(_searchKeyword.toLowerCase()) ??
            false))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        title: const Text("주요 일정 보기",
            style: TextStyle(color: Colors.black, fontSize: 24)),
        centerTitle: true,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black, size: 28),
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
              child: const Text('달력 옵션',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
              leading: const Icon(Icons.star),
              title: const Text('주요 일정 보기'),
              onTap: () {
                Navigator.pop(context); // 이미 이 페이지
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchKeyword = value;
                });
              },
              decoration: InputDecoration(
                labelText: '제목으로 검색',
                border: OutlineInputBorder(),
                suffixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: allSchedules.isEmpty
                ? const Center(child: Text('일정이 없습니다.'))
                : ListView.builder(
              itemCount: allSchedules.length,
              itemBuilder: (context, index) {
                final schedule = allSchedules[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(schedule['title'] ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (schedule['date'] != null)
                          Text("날짜: ${schedule['date']}"),
                        if (schedule['type'] != null)
                          Text("종류: ${schedule['type']}"),
                        if (schedule['content'] != null &&
                            schedule['content']!.isNotEmpty)
                          Text("내용: ${schedule['content']}"),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ScheduleDetailPage(schedule: schedule),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}