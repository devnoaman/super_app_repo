# Super App Monorepo - AI Coding Guidelines

This is a **Melos-managed Flutter monorepo** implementing a "Super App" architecture where a host application (`super_app_mobile`) hosts and manages multiple Mini Apps (`apps/*`).

## Architecture Overview

### Three-Tier Package System

1. **`super_app_common`** (Shared Language)
   - Zero Flutter UI dependencies, lightweight data models only
   - Contains: `AppConfig` (user/theme/locale/API data), `ShellEvent` (base event class), `MiniAppEntity`
   - Uses: `freezed` for immutable models, `json_serializable` for serialization
   - Every project imports this for type safety

2. **`super_app_bridge`** (Communication Abstraction)
   - Abstract `ShellService` interface defining platform-agnostic operations (camera, scanner, location, events)
   - Factory function `getPlatformShellService()` returns correct implementation:
     - **Web**: `WebShellService` via JS interop
     - **Mobile**: `MobileShellService` via `AppOperations`
   - Mini Apps depend on this to remain platform-agnostic

3. **`super_app_manager`** (Heavy Implementation)
   - Native feature implementation: `AppOperations` registry for platform actions
   - Hosts Mini Apps: `MiniAppHostScreen` wraps web apps in `InAppWebView`
   - Aggregates native plugins: `image_picker`, `mobile_scanner`, `geolocator`, `google_maps_flutter`, `permission_handler`
   - Required for standalone mobile Mini App development; optional for Super App

### Platform Behavior

- **Web**: Mini Apps run inside `InAppWebView` within Super App, communicate via JS bridge
- **Mobile (Standalone)**: Mini Apps can run as distinct native apps, using `super_app_manager` directly for native features
- **Mobile (Inside Super App)**: Same as web - uses JS bridge when running within host

## Mini App Development Patterns

### Initialization Template (`main.dart`)

```dart
import 'package:super_app_bridge/super_app_bridge.dart';
import 'package:super_app_manager/super_app_manager.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Critical for standalone mobile: register navigator key for native dialogs
  AppOperations.navigatorKey = navigatorKey;
  
  final service = getPlatformShellService(apiKey: 'apiKey');
  final config = await service.getConfiguration();
  
  runApp(MiniApp(shellService: service, navigatorKey: navigatorKey));
}
```

**Key Requirements:**
- Always register `GlobalKey<NavigatorState>` with `AppOperations` before running app
- Call `getPlatformShellService()` to get correct implementation automatically
- Fetch `AppConfig` to access user ID, theme, locale, API endpoints from host

### Communication Pattern

- **From Mini App to Host**: Use `ShellService.request*()` methods (camera, scanner, location)
- **From Host to Mini App**: Host sends events via `ShellService.events` stream (pictures, locations, custom events)
- **No Direct Plugin Dependencies**: Mini Apps should never import `image_picker`, `mobile_scanner` directly - use bridge instead

## Project Structure

```
apps/
  super_app_mobile/          # Shell/Host app (Riverpod-based UI)
  camera_mini_app/           # Example Mini App (web-first, mobile-compatible)
packages/
  super_app_common/          # Shared models (freezed, json_serializable)
  super_app_bridge/          # ShellService interface + platform factories
  super_app_manager/         # Native implementations, AppOperations, hosting logic
  shared/                    # Additional shared utilities (if any)
```

## Development Workflows

### Build/Run Commands

```bash
# Install workspace dependencies (required first time)
melos bootstrap

# Get all dependencies across all packages
melos get

# Run specific app (from root or app directory)
flutter run -t lib/main.dart

# Build web Mini App (for testing in Super App)
flutter build web --release

# Generate code (freezed, json_serializable)
melos run build_runner
```

### Code Generation

- **freezed**: Used in `super_app_common` and `super_app_manager` for immutable models
- **json_serializable**: Used for model serialization
- Run `melos run build_runner` (or `dart run build_runner build` in individual packages) after model changes

### Testing Patterns

- Super App hosts Mini Apps via `MiniAppHostScreen`
- For quick Mini App testing: run standalone (`flutter run`) with mock `AppOperations`
- For integration testing: run inside Super App shell

## Key Conventions

### Naming
- Mini App packages follow pattern: `{feature}_mini_app`
- Shell service methods: `request*()` (requestCamera, requestScanner, requestLocation)
- Event classes: `*Event` (PictureTakenEvent, LocationUpdateEvent, etc.)

### Dependency Imports
- Mini Apps: `super_app_bridge`, `super_app_common` (required); `super_app_manager` (optional for standalone)
- Super App: `super_app_manager`, `super_app_common`
- Never import app-specific packages across apps

### State Management
- Super App uses **Riverpod** (flutter_riverpod, flutter_hooks)
- Mini Apps: flexible (can use Riverpod, Provider, or simple setState)
- Both use `freezed` for models to ensure immutability

## Critical Integration Points

1. **Platform Detection**: `getPlatformShellService()` uses conditional imports (`dart:library.js_interop`) - always use, never hardcode platform detection
2. **Navigator Access**: `AppOperations.navigatorKey` must be set before native dialogs/actions occur
3. **Event Listening**: Mini Apps listen to `ShellService.events` stream for host-initiated actions (e.g., QR scan completion)
4. **Config Propagation**: Always fetch and cache `AppConfig` - it contains user context, theme, API endpoints

## When Adding New Features

1. Define event/model in `super_app_common` → generate code (freezed)
2. Add interface method to `ShellService` in `super_app_bridge`
3. Implement in both `ShellServiceWeb` and `ShellServiceMobile` (and `AppOperations` if native action)
4. Update Mini App template documentation in root `ReadMe.md`
