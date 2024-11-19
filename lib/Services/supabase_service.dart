import 'package:contestify/Credentials/supabase_credentials.dart';
import '../models/contest.dart';

Map<String,String> resources = {
  'Codeforces': 'codeforces.com',
  'Codec, String? uidhef': 'codechef.com',
  'Topcoder': 'topcoder.com',
  'SPOJ': 'spoj.com',
  'Hackerrank': 'hackerrank.com',
  'Hackerearth': 'hackerearth.com',
  'LeetCode': 'leetcode.com',
  'Atcoder': 'atcoder.jp',
  'GeeksforGeeks': 'geeksforgeeks.org'
};

class SupabaseService {

  Future<List<String>> fetchUserPreferences(String? userId) async {

    try {
      print("TRYING OUT WITH USERID : $userId");
      final response = await SupabaseCredentials.supabaseClient
          .from('user_preferences')
          .select('websitesPreference')
          .eq('uid', userId ?? "")
          .single();

      print("PRINTING THE RESPONSE OF THE PREFERNCES $response");

      if (response== null) {
        throw Exception('Error fetching user preferences: ${response}');
      }

      // Split the websitesPreference string into a list of website names
      // final preferences = (response['websitesPreference'] as String).split(', ');
      String preferencesString = response["websitesPreference"];
      List<String> preferencesList = preferencesString.split(", ");
      return preferencesList;
    }
    catch(e){
      print("ERROR IN GETTING THE USER PREFERENCES EXCEPTION: $e");
      return [];
    }
  }

  Future<List<Contest>> fetchContests(String table, String? userId) async {
    try {
      print("FETCHING THE REQUIRED CONTESTS ONLY");
      // Fetch user preferences
      final userPreferences = await fetchUserPreferences(userId);

      // Get the resource hosts from the user preferences
      final resourceHosts = userPreferences.map((site) => resources[site]).toList();

      print("PRINTING RESOURCE HOSTS: $resourceHosts");

      final response = await SupabaseCredentials.supabaseClient
          .from(table)
          .select()
          .inFilter('resource', resourceHosts)
          .order('start', ascending: true);

      print("PRINTING RESPONSE OF FILTERED DATA $response");

      if (response== null) {
        print("Error fetching contests: ${response}");
        throw Exception('Error fetching contests: ${response}');
      }

      return response.map((contest) => Contest.fromJson(contest)).toList();
    } catch (e) {
      print("Error fetching contests: ${e}");
      throw Exception('Error fetching contests: ${e}');
      print(e);
      return [];
    }
  }

}
