// This provider creates an instance of our bridge repository implementation.
// It should live in the same file as your MiniAppHostNotifier.
// e.g., packages/apps/shell_app/lib/features/mini_app_host/presentation/providers/mini_app_host_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/i_mini_app_bridge_repository.dart';
import '../domain/repositories/mini_app_bridge_repository_impl.dart';
// import 'package:super_app_mobile/features/mini_app_host/domain/repositories/i_mini_app_bridge_repository.dart';
// import 'package:super_app_mobile/features/mini_app_host/domain/repositories/mini_app_bridge_repository_impl.dart';

final bridgeRepositoryProvider = Provider<IMiniAppBridgeRepository>(
  // The 'ref' parameter allows providers to talk to each other.
  // Here, we simply return the concrete implementation of our repository.
  (ref) => MiniAppBridgeRepositoryImpl(),
);
