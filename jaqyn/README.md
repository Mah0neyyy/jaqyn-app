# Jaqyn - Location Tracking App

Jaqyn is a Flutter application that allows users to track the location of their friends and family members in real-time. The app provides features like geofencing, friend management, and privacy controls.

## Features

- Real-time location tracking
- Google Sign-In authentication
- Friend management with QR code support
- Geofencing with notifications
- Privacy controls
- Modern UI with animations
- Cross-platform support (Android & iOS)

## Prerequisites

- Flutter SDK (latest version)
- Android Studio / Xcode
- Firebase account
- Google Maps API key
- Google Sign-In credentials

## Setup Instructions

1. Clone the repository:
```bash
git clone https://github.com/yourusername/jaqyn.git
cd jaqyn
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Create a new Firebase project
   - Add Android and iOS apps to your Firebase project
   - Download and add the configuration files:
     - `google-services.json` for Android
     - `GoogleService-Info.plist` for iOS
   - Enable Authentication (Google Sign-In)
   - Enable Firestore Database
   - Enable Realtime Database

4. Configure Google Maps:
   - Get a Google Maps API key from the Google Cloud Console
   - Add the API key to:
     - Android: `android/app/src/main/AndroidManifest.xml`
     - iOS: `ios/Runner/AppDelegate.swift`

5. Update Firebase configuration:
   - Replace the placeholder values in `lib/firebase_options.dart` with your actual Firebase configuration

6. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── models/           # Data models
├── views/            # UI components
│   ├── auth/         # Authentication screens
│   ├── home/         # Main screens
│   ├── profile/      # Profile screens
│   └── friends/      # Friends management screens
├── viewmodels/       # Business logic
├── services/         # External services
├── utils/            # Utility functions
└── constants/        # App constants
```

## Dependencies

- firebase_core: ^2.24.2
- firebase_auth: ^4.15.3
- firebase_database: ^10.3.7
- cloud_firestore: ^4.13.6
- google_sign_in: ^6.1.6
- google_maps_flutter: ^2.5.3
- geolocator: ^10.1.0
- qr_flutter: ^4.1.0
- provider: ^6.1.1
- flutter_animate: ^4.5.0
- lottie: ^2.7.0
- image_picker: ^1.0.7
- flutter_local_notifications: ^16.3.0

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Firebase team for the backend services
- All contributors and users of the app
