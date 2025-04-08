class Festival {
  final String content;
  final String festivalName;
  final String place;
  final String category;
  final DateTime startDate;
  final DateTime endDate;

  Festival({
    required this.content,
    required this.festivalName,
    required this.place,
    required this.category,
    required this.startDate,
    required this.endDate,
  });

  factory Festival.fromJson(Map<String, dynamic> json) {
    return Festival(
      content: json['content'] as String,
      festivalName: json['festival_name'] as String,
      place: json['place'] as String,
      category: json['category'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
    );
  }
} 