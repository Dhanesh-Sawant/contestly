// lib/models/contest.dart
class Contest {
  final String tableRowId;
  final String createdAt;
  final String id;
  final String event;
  final String host;
  final String href;
  final String resource;
  final String start;
  final String end;
  final double duration;

  Contest({
    required this.tableRowId,
    required this.createdAt,
    required this.id,
    required this.event,
    required this.host,
    required this.href,
    required this.resource,
    required this.start,
    required this.end,
    required this.duration,
  });

  factory Contest.fromJson(Map<String, dynamic> json) {
    return Contest(
      tableRowId: json['table_row_id'],
      createdAt: json['created_at'],
      id: json['id'],
      event: json['event'],
      host: json['host'],
      href: json['href'],
      resource: json['resource'],
      start: json['start'],
      end: json['end'],
      duration: json['duration'].toDouble(),
    );
  }
}
