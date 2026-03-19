// CHANGES MADE:
// 1. Implemented the `AnomalySelectionScreen` for choosing between Normal and Challenge runs.
// 2. Used a `PageView` with custom `AnomalyCard` widgets for the 5 challenge types.
// 3. Added visual feedback for completed anomalies (COMPLETED stamp).
// 4. Integrated with `AnomalyService` to trigger the appropriate run initialization.
// 5. Styled with Orbitron and glassmorphism to maintain the cosmic aesthetic.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/anomaly_service.dart';
import '../services/simulation_service.dart';
import '../models/anomaly.dart';
import 'simulation_screen.dart';

class AnomalySelectionScreen extends StatefulWidget {
  const AnomalySelectionScreen({super.key});

  @override
  State<AnomalySelectionScreen> createState() => _AnomalySelectionScreenState();
}

class _AnomalySelectionScreenState extends State<AnomalySelectionScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  bool _isAnomalyMode = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anomalyService = context.watch<AnomalyService>();
    final anomalies = anomalyService.allAnomalies;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              "SELECT MISSION TYPE",
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 24,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 40),
            _buildModeToggle(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _isAnomalyMode 
                  ? _buildAnomalySelector(anomalies)
                  : _buildNormalModeInfo(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40),
              child: ElevatedButton(
                onPressed: () => _beginRun(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                ),
                child: Text(
                  _isAnomalyMode ? "BEGIN ANOMALY" : "BEGIN NORMAL RUN",
                  style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: _toggleButton("NORMAL", !_isAnomalyMode, () => setState(() => _isAnomalyMode = false)),
          ),
          Expanded(
            child: _toggleButton("ANOMALY", _isAnomalyMode, () => setState(() => _isAnomalyMode = true)),
          ),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: active ? Colors.black : Colors.white38,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildNormalModeInfo() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.public, color: Colors.white24, size: 80),
            const SizedBox(height: 30),
            Text(
              "STARDARD SIMULATION",
              style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Text(
              "Author the arc of the universe without external constraints. All physical constants are fully tunable across all stages.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnomalySelector(List<Anomaly> anomalies) {
    return PageView.builder(
      controller: _pageController,
      itemCount: anomalies.length,
      itemBuilder: (context, index) {
        return _AnomalyCard(anomaly: anomalies[index]);
      },
    );
  }

  void _beginRun(BuildContext context) {
    final anomalyService = context.read<AnomalyService>();
    final simService = context.read<SimulationService>();

    if (_isAnomalyMode) {
      final selectedAnomaly = anomalyService.allAnomalies[_pageController.page?.round() ?? 0];
      anomalyService.startAnomalyRun(selectedAnomaly.id);
    } else {
      anomalyService.clearAnomaly();
    }

    simService.reset();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SimulationScreen()),
    );
  }
}

class _AnomalyCard extends StatelessWidget {
  final Anomaly anomaly;
  const _AnomalyCard({required this.anomaly});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  anomaly.name,
                  style: GoogleFonts.orbitron(
                    color: Colors.cyanAccent,
                    fontSize: 20,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  anomaly.flavorText,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const Divider(color: Colors.white10, height: 40),
                const Text(
                  "MODIFICATIONS:",
                  style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2),
                ),
                const SizedBox(height: 10),
                Text(
                  anomaly.description,
                  style: const TextStyle(color: Colors.white70, height: 1.5),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.military_tech, color: Colors.amber, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      "BADGE: ${anomaly.badgeLabel.toUpperCase()}",
                      style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (anomaly.isCompleted)
            Positioned(
              top: 20,
              right: 20,
              child: Transform.rotate(
                angle: -0.2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.greenAccent, width: 2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    "COMPLETED",
                    style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
