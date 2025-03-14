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
  
  // Create our services
  final userService = UserService();
  final localStorageService = LocalStorageService();
  final userRepository = UserRepository(
    userService: userService,
    localStorageService: localStorageService,
  );

  runApp(
    ProviderScope(
      overrides: [
        // Override the repository provider with our implementation
        userRepositoryProvider.overrideWithValue(userRepository),
      ],
      child: const MyApp(),
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

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Random User App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random User App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Clear Cache',
            onPressed: () async {
              // Get the repository and clear the cache
              final repository = ref.read(userRepositoryProvider);
              await repository.clearCache();
              
              // Show a snackbar to confirm
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
              
              // Refresh the users with a clean cache
              ref.read(usersProvider.notifier).loadUsers(forceRefresh: true);
            },
          ),
        ],
      ),
      body: const UserListView(),
    );
  }
}
