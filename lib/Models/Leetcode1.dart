class LeetcodeUserProfile {
  final int totalSolved;
  final int easySolved;
  final int totalEasy;
  final int mediumSolved;
  final int totalMedium;
  final int hardSolved;
  final int totalHard;
  final int ranking;
  final int contributionPoint;
  final int reputation;

  LeetcodeUserProfile({
    required this.totalSolved,
    required this.easySolved,
    required this.totalEasy,
    required this.mediumSolved,
    required this.totalMedium,
    required this.hardSolved,
    required this.totalHard,
    required this.ranking,
    required this.contributionPoint,
    required this.reputation,
  });

  factory LeetcodeUserProfile.fromJson(Map<String, dynamic> json) {
    return LeetcodeUserProfile(
      totalSolved: json['totalSolved'],
      easySolved: json['easySolved'],
      totalEasy: json['totalEasy'],
      mediumSolved: json['mediumSolved'],
      totalMedium: json['totalMedium'],
      hardSolved: json['hardSolved'],
      totalHard: json['totalHard'],
      ranking: json['ranking'],
      contributionPoint: json['contributionPoint'],
      reputation: json['reputation'],
    );
  }
}
