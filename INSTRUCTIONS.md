# Flutter Timer App - Instructions

## Project Setup

1. Clone or download the repository
2. Navigate to the project directory
3. Run `flutter pub get` to install dependencies

## Running the Application

### For Web:
```bash
flutter run -d chrome
```

### For Android:
```bash
flutter run -d android
```

### For Windows:
```bash
flutter run -d windows
```

## Building the Application

### Web Build:
```bash
flutter build web
```

The built application will be available in the `build/web` directory.

### Android Build:
```bash
flutter build apk
```

The APK will be available in the `build/app/outputs/flutter-apk` directory.

### Windows Build:
```bash
flutter build windows
```

The Windows executable will be available in the `build/windows/x64/runner/Release` directory.

## Dependencies

- Flutter SDK (version 3.9.2 or higher)
- audioplayers package for sound effects

## Project Structure

- `lib/timer/` - Contains all timer-related functionality
- `lib/main.dart` - Entry point of the application
- `assets/sounds/` - Directory for sound files (if any)

## Features

- Interval training timer with customizable routines
- Exercise and rest periods configuration
- Repeat counts for workout blocks
- Audio cues during timer events
- Cross-platform support (Web, Android, Windows)