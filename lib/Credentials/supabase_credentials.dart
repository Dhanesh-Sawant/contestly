import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseCredentials {
  static String? supabaseKey = dotenv.env['supabaseKey'];
  static String? supabaseUrl = dotenv.env['supabaseUrl'];

  static SupabaseClient supabaseClient = SupabaseClient(
    supabaseUrl!,
    supabaseKey!,
      authOptions: AuthClientOptions(
        pkceAsyncStorage: SecureStorage()
      ),
    // headers: {
    //   'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNuamNxcmJsb2tqZ3J3b2Nmd21pIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcxNzA2ODg2OCwiZXhwIjoyMDMyNjQ0ODY4fQ.FG7wliE-ACWAqKna17iA6jMr2FZJ2GJAhbzgR9kaWFo'
    // }
  );
}

