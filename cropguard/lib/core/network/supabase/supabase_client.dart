import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class SupabaseClient {
  static const String baseUrl = 'https://isvpbjbgegbgyxagbwko.supabase.co';
  static const String apiKey = 'sb_publishable_z-vrMOmZd5eXjrvgDVRcZA_0A92UmWq';

  static Future<void> init() async {
    await supabase.Supabase.initialize(url: baseUrl, publishableKey: apiKey);
  }

  static supabase.SupabaseClient get client =>
      supabase.Supabase.instance.client;
}
