// api_service.dart
import 'dart:convert';
import 'package:contestify/Models/Codeforces.dart';
import 'package:http/http.dart' as http;

import '../Models/Leetcode1.dart';
import '../Models/Leetcode2.dart';
import '../Models/codechef.dart';


class ApiService {
  final String baseUrl = "https://codeforces.com/api";

  Future<CodeforcesUserInfo?> fetchUserInfo(String handle) async {
    final response = await http.get(Uri.parse("$baseUrl/user.info?handles=$handle&checkHistoricHandles=false"));
    print(response);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final userInfoJson = data['result'][0];
        return CodeforcesUserInfo.fromJson(userInfoJson);
      } else {
        throw Exception('Failed to load user info: ${data['comment']}');
      }
    } else {
      throw Exception('Failed to load user info');
    }
  }

  Future<LeetcodeUserProfile> fetchLeetcodeUserProfile(String username) async {
    print("Printing the username inside fetchLeetcodeUserProfile: $username");
    final response = await http.get(Uri.parse('https://alfa-leetcode-api.onrender.com/userProfile/$username'));

    if (response.statusCode == 200) {
      if(response.body == null || response.body.isEmpty){
        print("Response is null");
        throw Exception('Invalid Username');
      }
      return LeetcodeUserProfile.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  Future<Leetcode2UserContestRanking> fetchLeetcodeUserContestRankingInfo(String username) async {
    final response = await http.get(Uri.parse('https://alfa-leetcode-api.onrender.com/userContestRankingInfo/$username'));

    if (response.statusCode == 200) {
      if(response.body == null || response.body.isEmpty){
        print("Response is null");
        throw Exception('Invalid Username');
      }

      return Leetcode2UserContestRanking.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user contest ranking info');
    }
  }

  final String codechefBaseUrl = "https://codechef-api.vercel.app";

  Future<CodechefUserInfo?> fetchCodechefUserInfo(String handle) async {
    final response = await http.get(Uri.parse("$codechefBaseUrl/$handle"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return CodechefUserInfo.fromJson(data);
      } else {
        throw Exception('No user exists with this handle: $handle');
      }
    } else {
      throw Exception('Failed to load user info');
    }
  }

}
