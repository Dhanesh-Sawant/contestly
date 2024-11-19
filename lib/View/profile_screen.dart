import 'dart:io';

import 'package:contestify/Services/auth_supabase_service.dart';
import 'package:contestify/View/contact_me.dart';
import 'package:contestify/View/select_sound.dart';
import 'package:contestify/View/website_selection_view.dart';
import 'package:contestify/View_Models/contest_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase/supabase.dart';

import '../Credentials/supabase_credentials.dart';
import '../Widgets/error_widget.dart';
import '../main.dart';
import 'feedback_screen.dart';

Future<void> clearSession() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

class ProfileScreen extends StatefulWidget {

  final ContestViewModel contestViewModel;
  ProfileScreen({required this.contestViewModel});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isBannerLoaded = false;

  final bannerAdUnitId = 'ca-app-pub-1384475834483854/6298825516';
  // final bannerAdUnitId = '	ca-app-pub-3940256099942544/6300978111';


  final interstitialAdUnitId = 'ca-app-pub-1384475834483854/8566143625';
  // final interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  final rewardAdUnitId = "ca-app-pub-1384475834483854/1697482941";
  // final rewardAdUnitId = "ca-app-pub-3940256099942544/5224354917";

  /// Loads a rewarded ad.
  void loadRewardAd() {
    RewardedAd.load(
        adUnitId: rewardAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            _rewardedAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('RewardedAd failed to load: $error');
          },
        ));
  }



  /// Loads an interstitial ad.
  void loadInterAd() {
    InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            _interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }

  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            _isBannerLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          // Dispose the ad here to free resources.
          ad.dispose();
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) {},
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) {},
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) {},
      ),
    )..load();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadBannerAd();
    loadInterAd();
    loadRewardAd();
  }

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Future<void> _signOut() async {
      try {

        final data ={
          'soundPath': null,
        };

        await SupabaseCredentials.supabaseClient.from('alarm').update(data).eq('email', SupabaseCredentials.supabaseClient.auth.currentUser!.email!);
        print("SOUND PATH REMOVED FROM SUPABASE");


        await SupabaseCredentials.supabaseClient.auth.signOut();
        AuthenticationService().MygoogleSignIn.signOut();

        await clearSession();

        showMessage(context, "Signed out successfully!" , "success");

        await Future.delayed(Duration(seconds: 1));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyApp()));
      }
      catch(e) {
        showMessage(context, "Error signing out. Please try again later: $e", "error");
      }
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Settings'),
          backgroundColor: Colors.deepPurple,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                  children: [
                    ProfileOption(
                      signout: false,
                      icon: Icons.filter_list,
                      title: 'Filter Websites',
                      onTap: (){
                        _rewardedAd!=null ?  _rewardedAd?.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {}) : null;
                        User? user = widget.contestViewModel.getuser();
                        String? name = widget.contestViewModel.getusername();
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>WebsiteSelectionView(userData: user!,username: name!, contestViewModel: widget.contestViewModel,pop:true)));
                      },
                    ),
                    ProfileOption(
                      signout: false,
                      icon: Icons.alarm,
                      title: 'Change Alarm Sound',
                      onTap: (){
                        _interstitialAd!=null ?  _interstitialAd?.show() : null;
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>SoundPickerScreen(contestViewModel: widget.contestViewModel)));
                      },
                    ),
                    ProfileOption(
                      signout: false,
                      icon: Icons.feedback,
                      title: 'Feedback',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder:
                            (context) => FeedbackScreen())
                        );
                      },
                    ),
                    ProfileOption(
                      signout: false,
                      icon: Icons.contact_mail,
                      title: 'Contact Me',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder:
                        (context) => ContactMeScreen())
                        );
                      }
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.1),
                    ProfileOption(
                      signout: true,
                      icon: Icons.logout,
                      title: 'Sign Out',
                      onTap: _signOut,
                    ),
                  ]
                  ),
                ),
                (_isBannerLoaded && _bannerAd != null) ?
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SafeArea(
                      child: SizedBox(
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    ),
                  ) : Container(),
            ]
            ),
          ),
        ),
      ),
    );
  }
}





class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool signout;

  const ProfileOption({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.signout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: signout ? Colors.red : Colors.black38,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: signout ? Colors.red : Colors.white10, width: 2),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white54),
        title: Text(title, style: TextStyle(fontSize: 18)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
        onTap: onTap,
      ),
    );
  }
}
