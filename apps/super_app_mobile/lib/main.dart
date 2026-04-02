import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_app_mobile/features/home/presentation/home_screen.dart';

import 'package:wakelock_plus/wakelock_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Add this line

  if (kDebugMode) {
    WakelockPlus.enable();
  }
  // Add ProviderScope at the root of the application.

  runApp(
    const ProviderScope(
      child: SuperApp(),
    ),
  );
}

class SuperApp extends StatelessWidget {
  const SuperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Super App Shell',
      locale: Locale('en'),
      supportedLocales: [
        Locale('ar'),
        Locale('en'),
      ],
      //
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      //
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      //
      home: HomeScreen(),
    );
  }
}
