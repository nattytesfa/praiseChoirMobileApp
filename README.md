# praiseChoirMobileApp

A Flutter application for managing choir activities, songs, payments, and communications.

## Features
- Song library management
- Audio recording and playback
- Payment tracking
- Group chat
- Event calendar
- Member management

## Tech Stack
- **Framework:** Flutter & Dart
- **State Management:** BLoC (Primary), Provider
- **Local Storage:** Hive
- **Backend:** Firebase (Auth, Firestore, Core)
- **Audio:** just_audio, audio_service, record
- **Internationalization:** easy_localization
- **UI Components:** table_calendar, persistent_bottom_nav_bar_v2, flutter_slidable, emoji_picker_flutter

## Getting Started

### Prerequisites
- Flutter SDK (>=3.10.3)
- Dart SDK

### Installation
1. Clone the repository
2. Install dependencies
   ```bash
   flutter pub get
   ```
3. Generate code (for Hive, localization, etc.)
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Run the app
   ```bash
   flutter run
   ```

