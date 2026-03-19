# 🌌 Fine-Tuned Universe

> *"From the first spark to the final silence."*

A cosmic simulation game where you play as the architect of reality itself — tuning the fundamental physical constants that determine whether your universe collapses, burns bright, or blooms with life for trillions of years.

---

## What Is This?

**Fine-Tuned Universe** is a Flutter mobile game built around the real scientific concept of cosmological fine-tuning: the observation that if physical constants like gravity or the nuclear force were even slightly different, stars, atoms, and life could never form.

You are given control of those constants. You decide.

Each run takes you through the full arc of a universe — from the Big Bang to the final cosmic fate — one era at a time. The physics isn't magic; it's grounded in real astrophysics, from the Chandrasekhar limit to the Kardashev scale.

---

## Gameplay

The simulation unfolds across **7 sequential stages**, each requiring you to tune one physical constant:

| Stage | You Tune | What Happens |
|---|---|---|
| **Cosmic Dawn** | Gravity | Matter coalesces — or scatters forever |
| **Stellar Age** | Nuclear Force | Stars ignite — or hydrogen drifts cold in the dark |
| **Galactic Age** | EM Force | Spiral arms form — or atoms refuse to bond |
| **Life Age** | Entropy Rate | Complexity emerges — or dissolves into heat |
| **Stellar Death** | Dark Energy | The expansion accelerates — or collapses inward |
| **Civilization Dawn** *(unlockable)* | Cooperation Index | Intelligence organizes — or fractures into conflict |
| **Technological Age** *(unlockable)* | Energy Consumption | A species reaches the stars — or burns itself out |

Each slider has a **safe zone**. Stray too far and the universe's whisper turns to a warning. The visual, the ticker tape of cosmic events, and the atmospheric narration all react in real time.

---

## Endings

There are **7 possible outcomes**, each with its own animated ending screen:

- 🌿 **Eternal Garden** — Stars burn for a trillion years. Life spreads between galaxies.
- 🕯️ **Last Light** — Brief, blazing, beautiful. The universe burns fast and dies young.
- ⚫ **Great Collapse** — Gravity wins. Everything crushes back into a single silent point.
- 🔄 **Eternal Recurrence** — The universe loops. You are trapped in the cycle.
- ✨ **Transcendence** — The civilization solved cooperation and left the universe entirely.
- 💀 **Extinction** — They had the stars within reach. Internal conflict consumed them.
- ⚖️ **Equilibrium** — Not fire, not ice. Just billions of years of quiet endurance.

---

## Features

### 🧬 Universe DNA
Every universe is encoded as a **6-character alphanumeric seed** (e.g. `A3F7K2`). Share it with anyone to let them recreate your exact universe and explore what you built.

### 🔭 Multiverse Observatory
A zoomable, interactive star map of every universe you've ever created. Each one is plotted by its physical constants, connected by constellation lines, and tappable for detailed stats and a radar chart of its values.

### 📖 Cosmic Codex
15 lore entries grounded in real astrophysics and cosmology — unlocked by reaching stages, hitting thresholds, and achieving outcomes. From the RNA World to the Fermi Paradox to the Simulation Argument.

### ⚡ Anomaly Runs
Six seeded challenge runs that break the normal rules:

| Anomaly | Twist |
|---|---|
| **The Iron Star** | Nuclear force locked at 0.72 |
| **The Frozen Clock** | Entropy locked at 0.15 |
| **The Dark Tide** | Dark energy drifts upward automatically |
| **The Mirror Universe** | Safe zones are inverted — danger is now safety |
| **The Silent Bang** | Gravity locked at 0.20 — the universe is nearly empty |
| **The Warring Factions** | Cooperation locked at 0.20 — achieve Transcendence anyway |

Completing each anomaly earns a **badge** and unlocks cosmetic recognition in the Observatory.

### 💬 Whisper System
The universe narrates its own condition. When constants are off, it speaks. When everything is aligned, it hums: *"...I feel it. The quiet hum of something that wants to live."*

### 📡 Consequence Ticker
A live scrolling feed of causal events reacting to your current constants — hydrogen cloud timelines, stellar death sequences, and collapse warnings rendered in real time.

---

## Technical Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | Provider + ChangeNotifier |
| Persistence | SharedPreferences |
| Backend | Firebase (Firestore, Auth, Analytics) |
| Rendering | Custom `CustomPainter` per stage |
| Fonts | Google Fonts (Orbitron, Exo 2) |
| Physics | Sensors Plus (gyroscope parallax) |

### Architecture

```
lib/
├── core/
│   ├── constants.dart          # Safe zone thresholds, colors, enums
│   ├── simulation_engine.dart  # Outcome calculation logic
│   ├── universe_dna.dart       # Seed encoding / decoding
│   └── string_utils.dart       # Label formatting
├── models/
│   ├── universe_state.dart     # Immutable state snapshot
│   ├── codex_entry.dart        # Lore entry model
│   └── anomaly.dart            # Challenge run model
├── services/
│   ├── simulation_service.dart # Game state + stage transitions
│   ├── codex_service.dart      # Unlock tracking + persistence
│   ├── anomaly_service.dart    # Challenge run management
│   └── persistence_service.dart# JSON serialization of history
├── screens/
│   ├── home_screen.dart
│   ├── anomaly_selection_screen.dart
│   ├── simulation_screen.dart
│   ├── result_screen.dart
│   ├── observatory_screen.dart
│   └── codex_screen.dart
└── widgets/
    ├── universe_visual.dart     # Stage-specific animated painters
    ├── constant_slider.dart     # Safe zone slider with shudder
    ├── consequence_ticker.dart  # Scrolling event feed
    ├── whisper_bar.dart         # Atmospheric narration bar
    └── multiverse_observatory.dart # Background parallax map
```

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.11.0`
- Dart SDK (included)
- Android Studio or Xcode for device deployment
- A Firebase project (configuration files already included for the default project)

### Running Locally

```bash
# Clone the repository
git clone https://github.com/your-username/finetuneduniverse.git
cd finetuneduniverse

# Install dependencies
flutter pub get

# Run on a connected device or emulator
flutter run
```

### Building for Release

```bash
# Android
flutter build apk --release

# iOS
flutter build ipa --release
```

---

## Game Progression

```
First Run
  └─ Play through 5 stages → Outcome revealed
        └─ Achieve Eternal Garden
              └─ Civilization Layer unlocked (stages 6 & 7 available)
                    └─ Anomaly: Warring Factions becomes available
```

History, Codex unlocks, and Anomaly badges all persist across sessions. Up to 50 universes are saved in the Observatory. Use **Clear All Data** on the home screen to reset everything.

---

## The Science Behind It

This game is inspired by real cosmological and anthropic reasoning:

- **Fine-tuning problem** — Why are physical constants life-permitting? The probability of this occurring by chance is vanishingly small.
- **Chandrasekhar limit** — The mass threshold at which stars collapse into neutron stars or black holes, governed by nuclear force.
- **Kardashev scale** — A classification of civilizations by energy consumption (Type I, II, III).
- **Fermi paradox** — If intelligent life is common, why haven't we detected it? The game's Cooperation Index encodes one proposed answer: the coordination filter.
- **Jeans instability** — The density threshold at which gas clouds collapse into galaxies under gravity.

Each Codex entry expands on the real science underlying each game mechanic.

---

## License

This project is private and not currently published. All rights reserved.

---

*Built with Flutter. Grounded in physics. Haunted by the silence between galaxies.*
