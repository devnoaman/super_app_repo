# Super app manager Monorepo

Welcome to the Super app manager repository! This project implements a robust "Super App" architecture using Flutter, allowing a host application (`super_gudea`) to run and interact with multiple "Mini Apps" (`apps/*`).

The system is designed to be **Platform Agnostic**:
- **On Web**: Mini Apps run inside an `InAppWebView` within the Super App. They leverage `dart:js_interop` to communicate with the host.
- **On Mobile (Standalone)**: Mini Apps can be compiled and run as distinct native apps for testing or standalone usage. They leverage `super_app_manager` directly to access native features.

---

## 📚 Deep Dive: Packages & Architecture

The repository functionality is distributed across three core packages in the `packages/` directory. Understanding these is key to developing Mini Apps.

### 1. `super_app_common`
**"The Shared Language"**

- **Responsibility**: Contains data models, events, and constants shared between the Super App, Mini Apps, and the Bridge. It has ZERO dependencies on Flutter UI or native plugins, making it lightweight.
- **Key Components**:
  - `AppConfig`: Defines the configuration passed from Super App to Mini App (User ID, Theme, Locale, API Endpoints).
  - `ShellEvent`: The base class for all events sent from the Shell to the Mini App (e.g., `PictureTakenEvent`, `LocationUpdateEvent`).
  - `MiniAppEntity`: Metadata for a Mini App (ID, Name, Icon, URL).
- **Usage**: Import this in every project to ensure type safety when passing data around.

### 2. `super_app_bridge`
**"The Communication Layer"**

- **Responsibility**: Abstract the specific implementation of "Shell" services. It allows the Mini App to say "I want the camera" without worrying if it's running inside a WebView or as a standalone app.
- **Key Components**:
  - `ShellService` (Interface): Defines methods like `requestCamera()`, `requestScanner()`, `events` (Stream).
  - `getPlatformShellService()`: A factory function that **automatically** returns the correct implementation:
    - **Web**: Returns `WebShellService` (Communicates via JS Bridge).
    - **Mobile**: Returns `MobileShellService` (Communicates via `AppOperations`).
- **Usage**: Mini Apps depend on this package to interact with the outside world. They should **never** directly depend on native plugins like `image_picker` if they want to remain compatible with the Super App Shell.

### 3. `super_app_manager`
**"The Enforcer & Provider"**

- **Responsibility**: Contains the **heavy implementation** of native features and the hosting logic. It includes the actual code that opens the camera, scans QR codes, or manages the WebView.
- **Key Components**:
  - `AppOperations`: The central registry for native actions (`openCamera`, `openScanner`).
  - `MiniAppHostScreen`: The UI widget that hosts a Web Mini App inside the Super App.
  - **Native Plugin Management**: This package aggregates dependencies like `image_picker`, `mobile_scanner`, `geolocator`.
- **Usage**:
  - **In Super App**: Used to provide the environment for Mini Apps.
  - **In Mini App (Standalone Mobile)**: Used as a dev/runtime dependency to provide native capabilities when *not* running inside the Super App.

---

## 🛠 How to Create a New Mini App

Follow this guide to create a new Mini App that works seamlessly in both Web (Super App) and Mobile (Standalone) modes.

### Step 1: Create the Project
Navigate to the `apps/` directory and create a new Flutter project.
```bash
cd apps
flutter create --platforms=web,ios,android my_new_mini_app
```

### Step 2: Configure Dependencies (`pubspec.yaml`)
Add the necessary repo packages.
- `super_app_bridge`: Required for shell communication.
- `super_app_common`: Required for models.
- `super_app_manager`: Required **only** for standalone mobile capabilities.

```yaml
dependencies:
  flutter:
    sdk: flutter
  super_app_bridge:
    path: ../../packages/super_app_bridge
  super_app_common:
    path: ../../packages/super_app_common
  # Required for standalone mobile support:
  super_app_manager:
    path: ../../packages/super_app_manager
```

### Step 3: Implement `main.dart`
Your `main.dart` needs to handle initialization differently depending on the platform, but `super_app_bridge` makes this easy.

**Key Requirements:**
1. **Initialize ShellService**: Use `getPlatformShellService()`.
2. **Register Navigator Key**: (Critical for Standalone Mobile) Create a `GlobalKey<NavigatorState>` and allow `AppOperations` to use it. This ensures native dialogs (like the QR Scanner) have a valid context.

**Template `main.dart`:**
```dart
import 'package:flutter/material.dart';
import 'package:super_app_bridge/super_app_bridge.dart';
import 'package:super_app_manager/super_app_manager.dart'; // Import Manager

// 1. Create a global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Register key with AppOperations for standalone mobile support
  AppOperations.navigatorKey = navigatorKey;

  // 3. Get the correct shell service (Web or Mobile)
  final shellService = getPlatformShellService(apiKey: 'YOUR_API_KEY');

  runApp(MyMiniApp(shellService: shellService));
}

class MyMiniApp extends StatelessWidget {
  final ShellService shellService;

  const MyMiniApp({super.key, required this.shellService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // 4. Pass key to MaterialApp
      home: HomeScreen(shellService: shellService),
    );
  }
}
```

### Step 4: Using Features
Inside your screens, use `shellService` to request actions.

```dart
// Request Camera
widget.shellService.requestCamera();

// Request Scanner
widget.shellService.requestScanner();

// Listen for Results
widget.shellService.events.listen((event) {
  if (event is PictureTakenEvent) {
    print("Photo received: ${event.base64Data}");
  }
});
```

### Step 5: Android/iOS Configuration
Since `super_app_manager` brings in native plugins (Camera, Location, etc.), you must configure your native project files even if you only write Dart code.

**iOS (`ios/Runner/Info.plist`)**:
Add permission descriptions:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access for...</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access for...</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need location access for...</string>
```
*Note: Run `pod install` in `ios/` after adding dependencies.*

**Android (`android/app/src/main/AndroidManifest.xml`)**:
Ensure permissions are merged or added if necessary (usually handled by plugins automatically).

---

## 🚀 Running Your Mini App

**Option A: Standalone Mobile**
1. `cd apps/my_new_mini_app`
2. `flutter run` (Select iOS or Android simulator/device)
*This uses `MobileShellService` + `AppOperations`.*

**Option B: In Super App (Simulated)**
Currently, to test inside the Super App, you must build the Mini App for Web and host it, then point the Super App to that URL.
1. `cd apps/my_new_mini_app`
2. `flutter run -d chrome --web-port=8080` (Debug mode)
*This uses `WebShellService` + JS Bridge.*

## 📦 Workspace Management (Melos)
This repo is configured as a Melos workspace.
- **Link Dependencies**: `melos bootstrap` (Links all local packages).
- **Format All**: `melos run format`.
- **Analyze All**: `melos run analyze`.
