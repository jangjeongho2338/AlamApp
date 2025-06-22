import 'package:hive/hive.dart';

part 'Schedule.g.dart';

@HiveType(typeId: 0)
class Schedule extends HiveObject {
  @HiveField(0)
  String title;
  @HiveField(1)
  String location;
  @HiveField(2)
  String content;
  @HiveField(3)
  String type;
  @HiveField(4)
  String start;
  @HiveField(5)
  String end;

  Schedule({
    required this.title,
    required this.location,
    required this.content,
    required this.type,
    required this.start,
    required this.end,
  });

  // ⬇️ 이 부분 추가!
  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      title: map['title'] ?? '',
      location: map['location'] ?? '',
      content: map['content'] ?? '',
      type: map['type'] ?? '',
      start: map['start'] ?? '',
      end: map['end'] ?? '',
    );
  }
}

