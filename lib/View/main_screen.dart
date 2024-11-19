import 'package:contestify/View/profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../View_Models/contest_view_model.dart';
import 'contest_tab_screen.dart';
import 'home_page_screen.dart';

class MainScreen extends StatefulWidget {
  final ContestViewModel contestViewModel;

  MainScreen({required this.contestViewModel});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int _pageNo = 0;

  late PageController pageController;

  void NavigationTapped(int page){
    pageController.jumpToPage(page); // pagecontroller will jump to page given and make the page view change
  }

  void onpageChanged(int page){
    setState(() {
      _pageNo = page;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> homeScreenItems = [
//
      HomePageScreen(contestViewModel: widget.contestViewModel),
      ContestTabScreen(contestViewModel: widget.contestViewModel),
      ProfileScreen(contestViewModel: widget.contestViewModel),
    ];


    return Scaffold(
      body: SafeArea(
        child: PageView(// pageview is what we see after we change by pagecontroller and it is indexed
          children: homeScreenItems,
          controller: pageController,
          onPageChanged: onpageChanged,
          physics: NeverScrollableScrollPhysics(), // to disable pageview by swiping left and right
          // onPageChanged: onPageChanged,
        ),
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: Colors.transparent,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_filled,
              color: _pageNo==0 ? Colors.deepPurpleAccent : Colors.white,
            ),
            label: '',
            backgroundColor: Colors.orange,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.search,
              color: _pageNo==1 ? Colors.deepPurpleAccent : Colors.white,
            ),
            label: '',
            backgroundColor: Colors.orange,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
              color: _pageNo==2 ? Colors.deepPurpleAccent : Colors.white,
            ),
            label: '',
            backgroundColor: Colors.orange,
          )
        ],
        onTap: NavigationTapped,
      ),
    );
  }
}

