// This provider is located at:
// packages/apps/shell_app/lib/features/home/presentation/providers/home_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_app_manager/super_app_manager.dart';
// import 'package:shared/shared.dart';
import 'package:super_app_mobile/features/home/domain/entities/mini_app.dart';
import 'package:super_app_mobile/features/home/domain/repositories/i_home_repository.dart';
// import 'package:shell_app/features/home/data/repositories/home_repository_impl.dart';
// import 'package:shell_app/features/home/domain/entities/mini_app.dart';
// import 'package:shell_app/features/home/domain/repositories/i_home_repository.dart';

// The AsyncNotifier that contains the logic to fetch the mini-apps.
class MiniAppsNotifier extends AsyncNotifier<List<MiniAppEntity>> {
  @override
  Future<List<MiniAppEntity>> build() async {
    final repo = ref.watch(homeRepositoryProvider);
    return repo.getAvailableMiniApps();
  }
}

// The provider that the UI will watch to get the list of mini-apps.
final miniAppsProvider =
    AsyncNotifierProvider<MiniAppsNotifier, List<MiniAppEntity>>(
      () => MiniAppsNotifier(),
    );

// A separate provider for the repository to follow good practice.
final homeRepositoryProvider = Provider<IHomeRepository>(
  (ref) => HomeRepositoryImpl(),
);
