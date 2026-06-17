# PlayMate

PlayMate is a production-ready Flutter application that brings together essential tools for offline games and casual gatherings. Instead of downloading multiple utility apps, users get everything they need in one place.

Whether you’re playing Ludo with friends, organizing a gully cricket match, creating teams for a tournament, or simply need a coin toss, PlayMate provides a simple and intuitive experience.

## Features

### Dice Roller

*   Single and multiple dice support
*   Custom dice types (D4, D6, D8, D10, D12, D20)
*   Roll animations
*   Shake to roll
*   Roll statistics and history

### Coin Toss

*   Heads or tails simulation
*   Toss animations
*   Toss history

### Team Generator

*   Create random teams instantly
*   Support for multiple team configurations
*   Shuffle and regenerate teams
*   Save generated teams

### Score Tracker

*   Track scores for any custom game
*   Support for individual and team-based matches
*   Undo actions
*   Match history

### Cricket Scorer

*   Designed for simple gully cricket scoring
*   Track runs, wickets, overs, and targets
*   Toss support
*   Match summaries
*   Match history

### Spin Wheel

*   Create custom spin options
*   Random selection
*   Useful for truth or dare, punishments, winner selection, and more

### Tournament Generator

*   Generate tournament brackets
*   Support for 4, 8, 16, and 32 teams
*   Save tournament progress

### Timers

*   Countdown timer
*   Stopwatch
*   Turn timer
*   Chess timer

### Match History

*   View previous games and results
*   Search and filter records
*   Optional cloud synchronization

### Player Statistics

*   Matches played
*   Wins and losses
*   Win rate tracking
*   Leaderboards

### Achievement System

*   Unlock achievements based on usage
*   Extensible achievement architecture

## Tech Stack

### Framework

*   Flutter

### State Management

*   Riverpod
*   Riverpod Generator

### Architecture

*   Clean Architecture
*   Feature-First Architecture

### Routing

*   Go Router

### Local Storage

*   Hive

### Backend Services

*   Firebase Core
*   Firebase Authentication
*   Firebase Firestore
*   Firebase Analytics
*   Firebase Crashlytics
*   Firebase Remote Config

### Developer Experience

*   Freezed
*   Json Serializable
*   Build Runner
*   Flutter Lints

### CI/CD

*   GitHub Actions

### Monitoring

*   Firebase Crashlytics
*   Sentry (planned)

## Project Structure

lib/  
├── core/  
├── design\_system/  
├── shared/  
├── features/  
│ ├── home/  
│ ├── dice/  
│ ├── coin/  
│ ├── team\_generator/  
│ ├── score\_tracker/  
│ ├── cricket/  
│ ├── spin\_wheel/  
│ ├── tournament/  
│ ├── timer/  
│ ├── history/  
│ ├── statistics/  
│ ├── achievements/  
│ └── settings/  
├── routes/  
└── main.dart

## Design Principles

PlayMate follows a utility-first approach:

*   Minimal and clean interface
*   Native feeling experience
*   Responsive layouts
*   Accessibility support
*   Material 3 design
*   Light and dark themes
*   No AI-generated looking UI
*   No unnecessary visual clutter

## Responsive Design

The application is designed to work across multiple device sizes.

Supported layouts include:

*   Small Android devices
*   Large Android devices
*   Foldables
*   Tablets
*   iPhones
*   iPads

The project avoids:

*   RenderFlex overflows
*   Text overflows
*   Keyboard overflows
*   Pixel overflows

## Environments

The project supports multiple environments:

*   Development
*   Staging
*   Production

Each environment can maintain separate configurations and Firebase projects.

## Analytics Events

PlayMate tracks anonymous usage events to improve the product experience.

Examples include:

*   app\_open
*   dice\_roll
*   coin\_toss
*   team\_generated
*   score\_updated
*   cricket\_match\_created
*   spin\_wheel\_used
*   tournament\_created
*   timer\_started
*   achievement\_unlocked

## Getting Started

### Prerequisites

*   Flutter SDK
*   Dart SDK
*   Android Studio or VS Code
*   Firebase CLI
*   Android SDK
*   Xcode (for iOS development)

### Installation

Clone the repository:

git clone https://github.com/your-username/playmate.git

Navigate to the project directory:

cd playmate

Install dependencies:

flutter pub get

Run the application:

flutter run

## Building the App

Debug build:

flutter run

Android release build:

flutter build appbundle

iOS release build:

flutter build ios

## Roadmap

*   QR-based multiplayer sessions
*   Cloud synchronization
*   Premium subscription features
*   Social leaderboards
*   Advanced analytics
*   Daily challenges
*   Community requested utilities

## Contributing

Contributions, suggestions, and improvements are welcome.

If you find a bug or have an idea for a new feature, feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License.

## Author

Developed by **Sundramdotdev**.
