class CodechefUserInfo {
  final int currentRating;
  final int highestRating;
  final int globalRank;
  final int countryRank;
  final String stars;

  CodechefUserInfo({
    required this.currentRating,
    required this.highestRating,
    required this.globalRank,
    required this.countryRank,
    required this.stars,
  });

  factory CodechefUserInfo.fromJson(Map<String, dynamic> json) {
    return CodechefUserInfo(
      currentRating: json['currentRating'],
      highestRating: json['highestRating'],
      globalRank: json['globalRank'],
      countryRank: json['countryRank'],
      stars: json['stars'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentRating': currentRating,
      'highestRating': highestRating,
      'globalRank': globalRank,
      'countryRank': countryRank,
      'stars': stars,
    };
  }
}
