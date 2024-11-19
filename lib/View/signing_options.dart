
import 'dart:math';
import 'package:flutter_social_button/flutter_social_button.dart';
import 'package:contestify/Credentials/supabase_credentials.dart';
import 'package:contestify/View/login_view.dart';
import 'package:contestify/View/select_sound.dart';
import 'package:contestify/View/signup_view.dart';
import 'package:contestify/View/website_selection_view.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase/supabase.dart';
// add the import statement
import  'package:delightful_toast/delight_toast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Provider/auth_notifier.dart';
import '../Utils/constants.dart';
import '../View_Models/contest_view_model.dart';
import '../Widgets/error_widget.dart';
import 'main_screen.dart';

Future<void> saveSession(String email, String refreshToken) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('email', email);
  await prefs.setString('refreshToken', refreshToken);
}

// Add this function to check for existing sessions
Future<String?> checkSession() async {
  final prefs = await SharedPreferences.getInstance();
  bool result = prefs.getString('refreshToken') != null;
  if(result){
    return prefs.getString('refreshToken')!;
  }
  return null;
}

class SigningOptions extends StatefulWidget {

  final AuthNotifier authNotifier;
  final ContestViewModel contestViewModel;

  SigningOptions({
    required this.contestViewModel,
    required this.authNotifier,
  });

  @override
  State<SigningOptions> createState() => _SigningOptionsState();
}

class _SigningOptionsState extends State<SigningOptions> {

  bool _isLoading = false;
  bool _isCheckingSession = true;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    String? refreshToken = await checkSession();
    if (refreshToken != null) {
      AuthResponse response = await SupabaseCredentials.supabaseClient.auth.setSession(refreshToken);
      User? myuser = response.user;
      String? myname = response.user?.userMetadata?['name'];

      print("GOT THE USER FROM THE EXISTING SESSION: $myuser");

      widget.contestViewModel.setUser(myuser!, myname!);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(contestViewModel: widget.contestViewModel),
        ),
      );
    }
    else{
      setState(() {
        _isCheckingSession = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {

    // final AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);
    // final ContestViewModel contestViewModel = Provider.of<ContestViewModel>(context);

    Future<bool> checkUserWithEmail(String email) async {
      final response = await SupabaseCredentials.supabaseClient
          .from('user_preferences')
          .select('email')
          .eq('email', email);

      if (response==null) {
        // Handle error
        print('Error fetching user data: ${response}');
        return false;
      }

      final List<dynamic>? users = response;
      print("PRINTING THE LIST OF USERS IF PRESENT OF GIVEN EMAIL: ${users.toString()}}");

      return users != null && users.isNotEmpty;
    }


    if (_isCheckingSession) {
      return Scaffold(
        body: Center(
          child: LoadingAnimationWidget.waveDots(color: Colors.white, size: 50),
        ),
      );
    }


    return Scaffold(
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black,Colors.black12],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 70,
                  backgroundImage: AssetImage('assets/images/final-logo.png'),
                ),
                SizedBox(height: 20),
                Text(
                  'Schedule your competitive\ncontests across all popular websites',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                return SignUpView(authNotifier: widget.authNotifier, contestViewModel: widget.contestViewModel);
                              },
                            ));
                          },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Sign up free',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                        return LoginView(contestViewModel: widget.contestViewModel, authNotifier: widget.authNotifier);
                      },
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.deepPurple, width: 2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Log in',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'or continue with',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                buildSignInButton(
                  isLoading: _isLoading,
                  icon: FontAwesomeIcons.google,
                  text: _isLoading ? "" : '',
                  color: Colors.black,
                  onPressed: () async {

                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      AuthResponse? authResponse = await widget.authNotifier
                          .googleSignIn();
                      if (authResponse != null && authResponse.user != null) {

                        showMessage(context, "Google Sign in Successfull!!", "success");

                        User? myuser = authResponse.user;
                        String? myname = authResponse.user!
                            .userMetadata?['name'];
                        print("PRINTING USER B4 SETTING : $myuser");
                        print("PRINTING USERNAME B4 SETTING : $myname");

                        widget.contestViewModel.setUser(myuser!, myname!);

                        String myemail = authResponse.user!
                            .userMetadata?['email'] ?? "";


                        bool ans = await checkUserWithEmail(myemail);

                        await saveSession(myemail, authResponse.session!.refreshToken!);

                        if (ans == true) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainScreen(contestViewModel: widget.contestViewModel),
                            ),
                          );
                        }
                        else {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      WebsiteSelectionView(
                                          pop: false,
                                          userData: myuser,
                                          username: myname,
                                          contestViewModel: widget
                                              .contestViewModel
                                      )
                              ));
                        }
                      }else{
                        showMessage(context, "Sign in Cancelled", "error");

                      }
                    }catch(e){
                      showMessage(context, e.toString(), "error");
                    }
                    finally{
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Text('By continuing, you agree to our',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                GestureDetector(
                  onTap: () => _launchURL("https://dhanesh-sawant.github.io/contestify-privacy-policy/"),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text('Privacy Policy',
                      style: TextStyle(
                        color: Colors.deepPurple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget buildSignInButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return SizedBox(
      width: 50, // Fixed width for all buttons
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: onPressed,
            child: isLoading? Positioned.fill(
              child: Center(child: LoadingAnimationWidget.waveDots(color: Colors.white, size: 20)),
            ) : Container(

              child:
                  Container(
                      child:
                      Image.network(
                          'http://pngimg.com/uploads/google/google_PNG19635.png',
                          fit:BoxFit.cover
                      )
                  )
            ),
          ),
    ]
    )
    );
  }

void _launchURL(String url) async {
  print("LAUNCHING URL");
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url),mode: LaunchMode.inAppBrowserView);
    print("LAUNCHED URL");
  } else {
    throw 'Could not launch $url';
  }
}
