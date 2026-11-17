import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'SDK default storage retains readable session JSON in preferences',
    () async {
      SharedPreferences.setMockInitialValues({});
      const key = 'sb-test-project-auth-token';
      const syntheticSession =
          '{"access_token":"synthetic","refresh_token":"synthetic"}';
      final storage = SharedPreferencesLocalStorage(persistSessionKey: key);
      await storage.initialize();
      await storage.persistSession(syntheticSession);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(key) == syntheticSession, isTrue);
      await storage.removePersistedSession();
    },
  );
}
