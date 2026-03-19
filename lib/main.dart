// CHANGES MADE:
// 1. Updated `main.dart` to include `MultiProvider` for all services.
// 2. Initialized `CodexService` and `AnomalyService` as they are dependencies for `SimulationService`.
// 3. Registered `SimulationService` using the correctly injected constructor.
// 4. Maintained the theme and root navigation to `HomeScreen`.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants.dart';
import 'services/simulation_service.dart';
import 'services/codex_service.dart';
import 'services/anomaly_service.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CodexService()),
        ChangeNotifierProxyProvider<CodexService, AnomalyService>(
          create: (context) => AnomalyService(context.read<CodexService>()),
          update: (context, codex, previous) => previous ?? AnomalyService(codex),
        ),
        ChangeNotifierProxyProvider2<CodexService, AnomalyService, SimulationService>(
          create: (context) => SimulationService(
            context.read<CodexService>(),
            context.read<AnomalyService>(),
          ),
          update: (context, codex, anomaly, previous) => previous ?? SimulationService(codex, anomaly),
        ),
      ],
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
