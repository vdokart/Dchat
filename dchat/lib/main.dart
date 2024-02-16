import 'package:dchat/TextGenerationSettingsScreen.dart';
import 'package:dchat/chatscreen.dart';
import 'package:dchat/login.dart';
import 'package:dchat/register.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');
  String? password = prefs.getString('password');

  runApp(MyApp(
    initialRoute: username != null && password != null ? '/chat' : '/',
  ));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const LoginPage(),
        '/registration': (context) => const RegistrationPage(),
        '/chat': (context) => const ChatScreen(),
        '/text_generation_settings': (context) =>
            const TextGenerationSettingsScreen(),
      },
    );
  }
}

class AppConfig {
  static const String appName = "DChat";
  static const String appVersion = "1.0.0";
  static const String appLocale = "en";
  static const String dbName = "dchat.db";
  static const String dbVersion = "1.0.0";
}
