import 'package:contestify/Credentials/supabase_credentials.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../View_Models/contest_view_model.dart';
import 'contest_list_screen.dart';

class ContestTabScreen extends StatefulWidget {
  final ContestViewModel contestViewModel;

  ContestTabScreen({required this.contestViewModel});

  @override
  _ContestTabScreenState createState() => _ContestTabScreenState();
}

class _ContestTabScreenState extends State<ContestTabScreen> {
  late Future<void> _fetchContestsFuture;

  @override
  void initState() {
    super.initState();
    String uid = widget.contestViewModel.getuser()?.id ?? "";
    _fetchContestsFuture = widget.contestViewModel.fetchMyContestsOnce(uid);
    removeOldContests();
  }

  Future<void> removeOldContests() async {
    try {
      print("Removing old contests...");
      final DateTime now = DateTime.now();
      print("Current Time: $now");

      // Perform the deletion
      final response = await SupabaseCredentials.supabaseClient
          .from('timings')
          .delete()
          .lt('contestStartTime', now.toIso8601String());  // Ensure 'contestStartTime' is compared as an ISO string

      if (response == null) {
        print("Old contests removed successfully.");
      } else {
        print("Error removing old contests: ${response.error?.message}");
      }
    } catch (e) {
      print("Exception during removal: $e");
    }
  }

  Future<void> _refreshContests() async {
    setState(() {
      _fetchContestsFuture = widget.contestViewModel.fetchMyContests(widget.contestViewModel.getuser()?.id ?? "");
    });
    await _fetchContestsFuture;
  }



  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('My Contests'),
          backgroundColor: Colors.deepPurple,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _refreshContests,
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Ongoing Contests'),
              Tab(text: 'Further in Day'),
              Tab(text: 'Upcoming Contests'),
            ],
          ),
        ),
        body: FutureBuilder(
          future: _fetchContestsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: LoadingAnimationWidget.fourRotatingDots(
                    size: 50, color: Colors.deepPurpleAccent
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error fetching contests'));
            }

            return RefreshIndicator(
              onRefresh: _refreshContests,
              child: TabBarView(
                children: [
                  ContestListScreen(
                    status: "oc",
                    contestViewModel: widget.contestViewModel,
                  ),
                  ContestListScreen(
                    status: "fdc",
                    contestViewModel: widget.contestViewModel,
                  ),
                  ContestListScreen(
                    status: "uc",
                    contestViewModel: widget.contestViewModel,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ));
  }
}
