import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'providers/theme_provider.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Immersive / edge-to-edge display
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive
  await HiveService.init();

  // Initialize Notifications
  await NotificationService.init();
  await NotificationService.requestPermission();

  runApp(
    const ProviderScope(
      child: DedoApp(),
    ),
  );
}

class DedoApp extends ConsumerStatefulWidget {
  const DedoApp({super.key});

  @override
  ConsumerState<DedoApp> createState() => _DedoAppState();
}

class _DedoAppState extends ConsumerState<DedoApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      ref.read(themeProvider.notifier).syncWithPlatformBrightness(brightness);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    ref.read(themeProvider.notifier).syncWithPlatformBrightness(brightness);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final profile = HiveService.getProfile();
    final hasProfile = profile != null && profile.username.isNotEmpty;

    return MaterialApp(
      title: 'DEDO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      themeAnimationDuration: const Duration(milliseconds: 250),
      themeAnimationCurve: Curves.easeInOut,
      home: hasProfile ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}
