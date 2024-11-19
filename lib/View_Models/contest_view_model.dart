import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import '../models/contest.dart';
import '../services/supabase_service.dart';

class ContestViewModel extends ChangeNotifier {

  User? _user;
  String? _username;

  bool hasFetchedData = false;


  User? getuser() {
    return _user;
  }

  String? getusername() {
    return _username;
  }

  void setUser(User user, String username) {
     _user = user;
     _username = username;
     print("USER IS SET !!!");
     print("USER SET IS ${_user.toString()}");
     print("USERNAME SET IS $_username");
     notifyListeners();
  }

    final SupabaseService _supabaseService = SupabaseService();
    bool isLoading = true;

    List<Contest> oc = [];
    List<Contest> uc = [];
    List<Contest> fdc = [];

  Future<void> fetchMyContestsOnce(String? uid) async {
    if (!hasFetchedData) {
      await fetchMyContests(uid);
      hasFetchedData = true;
    }
  }

  void filterContestsByEndTime(List<Contest> contests) {
    final nowIST = DateTime.now().add(Duration(hours: 5, minutes: 30)); // Current IST time

    contests.removeWhere((contest) {
      final endUTC = DateTime.parse(contest.end);
      final endIST = endUTC.add(Duration(hours: 5, minutes: 30)); // Convert end time to IST

      return endIST.isBefore(nowIST); // Remove if the contest has ended in IST
    });

    List<Contest> temp = [];
    temp = contests;

    for(Contest contest in temp) {
      final nowIST = DateTime.now();
      final contestStart = DateTime.parse(contest.start).add(Duration(hours: 5, minutes: 30));
      if(contestStart.isAfter(nowIST)){
        fdc.add(contest);
        contests.remove(contest);
      }
    }

    for(Contest contest in contests) {
      oc.add(contest);
    }
  }

  void updateContests(List<Contest> furtherDayContests) {
    final nowIST = DateTime.now().toUtc().add(Duration(hours: 5, minutes: 30)); // Current IST time

    furtherDayContests.removeWhere((contest) {
      final startUTC = DateTime.parse(contest.start).toUtc();
      final endUTC = DateTime.parse(contest.end).toUtc();

      final startIST = startUTC.add(Duration(hours: 5, minutes: 30)); // Convert start time to IST
      final endIST = endUTC.add(Duration(hours: 5, minutes: 30));     // Convert end time to IST

      // Check if the contest is ongoing in IST
      if (nowIST.isAfter(startIST) && nowIST.isBefore(endIST)) {
        oc.add(contest); // Add to ongoing contests
        return false; // Do not remove from furtherDayContests as it is ongoing
      }

      // Remove the contest if it has finished in IST
      return endIST.isBefore(nowIST);
    });
    fdc=furtherDayContests;
  }

  void updateUpcomingContests(List<Contest> upcomingContests) {
    final nowIST = DateTime.now().toUtc().add(Duration(hours: 5, minutes: 30)); // Current IST time
    final endOfDayIST = DateTime(nowIST.year, nowIST.month, nowIST.day, 23, 59, 59); // End of today in IST

    upcomingContests.removeWhere((contest) {
      final startUTC = DateTime.parse(contest.start).toUtc();
      final endUTC = DateTime.parse(contest.end).toUtc();

      final startIST = startUTC.add(Duration(hours: 5, minutes: 30)); // Convert start time to IST
      final endIST = endUTC.add(Duration(hours: 5, minutes: 30));     // Convert end time to IST

      // Remove the contest if it has ended in IST
      if (endIST.isBefore(nowIST)) {
        return true;
      }

      // Move contest to further day contests if it starts after now and ends before today ends in IST
      if (startIST.isAfter(nowIST) && endIST.isBefore(endOfDayIST)) {
        fdc.add(contest);
        return true;
      }

      // Move contest to ongoing contests if it is currently ongoing in IST
      if (nowIST.isAfter(startIST) && nowIST.isBefore(endIST)) {
        oc.add(contest);
        return true;
      }

      return false; // Keep the contest in upcoming contests
    });

    uc=upcomingContests;
  }

  void removeSpecificContests() {
    final idsToRemove = ["48942094", "46865089", "48942093", "45256482"];
    oc.removeWhere((contest) => idsToRemove.contains(contest.id));
  }

    Future<void> fetchMyContests(String? uid) async {
      try {
        isLoading = true;
        notifyListeners();

        List<Contest> temp_oc = await _supabaseService.fetchContests('ongoing_contests',uid);
        List<Contest> temp_uc = await _supabaseService.fetchContests('upcoming_contests',uid);
        List<Contest> temp_fdc = await _supabaseService.fetchContests('further_day_contests',uid);

        // print("temp_oc:");
        // print("temp_uc:");
        // print("temp_fdc:");

        // for(Contest contest in temp_oc){
        //   print("OC CONTEST IS ${contest.event} , ${contest.start}, ${contest.end}");
        // }
        //
        // for(Contest contest in temp_uc){
        //   print("UC CONTEST IS ${contest.event} , ${contest.start}, ${contest.end}");
        // }
        //
        // for(Contest contest in temp_fdc){
        //   print("FDC CONTEST IS ${contest.event} , ${contest.start}, ${contest.end}");
        // }


        // filterContestsByEndTime(temp_oc);
        // updateContests(temp_fdc);
        // updateUpcomingContests(temp_uc);



        oc = temp_oc;
        uc = temp_uc;
        fdc = temp_fdc;

        removeSpecificContests();


        print("------OC-----");
        for(Contest contest in oc){
          print("OC CONTEST IS ${contest.event} , ${contest.start}, ${contest.end}");
        }
        print("-----UC-----");
        for(Contest contest in uc){
          print("UC CONTEST IS ${contest.event} , ${contest.start}, ${contest.end}");
        }

        print("-----FDC-----");
        for(Contest contest in fdc){
          print("FDC CONTEST IS ${contest.event} , ${contest.start}, ${contest.end}");
        }

      } catch (e) {
        print("CATCHING THE ERROR IN FETCHMYCONTESTS FUNCTION OF CVM:-  $e");
      } finally {
        print("INTO FINALLY!!");
        isLoading = false;
        notifyListeners();
      }
    }
  }

