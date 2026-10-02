import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campos/state/event_provider.dart';
import 'package:campos/ui/screens/main_navigation_screen.dart';
import 'package:campos/ui/theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CampusPilotApp());
}

class CampusPilotApp extends StatelessWidget {
  const CampusPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => EventProvider())],
      child: MaterialApp(
        title: 'CampusPilot AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.navyDark,
            primary: AppColors.navyDark,
            secondary: AppColors.purpleAccent,
            surface: AppColors.cardSurface,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.navyDark,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const MainNavigationScreen(),
      ),
    );
  }
}
