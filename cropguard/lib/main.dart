import 'package:flutter/material.dart';
import 'package:cropguard/app.dart';
import 'package:cropguard/core/network/supabase/supabase_client.dart'
    as app_supabase;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await app_supabase.SupabaseClient.init();
  runApp(const CropGuardApp());
}
