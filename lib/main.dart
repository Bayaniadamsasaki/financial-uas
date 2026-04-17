import 'package:finalcial_records/shared/theme.dart';
import 'package:finalcial_records/ui/pages/add_financial_page.dart';
import 'package:finalcial_records/ui/pages/avatar_page.dart';
import 'package:finalcial_records/ui/pages/menu_page.dart';
import 'package:finalcial_records/ui/pages/profile_page.dart';
import 'package:finalcial_records/ui/pages/report_page.dart';
import 'package:finalcial_records/ui/pages/sign_in_page.dart';
import 'package:finalcial_records/ui/pages/sign_up_page.dart';
import 'package:finalcial_records/ui/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  Intl.defaultLocale = 'id_ID';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: lightBackgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: lightBackgroundColor,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: blackColor),
          titleTextStyle: blackTextStyle.copyWith(
            fontSize: 20,
            fontWeight: semiBold,
          ),
        ),
      ),
      routes: {
        '/': (context) => const SplashPage(),
        '/sign-in': (context) => const SignInPage(),
        '/sign-up': (context) => const SignUpPage(),
        '/menu': (context) => const MenuPage(),
        '/add': (context) => const AddFinancialPage(),
        '/report': (context) => const ReportPage(),
        '/profile': (context) => const ProfilePage(),
        '/avatar': (context) => const AvatarPage(),
      },
    );
  }
}
