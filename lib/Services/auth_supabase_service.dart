import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase/supabase.dart';
import '../Credentials/supabase_credentials.dart';
import '../View/signing_options.dart';

class AuthenticationService {

  // Future<void> saveSession(Session session) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('access_token', session.accessToken ?? '');
  //   await prefs.setString('refresh_token', session.refreshToken ?? '');
  // }

  Future<UserResponse?> signUp({
    required String displayName,
    required String email,
    required String password,
  }) async {
    try {

      AuthResponse myAuthResponse;


      print("signing up the user with the username and password : $email $password");
      AuthResponse response = await SupabaseCredentials.supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      myAuthResponse = response;

      print(response);


      if (response.user != null) {
        final user = response.user!;
        final updateResponse = await SupabaseCredentials.supabaseClient.auth
            .updateUser(
          UserAttributes(data: {
            'displayName': displayName,
          }),
        );

        final updatedUserResponse = await SupabaseCredentials.supabaseClient.auth.getUser();
        if (updatedUserResponse.user!= null) {
          print("USER META DATA ${user.userMetadata.toString()}");
          print('Sign-up successful! Email: $email');

          await saveSession(email, myAuthResponse.session!.refreshToken!);

        } else {
          print('Sign-up failed: No user returned.');
        }
        return updatedUserResponse;
      }
    } catch (error) {
      print('CAUGHT AN EXCEPTIONS: Sign-up failed: ${error.toString()}');
    }
  }

  Future<AuthResponse?> LogIn({
    required String email,
    required String password,
  }) async {
    try {

      final response = await SupabaseCredentials.supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print(response);

      if (response.user != null) {
        print("USER META DATA ${response.user!.userMetadata.toString()}");
        print('Sign-in successful! Email: $email');

        User? user = response.user;
        String? username = response.user!.userMetadata?['displayName'];
      } else {
        print('Sign-in failed: No user returned.');
      }
      return response;

    } catch (error) {
      if (error is AuthException) {
        throw Exception('${error.message}');
      } else {
        throw Exception('$error');
      }
    }
  }

  final GoogleSignIn MygoogleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/userinfo.profile',
        'openid',
      ],
      serverClientId: dotenv.env['serverClientId']!
  );

  Future<AuthResponse?> googleSignIn() async {
    try {
      print("SERVER CLIENT ID : ${MygoogleSignIn.serverClientId}");
      print("NOW STARTING TO SIGNIN");
      final googleUser = await MygoogleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in canceled by user.');
      }
      print("goolge user : ${googleUser.toString()}");
      GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      print("PRINTING GOOGLE AUTH: ${googleAuth.idToken}");
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      else if (idToken == null) {
        // print(accessToken);
        print('No ID Token found.');
        throw 'No ID Token found.';
      }
      else {
        print("PRINTING ID TOKEN: $idToken");
        print("PRINTING ACCESS TOKEN: $accessToken");

        print("NOW SIGNING WITH IDTOKEN GOOGLE");
      AuthResponse response = await SupabaseCredentials.supabaseClient.auth
          .signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      print("DONE SIGNING WITH IDTOKEN GOOGLE");


      if (response.session != null) {
        print("USER META DATA ${response.user!
          ..userMetadata.toString()}");
        print('google auth successful! ${response.user}');
        return response;
        // Navigator.push(context, MaterialPageRoute(builder: (context)=> ContestTabScreen(signUp: false, contestViewModel: ,)));
      } else {
        throw Exception('failed: No session returned.');
      }
    }
    } catch (error) {
      if (error is AuthException) {
        throw Exception('${error.message}');
      } else {
        throw Exception('$error');
      }
    }
  }


}
