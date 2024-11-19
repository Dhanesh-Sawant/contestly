import 'dart:math';
import 'dart:ui';
import 'package:contestify/Credentials/supabase_credentials.dart';
import 'package:contestify/Models/codechef.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';
import '../Data/api_service.dart';
import '../Models/Codeforces.dart';
import '../Models/Leetcode1.dart';
import '../Models/Leetcode2.dart';
import '../View_Models/contest_view_model.dart';
import '../Widgets/error_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePageScreen extends StatefulWidget {
  final ContestViewModel contestViewModel;

  HomePageScreen({required this.contestViewModel});

  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {

  final String userLogoUrl =
      "https://images.wallpapersden.com/image/download/anonymous-hacker-working_bGllZ2mUmZqaraWkpJRmZ21lrWZnbWU.jpg"; // Replace with actual URL

  bool _isBlurred = false;
  CodeforcesUserInfo? _codeforcesUserInfo;
  LeetcodeUserProfile? _leetcodeUserProfile;
  Leetcode2UserContestRanking? _leetcode2userContestRanking;
  CodechefUserInfo? _codechefUserInfo;


  final ApiService _apiService = ApiService();
  final TextEditingController _codeforcesController = TextEditingController();
  final TextEditingController _leetcodeController = TextEditingController();
  final TextEditingController _codechefController = TextEditingController();
  TextEditingController _mainController = TextEditingController();


  void handleEditIconTap(String platform){
    setState(() {
      _isBlurred = !_isBlurred;
    });

    if(platform == "cf"){
      _mainController= _codeforcesController;
    }
    else if(platform == "lc"){
      _mainController= _leetcodeController;
    }
    else if(platform == "cc"){
      _mainController= _codechefController;
    }
  }

  Future<void> fetchUserInfoInit() async {
    try {
      print("FETCHING STATS FROM FETCHINIT");

      final response = await SupabaseCredentials.supabaseClient.from('username')
          .select('codeforces, leetcode, codechef')
          .eq('email', SupabaseCredentials.supabaseClient.auth.currentUser!.email!)
          .single();

      print("RESPONSE FROM FETCHINIT: $response");

      if (response != null) {
        if(response["codeforces"]!="") {
          _codeforcesController.text = response["codeforces"].toString();
          final userInfo = await _apiService.fetchUserInfo(_codeforcesController.text);
          _codeforcesUserInfo = userInfo;
        }

        if(response["leetcode"]!="") {
          _leetcodeController.text = response["leetcode"].toString();
          final leetcodeUserProfile = await _apiService.fetchLeetcodeUserProfile(_leetcodeController.text);
          _leetcodeUserProfile = leetcodeUserProfile;

          final leetcodeUserContestRankingInfo = await _apiService.fetchLeetcodeUserContestRankingInfo(_leetcodeController.text);
          _leetcode2userContestRanking = leetcodeUserContestRankingInfo;
        }

        if(response["codechef"]!="") {
          _codechefController.text = response["codechef"].toString();
          final codechefUserInfo = await _apiService.fetchCodechefUserInfo(_codechefController.text);
          _codechefUserInfo = codechefUserInfo;
        }
      }
    }
    catch(e){
      print('Error fetching user info FROM FETCHINIT: $e');
    }
  }

  Future<void> _fetchUserInfo() async {
    try {

      CodeforcesUserInfo? cf;
      LeetcodeUserProfile? lc1;
      Leetcode2UserContestRanking? lc2;
      CodechefUserInfo? cc;

      try {
        if (_codeforcesController.text.isNotEmpty) {
          cf = await _apiService.fetchUserInfo(_codeforcesController.text);
        }
      }
      catch(e){
        showMessage(context, e.toString(), "error");

        _codeforcesController.text= "";
        print('Error fetching codeforces data FROM FETCH: $e');
      }

      try {
        if (_leetcodeController.text.isNotEmpty) {
          lc1 = await _apiService.fetchLeetcodeUserProfile(_leetcodeController.text);
          print("PRINTING LC1 : $lc1");
        }
      }
      catch(e) {
        showMessage(context, e.toString(), "error");
      }

      try {
        if (_leetcodeController.text.isNotEmpty) {
          lc2 = await _apiService.fetchLeetcodeUserContestRankingInfo(_leetcodeController.text);
          print("PRINTING LC2 : $lc2");
        }
      }
      catch(e) {
        showMessage(context, e.toString(), "error");
        _leetcodeController.text= "";
        print('Error fetching fetchLeetcodeUserContestRankingInfo data FROM FETCH: $e');
      }

      try {
        if (_codechefController.text.isNotEmpty) {
          cc = await _apiService.fetchCodechefUserInfo(_codechefController.text);
        }
      }
      catch(e) {
        showMessage(context, e.toString(), "error");
        _codechefController.text= "";
        print('Error fetching codechef data FROM FETCH: $e');
      }


      setState(() {
        _codeforcesUserInfo = cf;
        _leetcodeUserProfile = lc1;
        _leetcode2userContestRanking = lc2;
        _codechefUserInfo = cc;
        _isBlurred = !_isBlurred;
      });

        final data = {
          'displayName': widget.contestViewModel.getusername(),
          'email': widget.contestViewModel.getuser()?.email,
          'codeforces': _codeforcesController.text,
          'leetcode' : _leetcodeController.text,
          'codechef' : _codechefController.text,
        };

        final response = await SupabaseCredentials.supabaseClient
            .from('username')
            .upsert(data,onConflict: 'email');



    } catch (e) {
      print('Error SETTING USERNAMES IN SUPABASE $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;


    return PopScope(
        canPop: false,
        child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Hi, ${widget.contestViewModel.getusername()}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 10),
            CircleAvatar(
              foregroundImage: NetworkImage(userLogoUrl),
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: fetchUserInfoInit(),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return Center(
      child: LoadingAnimationWidget.fourRotatingDots(
        size: 50, color: Colors.deepPurpleAccent
      ),
    );
    } else if (snapshot.hasError) {
    return Center(child: Text('Error: ${snapshot.error}'));
    } else {
    return GestureDetector(
      onTap: (){
        print("TAPPED");
        if(_isBlurred){
          print("SETTING BLUR TO FALSE");
          setState(() {
            _isBlurred = false;
          });
        }
      },
      child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Flexible(
                      flex: 3,
                      child: Card(
                        color: Colors.redAccent,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.all(10),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset('assets/images/codeforces.png', width: screenWidth * 0.05),
                                      SizedBox(width: screenWidth * 0.02),
                                      Text(
                                        'Codeforces',
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                                      )
                                      ]
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                      if (_codeforcesUserInfo != null) ...[
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text('${_codeforcesUserInfo!.rank}',style: TextStyle(fontSize: 24)),
                                              Text('Rating: ${_codeforcesUserInfo!.rating}',style: TextStyle(fontSize: 14)),
                                              SizedBox(height: screenHeight * 0.045),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('Contribution: ${_codeforcesUserInfo!.contribution}',style: TextStyle(fontSize: 14)),
                                                  Text('Max Rating: ${_codeforcesUserInfo!.maxRating}',style: TextStyle(fontSize: 14))
                                                ]
                                              ),
                                              SizedBox(height: screenHeight * 0.006),
                                        ])
                                  ]
                                  else ...[
                                    Text('Enter your Codeforces username',style: TextStyle(fontSize: 14)),
                                  ]
                          ]
                              ),
                            ),
                            Positioned(
                              top: screenHeight * 0.01,
                              right: screenWidth * 0.02,
                              child: GestureDetector(
                                onTap:() => handleEditIconTap("cf"),
                                child: Icon(Icons.edit, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 4,
                      child: Card(
                        color: Colors.deepPurple,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.all(10),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0,horizontal: 6),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Image.asset('assets/images/leetcode.png', width: screenWidth * 0.05),
                                      SizedBox(width: screenWidth * 0.02),
                                  Text(
                                    'Leetcode',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  )]),
                                  SizedBox(height: screenHeight * 0.02),
                                  Row(
                                    children: [
                                      if (_leetcodeUserProfile != null && _leetcode2userContestRanking != null) ...[
                                            Container(
                                              width: screenWidth * 0.85,
                                              child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                              Text('Total Solved: ${_leetcodeUserProfile!.totalSolved}'),
                                              SizedBox(height: screenHeight * 0.025),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                Text('Easy: ${_leetcodeUserProfile!.easySolved}/${_leetcodeUserProfile!.totalEasy}'),
                                                Text('Medium: ${_leetcodeUserProfile!.mediumSolved}/${_leetcodeUserProfile!.totalMedium}'),
                                                Text('Hard: ${_leetcodeUserProfile!.hardSolved}/${_leetcodeUserProfile!.totalHard}'),
                                              ]),
                                                    SizedBox(height: screenHeight * 0.02),
                                              Text('Rating: ${_leetcode2userContestRanking!.rating.floor()}',style: TextStyle(fontSize: 24),),

                                                    SizedBox(height: screenHeight * 0.03),
                                                    Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('Global Rank: ${_leetcode2userContestRanking!.globalRanking}'),
                                                  Text('Contribution: ${_leetcodeUserProfile!.contributionPoint}'),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('Attended Contests: ${_leetcode2userContestRanking!.attendedContestsCount}'),
                                                  Text('Ranking: ${_leetcodeUserProfile!.ranking}')
                                                ],
                                              )
                                                                                      ],
                                                                                    ),
                                            )]
                                      else ...[
                                        Center(child: Text('Enter your Leetcode username'))]]
                                        )
                                      ]
                              )
                            ),
                            Positioned(
                              top: screenHeight * 0.01,
                              right: screenWidth * 0.02,
                              child: GestureDetector(
                                onTap: () => handleEditIconTap("lc"),
                                child: Icon(Icons.edit, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      child: Card(
                        color: Colors.teal,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.all(10),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                  children: [
                              Image.asset('assets/images/codechef.png', width: screenWidth * 0.05),
                                  SizedBox(height: screenHeight * 0.02),
                                  Text(
                                    'Codechef',
                                    style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,
                                      color: Colors.white,),
                                  )
                                  ]),
                                  SizedBox(height: screenHeight * 0.016),
                                  if (_codechefUserInfo != null) ...[
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                          Text('Country Rank: ${_codechefUserInfo!.countryRank}'),
                                          Text('Global Rank: ${_codechefUserInfo!.globalRank}'),
                                        ]),
                                        SizedBox(height: screenHeight * 0.03),
                                        (_codechefUserInfo!.stars.substring(0,1)=="1") ? Text('⭐',style: TextStyle(fontSize: 25)) : SizedBox.shrink(),
                                        (_codechefUserInfo!.stars.substring(0,1)=="2") ? Text('⭐⭐',style: TextStyle(fontSize: 25)) : SizedBox.shrink(),
                                        (_codechefUserInfo!.stars.substring(0,1)=="3") ? Text('⭐⭐⭐',style: TextStyle(fontSize: 25)) : SizedBox.shrink(),
                                        (_codechefUserInfo!.stars.substring(0,1)=="4") ? Text('⭐⭐⭐⭐',style: TextStyle(fontSize: 25)) : SizedBox.shrink(),
                                        (_codechefUserInfo!.stars.substring(0,1)=="5") ? Text('⭐⭐⭐⭐⭐',style: TextStyle(fontSize: 25)) : SizedBox.shrink(),
                                        SizedBox(height: screenHeight * 0.02),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Rating: ${_codechefUserInfo!.currentRating}'),
                                            Text('Highest Rating: ${_codechefUserInfo!.highestRating}')
                                          ],
                                        )
                                      ],
                                    ),
                                ]else ...[
                                  Text('Enter your Codechef username')]
                              ],
                            )
                            ),
                            Positioned(
                              top: screenHeight * 0.01,
                              right: screenWidth * 0.02,
                              child: GestureDetector(
                                onTap: () => handleEditIconTap("cc"),
                                child: Icon(Icons.edit, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _isBlurred ?
              AnimatedOpacity(
                opacity: _isBlurred ? 1 : 0,
                duration: Duration(milliseconds: 300),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ) : SizedBox.shrink(),
            _isBlurred ?
              Center(
                child: GestureDetector(
                  onTap: (){},
                  child: Container(
                    width: screenWidth * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Enter your username', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.black)),
                        Row(
                          children: [
                            Icon(Icons.edit,color: Colors.black,),
                            Expanded(
                              child: TextField(
                                controller: _mainController,
                                decoration: InputDecoration(
                                  hintText: 'Enter your username',
                                ),
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            IconButton(
                              onPressed: _fetchUserInfo,
                              icon: Icon(Icons.send,color: Colors.deepPurpleAccent),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ) : SizedBox.shrink(),
          ],
        ),
    );
  }
}
    )));
  }



}
