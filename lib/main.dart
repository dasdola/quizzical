import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/quiz_provider.dart';
import 'screens/welcome_screen.dart';
import 'services/opentdb_service.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(QuizzicalApp(prefs: prefs));
}

class QuizzicalApp extends StatelessWidget {
  const QuizzicalApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<QuizProvider>(
      create: (_) => QuizProvider(service: OpenTdbService(), prefs: prefs),
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const WelcomeScreen(),
      ),
    );
  }
}
