import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants.dart';
import 'services/simulation_service.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SimulationService(),
      child: const FineTunedUniverseApp(),
    ),
  );
}

class FineTunedUniverseApp extends StatelessWidget {
  const FineTunedUniverseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: GameConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: GameConstants.cosmicPurple,
        scaffoldBackgroundColor: GameConstants.spaceBlack,
        textTheme: GoogleFonts.exo2TextTheme(
          ThemeData.dark().textTheme,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
