import 'package:contestify/Provider/auth_notifier.dart';
import 'package:contestify/View/login_view.dart';
import 'package:contestify/View/signing_options.dart';
import 'package:contestify/View/website_selection_view.dart';
import 'package:contestify/View_Models/contest_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase/supabase.dart';
import '../Utils/constants.dart';
import '../Widgets/error_widget.dart';

class SignUpView extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();

  final AuthNotifier authNotifier;
  final ContestViewModel contestViewModel;

  SignUpView({
    required this.authNotifier,
    required this.contestViewModel,
  });




  @override
  Widget build(BuildContext context) {

    // final AuthNotifier authNotifier = Provider.of<AuthNotifier>(context,listen: true);
    // final ContestViewModel contestViewModel = Provider.of<ContestViewModel>(context,listen: true);

    return Consumer<ContestViewModel>(
        builder: (context, contestViewModel, _) => Consumer<AuthNotifier>(
        builder: (context, authNotifier, _) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => {Navigator.pop(context)}
            ),
          ),
          title: Text('Sign Up'),
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
                      controller: displayNameController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person, color: Colors.white),
                        labelText: 'Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
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
                    SizedBox(height: 16),
                    TextField(
                      controller: confirmPasswordController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.password, color: Colors.white),
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)
                        ),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () async {
        
                        String displayName = displayNameController.text;
                        String email = emailController.text;
                        String password = passwordController.text;
                        String comfirmpassword = confirmPasswordController.text;
        
                        if(email.isEmpty || password.isEmpty || comfirmpassword.isEmpty || displayName.isEmpty){
                          showMessage(context, "Please fill all the fields", "error");
                        }
                        else if(!Constants.isValidEmail(email)){
                          showMessage(context, "Invalid Email", "error");
                        }
                        else if(password.length<6){
                          showMessage(context, "Password should be atleast 6 characters", "error");
                        }
                        else if(password!=comfirmpassword){
                          showMessage(context, "password and confirm password does'nt match", "error");
                          }
                          else {
                            try {
                              UserResponse? userresponse = await authNotifier.signUp(
                                  email: email,
                                  password: password,
                                  displayName: displayName);
        
                              if(userresponse!=null){
                                print("SETTING THE USER DETAILS");
                                contestViewModel.setUser(userresponse.user!, displayName);
                                print("DONE SETTING THE USERS");
                                showMessage(context, "Sign Up Successfull!!", "success");
        
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>WebsiteSelectionView(pop:false,userData: userresponse.user!,username: displayName, contestViewModel: contestViewModel)));
                              }
                              else{
                                showMessage(context, "Unsuccessfull Sign Up, please try again with correct credentials!!", "error");
                              }
                            }
                            catch(e){
                              showMessage(context, e.toString(), "error");
                            }
        
        
                          }
                          },
                      child: Text('Sign Up'),
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(Size(MediaQuery.of(context).size.width*0.5, 50)),
                        backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
                        foregroundColor: MaterialStateProperty.all(Colors.white)
                      )
                    ),
                    SizedBox(height: 25),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginView(contestViewModel: contestViewModel, authNotifier: authNotifier)));
                      },
                      child: Text('Already have an account? Log In'),
                    ),
                  ],
                ),
            ),
          ),
          ),
      ),
      ),
    ));
  }
}
