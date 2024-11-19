import 'package:contestify/Services/auth_supabase_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase/supabase.dart';

class AuthNotifier extends ChangeNotifier{

  final AuthenticationService _authenticationService = new AuthenticationService();

  Future<UserResponse?> signUp({
    required String displayName,
    required String email,
    required String password,
  }) async {
    try{
      UserResponse? userresponse = await _authenticationService.signUp(email: email, password: password, displayName: displayName);
      return userresponse;
    }
    catch(e){
      throw Exception("$e");
    }
  }

  Future<AuthResponse?> logIn({
    required String email,
    required String password,
  }) async {
    try{
      AuthResponse? authResponse = await _authenticationService.LogIn(email: email, password: password);
      return authResponse;
    }
    catch(e){
      throw Exception("$e");
    }
  }

  Future<AuthResponse?> googleSignIn()async{
    try{
      AuthResponse? authResponse = await _authenticationService.googleSignIn();
      return authResponse;
    }
    catch(e){
      throw Exception(e);
    }

  }
}