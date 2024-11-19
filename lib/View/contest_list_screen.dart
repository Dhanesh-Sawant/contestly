import 'dart:io';

import 'package:contestify/View/select_sound.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../Credentials/supabase_credentials.dart';
import '../models/contest.dart';
import '../View_Models/contest_view_model.dart';
import '../widgets/contest_card.dart';

class ContestListScreen extends StatefulWidget {
  final String status;
  final ContestViewModel contestViewModel;

  ContestListScreen({
    required this.status,
    required this.contestViewModel,
  });

  @override
  State<ContestListScreen> createState() => _ContestListScreenState();
}

class _ContestListScreenState extends State<ContestListScreen> {

  BannerAd? _bannerAd;
  bool _isLoaded = false;

  final adUnitId = 'ca-app-pub-1384475834483854/7825715510';

  void loadAd() {
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            _isLoaded = true;
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

  void initState() {
    // TODO: implement initState
    super.initState();
    loadAd();
    loadAlarmIfNotSet();
  }

  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

Future<void> loadAlarmIfNotSet() async {
    try {
      final response = await SupabaseCredentials.supabaseClient
          .from('alarm')
          .select()
          .eq(
          'email', SupabaseCredentials.supabaseClient.auth.currentUser!.email!)
          .single();

      if (response['soundPath'] == null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SoundPickerScreen(contestViewModel: widget.contestViewModel),
          ),
        );
      }
    }
    catch (e) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SoundPickerScreen(contestViewModel: widget.contestViewModel),
        ),
      );
      print("Error loading alarm: $e");
    }
}

  List<Contest> _getContestsForStatus(String status) {
    switch (status) {
      case "uc":
        return widget.contestViewModel.uc;
      case "fdc":
        return widget.contestViewModel.fdc;
      case "oc":
      default:
        return widget.contestViewModel.oc;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Contest> contests = _getContestsForStatus(widget.status);

    bool show;

    if(widget.status=="oc"){
      show=false;
    }
    else {
      show = true;
    }

      if (contests.isEmpty) {
        return Center(child: Text('No contests available'));
      }

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(

          children: [
            Expanded(
              child: ListView.builder(
              itemCount: contests.length,
              itemBuilder: (context, index) {
                return ContestCard(contestViewModel: widget.contestViewModel, contest: contests[index], show: show);
              },
            ),
          ),
            (_isLoaded && _bannerAd != null) ?
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
            ) : Container()]
        ),
      );
    }
}


