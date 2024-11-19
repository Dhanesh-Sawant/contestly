class Leetcode2UserContestRanking {
  final int attendedContestsCount;
  final double rating;
  final int globalRanking;
  final int totalParticipants;
  final double topPercentage;
  final String? badge;

  Leetcode2UserContestRanking({
    required this.attendedContestsCount,
    required this.rating,
    required this.globalRanking,
    required this.totalParticipants,
    required this.topPercentage,
    this.badge,
  });

  factory Leetcode2UserContestRanking.fromJson(Map<String, dynamic> json) {
    Map<String,dynamic>? newjson = json['data']['userContestRanking'];

    if(newjson == null){
      return Leetcode2UserContestRanking(
        attendedContestsCount: 0,
        rating: 0,
        globalRanking: 0,
        totalParticipants: 0,
        topPercentage: 0,
        badge: null,
      );
    }

    return Leetcode2UserContestRanking(
      attendedContestsCount: newjson?['attendedContestsCount'],
      rating: newjson?['rating'],
      globalRanking: newjson?['globalRanking'],
      totalParticipants: newjson?['totalParticipants'],
      topPercentage: newjson?['topPercentage'],
      badge: newjson?['badge'],
    );
  }
}
