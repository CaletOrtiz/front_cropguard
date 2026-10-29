import 'package:flutter/material.dart';
import 'package:kroppi/app.dart';
import 'package:kroppi/core/network/api/fastapi_client.dart';
import 'package:kroppi/core/network/supabase/supabase_client.dart'
    as app_supabase;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await app_supabase.SupabaseClient.init();
  FastApiClient.init();
  runApp(const KroppiApp());
}
