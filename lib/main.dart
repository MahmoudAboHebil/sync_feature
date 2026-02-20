import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sync_feature/config/constants.dart';
import 'package:sync_feature/core/isar_service/isar_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: projectSupabaseUrl,
    anonKey: projectSupabaseAnonKey,
  );
  await IsarService.getInstance();

  runApp(MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: TextButton(onPressed: () {}, child: Text('Do Test')),
        ),
      ),
    );
  }
}
