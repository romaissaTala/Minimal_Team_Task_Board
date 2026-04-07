import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/di/injection_container.dart' as di;
import 'app.dart';

import 'package:app_links/app_links.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kklfzbmeuicuiiuslgec.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtrbGZ6Ym1ldWljdWlpdXNsZ2VjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU0MDA1NTYsImV4cCI6MjA5MDk3NjU1Nn0.4ZkeTxIb6KX3NBSfJfrt6rnDEThHqj-5ooVDP0DRTWg',
  );
  await di.init();
  final appLinks = AppLinks();

  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final session = data.session;

    if (session != null) {
      print("User logged in automatically!");
    }
  });
  appLinks.uriLinkStream.listen((uri) {
    if (uri.toString().contains('login-callback')) {
      Supabase.instance.client.auth.getSessionFromUrl(uri);
    }
  });

  runApp(const App());
}
