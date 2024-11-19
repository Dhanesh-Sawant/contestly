import 'package:contestify/View/main_screen.dart';
import 'package:contestify/View/select_sound.dart';
import 'package:contestify/View_Models/contest_view_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import '../Credentials/supabase_credentials.dart';
import '../Widgets/error_widget.dart';


class WebsiteSelectionView extends StatefulWidget {
  final bool pop;
  final User userData;
  final String username;
  final ContestViewModel contestViewModel;
  // final bool sound;

  WebsiteSelectionView({required this.userData, required this.username, required this.contestViewModel, required this.pop});

  @override
  _WebsiteSelectionViewState createState() => _WebsiteSelectionViewState();
}

class _WebsiteSelectionViewState extends State<WebsiteSelectionView> {
  final List<String> codingPlatforms = [
    'Codeforces',
    'Codechef',
    'Topcoder',
    'SPOJ',
    'Hackerrank',
    'Hackerearth',
    'LeetCode',
    'Atcoder',
    'GeeksforGeeks'
  ];

  final Map<String, String> platformLogos = {
    'Codeforces': 'assets/images/codeforces.png',
    'Codechef': 'assets/images/codechef.png',
    'Topcoder': 'assets/images/topcoder.png',
    'SPOJ': 'assets/images/spoj.png',
    'Hackerrank': 'assets/images/hackerrank.png',
    'Hackerearth': 'assets/images/hackerearth.png',
    'LeetCode': 'assets/images/leetcode.png',
    'Atcoder': 'assets/images/atcoder.jpg',
    'GeeksforGeeks': 'assets/images/geeksforgeeks.png',
  };

  final Set<String> selectedPlatforms = Set<String>();


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
        child:
        Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Select Coding Platforms'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: codingPlatforms.length,
                itemBuilder: (context, index) {
                  final platform = codingPlatforms[index];
                  final isSelected = selectedPlatforms.contains(platform);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedPlatforms.remove(platform);
                        } else {
                          selectedPlatforms.add(platform);
                        }
                      });
                    },
                    child: Card(
                      color: isSelected ? Colors.teal : Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            platformLogos[platform]!,
                            height: 60,
                            width: 60,
                          ),
                          SizedBox(height: 8),
                          Text(
                            platform,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(Size(MediaQuery.of(context).size.width*0.4, 45)),
                backgroundColor: selectedPlatforms.isEmpty? MaterialStateProperty.all(Colors.grey) : MaterialStateProperty.all(Colors.deepPurple),
              ),
              onPressed: () async {

                try {
                  if (selectedPlatforms.isEmpty) {
                    showMessage(context, 'Please select at least one platform', 'error');
                    return;
                  }

                  final user = widget.userData;

                  final data = {
                    'displayName': widget.username,
                    'email': user.email,
                    'uid': user.id,
                    'websitesPreference': selectedPlatforms.join(', '),
                  };

                  final response = await SupabaseCredentials.supabaseClient
                      .from('user_preferences')
                      .upsert(data,onConflict: 'email');

                  if (response!= null) {
                    print('Error inserting data: ${response.error!.message}');
                    showMessage(context, 'Error inserting data: ${response.error!.message}', 'error');
                  } else {
                    showMessage(context, 'Your Preferences have been saved', 'success');

                    widget.contestViewModel.hasFetchedData = false;

                    if(!widget.pop){
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainScreen(contestViewModel: widget.contestViewModel),
                        ),
                      );
                    }
                    else{
                      Navigator.pop(context);
                    }
                  }
                }
                catch(e){
                  print("ERROR !!! $e");
                }
              },
              child: Text('Next',style: TextStyle(color: Colors.white,fontSize: 18)),
            ),
          ],
        ),
      ),
    )
    );
  }
}

class NextScreen extends StatelessWidget {
  final List<String> selectedPlatforms;

  NextScreen({required this.selectedPlatforms});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selected Platforms'),
      ),
      body: Center(
        child: Text('Selected Platforms: ${selectedPlatforms.join(', ')}'),
      ),
    );
  }
}
