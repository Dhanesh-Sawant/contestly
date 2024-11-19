
class CodeforcesUserInfo {
  final int contribution;
  final int? rating;
  final String? rank;
  final int? maxRating;
  final String? maxRank;

  CodeforcesUserInfo({
    required this.contribution,
    required this.rating,
    required this.rank,
    required this.maxRating,
    required this.maxRank,
  });

  factory CodeforcesUserInfo.fromJson(Map<String, dynamic> json) {
    return CodeforcesUserInfo(
      contribution: json['contribution'],
      rating: json['rating'],
      rank: json['rank'],
      maxRating: json['maxRating'],
      maxRank: json['maxRank'],
    );
  }
}
