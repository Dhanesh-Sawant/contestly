import 'dart:ui';

import 'package:contestify/Credentials/supabase_credentials.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_social_button/flutter_social_button.dart';
import '../View_Models/contest_view_model.dart';
import 'main_screen.dart';

class SoundPickerScreen extends StatefulWidget {

  final ContestViewModel contestViewModel;
  SoundPickerScreen({required this.contestViewModel});

  @override
  _SoundPickerScreenState createState() => _SoundPickerScreenState();
}

class _SoundPickerScreenState extends State<SoundPickerScreen> {
  String? selectedSoundPath;

  Future<void> _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      setState(() {
        selectedSoundPath = result.files.single.path!;
      });
    } else {
      print("User cancelled the file selection");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
        child:Scaffold(
      //     appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   title: Text(
      //     'Pick a Sound',
      //     style: TextStyle(
      //       color: Colors.white,
      //       fontSize: 24,
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      //   backgroundColor: Colors.black,
      // ),
      body: Stack(
        children: [Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/sound-test.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),child: Container(
            color: Colors.black.withOpacity(0.3)),
            )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                Text(
                  'Select a sound for your contest reminders from your device',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (selectedSoundPath != null) ...[
                        Text(
                          'Selected Sound:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                        Text(
                          selectedSoundPath!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueAccent,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        IconButton(onPressed: (){
                          setState(() {
                            selectedSoundPath = null;
                          });

                        }, icon: Icon(Icons.cancel), color: Colors.red, iconSize: 20,),

                        SizedBox(height: MediaQuery.of(context).size.height * 0.15)
                      ],
                      ElevatedButton(
                         onPressed: selectedSoundPath!=null ? () async {
                           try {
                             print('Selected Sound: $selectedSoundPath');

                             final data = {
                               'email': SupabaseCredentials.supabaseClient.auth
                                   .currentUser!.email,
                               'soundPath': selectedSoundPath,
                             };

                             print("printing the data: $data");

                             final response = await SupabaseCredentials.supabaseClient.from(
                                 'alarm').upsert(data, onConflict: 'email');

                             print("SELECTED SOUND PATH SAVED IN SUPABASE");
                           }
                           catch(e){
                             print("ERROR IN SAVING SELECTED SOUND PATH IN SUPABASE");
                           }

                           Navigator.pushReplacement(
                             context,
                             MaterialPageRoute(
                               builder: (context) => MainScreen(contestViewModel: widget.contestViewModel),
                             ),
                           );
                         } : _pickAudioFile,
                        child: selectedSoundPath!=null ? Text('Confirm Selection') : Text('Pick Sound'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                    ],
                  ),
                ),
                SizedBox(height: 20),

              ],
            ),
          ),
        ]),
      backgroundColor: Colors.black,
    ));
  }
}

