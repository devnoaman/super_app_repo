// This is the code for your NEW Flutter Web project (the mini-app).
// The 'js' package is no longer needed in pubspec.yaml with this approach.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:super_app_bridge/super_app_bridge.dart';
import 'package:super_app_common/super_app_common.dart';
import 'dart:typed_data';
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

import 'package:super_app_manager/super_app_manager.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  // ** NEW: Fetch config before running the app **
  // Register the navigator key so AppOperations (and ShellService) can find the context
  AppOperations.navigatorKey = navigatorKey;

  final service = getPlatformShellService(apiKey: 'apiKey');
  // final config = await service.getConfiguration();

  runApp(
    MiniApp(
      // ** NEW: Pass theme to the app **
      // config: config,
      shellService: service,
      // isShell: config != null,
    ),
  );
}

class MiniApp extends StatefulWidget {
  // final AppConfig? config;
  final ShellService shellService;
  // final bool isShell;

  const MiniApp({
    super.key,
    // required this.config,
    required this.shellService,
    // required this.isShell,
  });

  @override
  State<MiniApp> createState() => _MiniAppState();
}

class _MiniAppState extends State<MiniApp> {
  // ShellService? service;
  AppConfig? config;
  bool? isShell;
  @override
  void initState() {
    // final service = ShellService();
    _initializeService(widget.shellService);
    super.initState();
  }

  Future<void> _initializeService(ShellService service) async {
    config = await service.getConfiguration();
    isShell = config != null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // ** NEW: Pass the navigator key **
      title: 'Camera App',

      theme: config?.theme == 'dark' ? ThemeData.dark() : ThemeData.light(),
      locale: Locale(config?.deviceLocale ?? 'en_US'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('ar'), Locale('en')],

      home: isShell == true
          ? ProfileScreen(shellService: widget.shellService)
          : const DownloadSuperAppScreen(),
      routes: {'/settings': (context) => const SettingsScreen()},
    );
  }
}

// ** NEW: A screen to prompt the user to download the super app **
class DownloadSuperAppScreen extends StatelessWidget {
  const DownloadSuperAppScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Download Super App')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'To use this mini app, you need to install the Super App.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () =>
                    _launchUrl('https://apps.apple.com/app/your-app-id'),
                child: const Text('Download from App Store'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _launchUrl(
                  'https://play.google.com/store/apps/details?id=your.package.name',
                ),
                child: const Text('Download from Play Store'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ** NEW: A separate widget for the settings screen **
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings view'),
        // The back button is automatically added by MaterialApp
      ),
      body: const Center(
        child: Text(
          'This is the settings page.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final ShellService shellService;
  const ProfileScreen({super.key, required this.shellService});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? _imageData;
  String _message = "Click the button to use the Super App's camera.";
  AppConfig? _config;
  StreamSubscription? _shellSubscription;
  @override
  void initState() {
    super.initState();
    _initializeApp();

    _shellSubscription = widget.shellService.events.listen((event) {
      // Handle the different, strongly-typed events

      switch (event) {
        case PictureTakenEvent(:final base64Data):
          if (mounted) {
            setState(() {
              _imageData = base64Decode(base64Data);
              _message = "Photo updated successfully!";
            });
          }
        case ScannerResultEvent(:final scanData):
          if (mounted) {
            setState(() {
              _message = "Scan Result: $scanData";
            });
          }
        case LocationUpdateEvent(:final latitude, :final longitude):
          if (mounted) {
            setState(() {
              _message = "Location: $latitude, $longitude";
            });
          }
        case LaunchUriEvent(:final uri):
          if (mounted) {
            setState(() {
              _message = "Launched URI: $uri";
            });
          }
        case ShellErrorEvent(:final message):
          debugPrint(event.toString());
          if (mounted) {
            setState(() {
              _message = "Error: $message";
            });
          }
      }
    });
    // ShellService.initialize((String base64) {
    //   debugPrint("Flutter Web Mini-App: Received picture from shell!");
    //   setState(() {
    //     _imageData = base64Decode(base64);
    //     _message = "Photo updated successfully!";
    //   });
    // });
  }

  Future<void> _initializeApp() async {
    widget.shellService.verify();
    // ShellBridge.verify();
    final config = await widget.shellService.getConfiguration();
    // final config = await ShellBridge.getConfiguration();
    if (mounted && config != null) {
      setState(() {
        _config = config;
      });
    }
  }

  void _handleTakePhoto() {
    setState(() {
      _message = "Waiting for Super App to open camera...";
    });
    widget.shellService.requestCamera();
    // ShellBridge.requestCamera();
  }

  void _handleScan() {
    setState(() {
      _message = "Waiting for Super App to open scanner...";
    });
    widget.shellService.requestScanner();
    // ShellBridge.requestScanner();
  }

  void _handleLocation() {
    setState(() {
      _message = "Waiting for Super App to get location...";
    });
    widget.shellService.requestLocation();
  }

  void _handleLaunchUri() {
    setState(() {
      _message = "Waiting for Super App to launch uri...";
    });
    widget.shellService.launchUri(Uri.parse("https://www.google.com"));
  }

  @override
  void dispose() {
    _shellSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ** NEW: Add an AppBar to hold the settings button **
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              // ** NEW: Navigate to the settings page **
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 75,
                backgroundColor: Colors.grey[300],
                backgroundImage: _imageData != null
                    ? MemoryImage(_imageData!)
                    : null,
                child: _imageData == null
                    ? const Icon(Icons.person, size: 75, color: Colors.grey)
                    : null,
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                    onPressed: _handleTakePhoto,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.barcode_reader),
                    label: const Text('Scan Qr'),
                    onPressed: _handleScan,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.barcode_reader),
                    label: const Text('get location'),
                    onPressed: _handleLocation,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.link),
                    label: const Text('launch uri'),
                    onPressed: _handleLaunchUri,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(_message, textAlign: TextAlign.center),
              const SizedBox(height: 30),
              if (_config == null)
                const CircularProgressIndicator()
              else
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Shell Config:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        Text("User ID: ${_config!.userId}"),
                        Text("Theme: ${_config!.theme}"),
                        Text("Locale: ${_config!.deviceLocale}"),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
