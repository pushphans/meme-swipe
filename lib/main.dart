import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/meme_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';
import 'services/ad_service.dart';
import 'services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================
  // 🔥 ADMOB INITIALIZE
  // ============================================
  print('');
  print('🚀 Initializing AdMob...');
  try {
    await AdService.initialize();
    print('✅ AdMob initialization complete!');
  } catch (e) {
    print('❌ AdMob initialization failed: $e');
  }
  print('');

  // ============================================
  // 🔊 AUDIO INITIALIZE - ADD THESE 3 LINES
  // ============================================
  print('🔊 Initializing Audio...');
  await AudioService.initialize();
  print('✅ Audio ready!');

  // ============================================

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MemeProvider())],
      child: MaterialApp(
        title: 'MemeSwipe',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppConstants.primaryColor,
          scaffoldBackgroundColor: AppConstants.backgroundColor,
          brightness: Brightness.dark,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
