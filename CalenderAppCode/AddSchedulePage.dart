import 'package:flutter/material.dart';

class AddSchedulePage extends StatefulWidget {
  final DateTime selectedDate;
  final Map<String, String>? existingSchedule;
  final Function(Map<String, String>)? onSave;

  const AddSchedulePage({
    required this.selectedDate,
    this.existingSchedule,
    this.onSave,
    super.key,
  });

  @override
  _AddSchedulePageState createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController(text: "00:00");
  final TextEditingController _endTimeController = TextEditingController(text: "00:00");
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  final List<String> _scheduleTypes = [
    '기념일', '업무', '수업', '휴가', '당직', '휴일', '회의', '약속'
  ];
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    if (widget.existingSchedule != null) {
      final s = widget.existingSchedule!;
      _titleController.text = s['title'] ?? '';
      _startTimeController.text = s['start'] ?? '00:00';
      _endTimeController.text = s['end'] ?? '00:00';
      _locationController.text = s['location'] ?? '';
      _contentController.text = s['content'] ?? '';
      _selectedType = s['type'];
    }
  }

  @override
  Widget build(BuildContext context) {
    String dateText =
        "${widget.selectedDate.year}-${widget.selectedDate.month.toString().padLeft(2, '0')}-${widget.selectedDate.day.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.existingSchedule != null ? "일정 수정" : "일정 추가"),
        backgroundColor: Colors.blue[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("제목:", style: TextStyle(fontSize: 16)),
            TextField(controller: _titleController),

            SizedBox(height: 20),
            Text("일정 종류:", style: TextStyle(fontSize: 16)),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _scheduleTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
            ),

            SizedBox(height: 20),
            Text("날짜 및 시간:", style: TextStyle(fontSize: 16)),
            Row(
              children: [
                Text(dateText),
                SizedBox(width: 12),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startTimeController,
                    decoration: InputDecoration(labelText: "시작 시간"),
                    keyboardType: TextInputType.datetime,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _endTimeController,
                    decoration: InputDecoration(labelText: "종료 시간"),
                    keyboardType: TextInputType.datetime,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),
            Text("장소:", style: TextStyle(fontSize: 16)),
            TextField(controller: _locationController),

            SizedBox(height: 20),
            Text("내용:", style: TextStyle(fontSize: 16)),
            TextField(
              controller: _contentController,
              maxLines: 1,
              decoration: InputDecoration(hintText: "상세 내용을 입력하세요"),
            ),

            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text("취소"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: Text("저장"),
                  onPressed: () {
                    if (_titleController.text.trim().isNotEmpty) {
                      final newSchedule = {
                        'title': _titleController.text.trim(),
                        'type': _selectedType ?? '',
                        'start': _startTimeController.text.trim(),
                        'end': _endTimeController.text.trim(),
                        'location': _locationController.text.trim(),
                        'content': _contentController.text.trim(),
                      };

                      if (widget.onSave != null) {
                        widget.onSave!(newSchedule);
                      }

                      Navigator.pop(context, newSchedule);
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
