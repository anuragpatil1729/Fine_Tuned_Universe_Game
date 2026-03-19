// FEATURE: Session Persistence // WHAT CHANGED: Implemented `_AppLoader` to handle asynchronous service initialization (loading history from storage) before the UI is rendered. Integrated `MultiProvider` with `ProxyProvider` for dependency injection. // WHY: To ensure that the player's saved multiverse history is available immediately upon app launch and to maintain a clean service architecture.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants.dart';
import 'services/simulation_service.dart';
import 'services/codex_service.dart';
import 'services/anomaly_service.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      child: const _AppLoader(),
    ),
  );
}

class _AppLoader extends StatefulWidget {
  const _AppLoader();

  @override
  State<_AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<_AppLoader> {
  late Future<void> _init;

  @override
  void initState() {
    super.initState();
    // Start the persistent data load
    _init = context.read<SimulationService>().initAsync();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: Color(0xFF050505),
              body: Center(
                child: CircularProgressIndicator(
                  color: Colors.white24,
                ),
              ),
            ),
          );
        }
        return const FineTunedUniverseApp();
      },
    );
  }
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
