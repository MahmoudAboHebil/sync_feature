import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sync_feature/config/constants.dart';
import 'package:sync_feature/core/internet_service/internet_bloc/internet_bloc.dart';
import 'package:sync_feature/core/isar_service/isar_service.dart';
import 'package:sync_feature/sync_engine/presentation/blocs/sync_bloc/sync_bloc.dart';
import 'package:sync_feature/sync_engine/presentation/pages/home_page.dart';

import 'bloc_observer.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  await Supabase.initialize(
    url: projectSupabaseUrl,
    anonKey: projectSupabaseAnonKey,
  );
  await IsarService.getInstance();
  await initializeDependencies();

  runApp(MyApp());
}

Future<void> testInternet() async {
  final res = await http.get(Uri.parse("https://google.com"));
  print('ddddddddd ${res.statusCode}');
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SyncBloc>(
          create: (BuildContext context) => sl<SyncBloc>(),
        ),
        BlocProvider<InternetBloc>(
          create: (BuildContext context) => sl<InternetBloc>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
      ),
    );
  }
}
