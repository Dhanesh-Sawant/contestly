import 'package:contestify/View/select_sound.dart';
import 'package:contestify/View/signing_options.dart';
import 'package:contestify/View/signup_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase/supabase.dart';
import '../Provider/auth_notifier.dart';
import '../Utils/constants.dart';
import '../View_Models/contest_view_model.dart';
import '../Widgets/error_widget.dart';
import 'main_screen.dart';

class LoginView extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ContestViewModel contestViewModel;
  final AuthNotifier authNotifier;

  LoginView({
    required this.contestViewModel, required this.authNotifier,
  });

  @override
  Widget build(BuildContext context) {

    // final ContestViewModel contestViewModel  = Provider.of<ContestViewModel>(context,listen:false);

    return Consumer<ContestViewModel>(
      builder: (context, contestViewModel, _) => Consumer<AuthNotifier>(
          builder: (context, authNotifier, _) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => {
                Navigator.pop(context)
            }
            ),
          ),
          title: Text('Log In'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width*0.8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height*0.06),
                    CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 70,
                      backgroundImage: AssetImage('assets/images/final-logo.png'),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email, color: Colors.white),
                        labelText: 'Email',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.password, color: Colors.white),
                        labelText: 'Password',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)
                        ),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () async {
                        String email = emailController.text;
                        String password = passwordController.text;

                        if(email.isNotEmpty && password.isNotEmpty){

                          if(!Constants.isValidEmail(email)){
                            showMessage(context, "Invalid Email", "error");
                          }
                          else {
                            try {
                              AuthResponse? authResponse = await authNotifier.logIn(
                                  email: email, password: password);

                              if (authResponse != null) {
                                showMessage(context, "Sign in Successfull!!", "success");
                                print(
                                    "PRINTING USER B4 SETTING : ${authResponse.user}");
                                print(
                                    "PRINTING USERNAME B4 SETTING : ${authResponse.user!
                                        .userMetadata?['displayName']}");
                                contestViewModel.setUser(authResponse.user!,
                                    authResponse.user!.userMetadata?['displayName']);

                                await saveSession(email, authResponse.session!.refreshToken!);


                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MainScreen(contestViewModel: contestViewModel),
                                  ),
                                );
                              }

                            }
                            catch (e) {
                              showMessage(context, e.toString(), "error");
                            }
                          }
                        }
                        else{
                          showMessage(context, "fill all the fields", "error");
                        }

                      },
                      child: Text('Log In'),
                        style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(Size(MediaQuery.of(context).size.width*0.5, 50)),
                            backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
                            foregroundColor: MaterialStateProperty.all(Colors.white)
                        )
                    ),
                    SizedBox(height: 25),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>SignUpView(authNotifier: authNotifier, contestViewModel: contestViewModel,)));
                      },
                      child: Text('Don\'t have an account? Sign Up'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      )));
    }
  }

