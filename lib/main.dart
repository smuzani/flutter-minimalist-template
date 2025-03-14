import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'repositories/user_repository.dart';
import 'services/user_service.dart';
import 'services/local_storage_service.dart';
import 'viewmodels/user_view_model.dart';
import 'views/user_list_view.dart';

// Create a provider override for userRepositoryProvider
final userRepositoryOverride = Provider<UserRepository>((ref) {
  final userService = UserService();
  // Register a dispose callback
  ref.onDispose(() {
    userService.dispose();
  });
  
  return UserRepository(
    userService: userService,
    localStorageService: LocalStorageService(),
  );
});

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Configure HTTP client for macOS
  if (Platform.isMacOS) {
    HttpOverrides.global = MyHttpOverrides();
  }
  
  runApp(
    ProviderScope(
      overrides: [
        userRepositoryProvider.overrideWithProvider(userRepositoryOverride),
      ],
      child: const MainApp(),
    ),
  );
}

// Custom HTTP overrides to help with macOS network permissions
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Random User App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const UserListView(),
    );
  }
}
