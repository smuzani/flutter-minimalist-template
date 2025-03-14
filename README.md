# Random User App

A cross-platform Flutter application that displays random user data from the [Random User API](https://randomuser.me/). The app follows the MVVM architecture pattern and works across all Flutter-supported platforms.

## Features

- Fetches and displays random user data
- Implements MVVM architecture (View-ViewModel-Repository-Service)
- Provides local caching for offline use
- Gracefully handles network connectivity issues
- Shows detailed user information
- Works on all Flutter platforms (iOS, Android, Web, macOS, Windows, Linux)

## Architecture

The app follows a clean MVVM architecture:

- **Model**: Data classes representing users (`UserModel`)
- **View**: UI components (`UserListView`, `UserDetailView`)
- **ViewModel**: Reactive state management using Riverpod
- **Repository**: Manages data sources (network vs local)
- **Service**: API communication and local storage

## Network Connectivity Issues

If you encounter network connectivity issues (particularly on macOS):

### For macOS Users

The error "Operation not permitted, errno = 1" is typically a macOS network permissions issue. To fix it:

1. Make sure the app has network entitlements:
   - `com.apple.security.network.client` should be present in the entitlements files (already included in this project)

2. Check your macOS security settings:
   - Go to System Preferences > Security & Privacy > Privacy > Network
   - Ensure your Flutter/Dart app has network permissions

3. If running from Xcode:
   - Run from Xcode with appropriate signing
   - Sign your app with a valid developer certificate

The app includes fallback mechanisms that will show mock data if the network is unavailable, so you can still test the app's functionality.

## Setup & Running

1. Make sure you have Flutter installed
2. Clone this repository
3. Run `flutter pub get` to fetch dependencies
4. Run `flutter run` to launch the app on your preferred platform

## Dependencies

- http: ^1.2.0 - For network requests
- provider: ^6.1.1 - For state management
- shared_preferences: ^2.2.2 - For simple local storage
- flutter_riverpod: ^2.4.10 - For reactive state management
- path_provider: ^2.1.2 - For file system access
- sqflite: ^2.3.2 - For SQLite database

## Troubleshooting

- If you encounter network issues, the app will display an appropriate message and use mock data.
- For persistent network issues, check your internet connection and platform-specific network settings.
- The app's error handling ensures that it will still function with cached or mock data when network is unavailable.

## License

This project is open source under the MIT License.
