import 'package:chasebank/screens/auth/login.dart';
import 'package:chasebank/screens/auth/register.dart';
import 'package:chasebank/screens/mainpage.dart';
import 'package:chasebank/screens/sendmoney_screen.dart';
import 'package:chasebank/screens/transfer_btc.dart';
//import 'package:chasebank/screens/transferandpay.dart';
import 'package:chasebank/screens/welcome_screen.dart';
import 'package:chasebank/screens/withdraw.dart';
import 'package:chasebank/theme/apptheme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Application name
      // Application theme data, you can set the colors for the application as
      // you want
      theme: appTheme,
      // A widget which will be started on application startup

      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/home': (context) => const MainPage(),
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const Register(),
        '/enter_amount': (context) => const SendMoneyScreen(),
        '/withdraw': (context) => const Withdraw(),
        '/transferToBtc': (context) => const TransferBtc(),
      },
    );
  }
}
