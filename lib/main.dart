import 'package:firebase_core/firebase_core.dart';
import 'package:flash_chat_flutter_review/screens/chat_screen.dart';
import 'package:flash_chat_flutter_review/screens/login_screen.dart';
import 'package:flash_chat_flutter_review/screens/registration_screen.dart';
import 'package:flash_chat_flutter_review/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        ChatScreen.id: (context) => ChatScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
      },
      initialRoute: WelcomeScreen.id,
    );
  }
}
