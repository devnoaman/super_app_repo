import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:super_app_common/models/app_config.dart';
import 'package:super_app_manager/src/models/mini_app_status.dart';

import '../mini_app_entity/mini_app_entity.dart';
import 'bridge_repository_provider.dart';

class MiniAppEntityHostState {
  final MiniAppStatus status;
  final bool canGoBack;
  final MiniAppEntity miniApp; // Now holds the full mini-app object

  const MiniAppEntityHostState({
    required this.status,
    required this.canGoBack,
    required this.miniApp,
  });

  MiniAppEntityHostState copyWith({MiniAppStatus? status, bool? canGoBack}) {
    return MiniAppEntityHostState(
      status: status ?? this.status,
      canGoBack: canGoBack ?? this.canGoBack,
      miniApp: miniApp,
    );
  }
}

// We use AsyncNotifier since initializing the bridge is an async operation.
// We also use 'family' to pass the selected MiniAppEntity object to the provider.
class MiniAppEntityHostNotifier extends AsyncNotifier<MiniAppEntityHostState> {
  // final MiniAppEntity
  // @override
  // Future<MiniAppEntityHostState> build(MiniAppEntity arg) async {

  // }

  MiniAppEntityHostNotifier(this.miniAppEntity);

  MiniAppEntity miniAppEntity;
  // MiniAppEntityHostNotifier(this.miniAppEntity);

  void initializeBridge(InAppWebViewController controller, AppConfig config) {
    final bridgeRepository = ref.read(bridgeRepositoryProvider);
    bridgeRepository.initialize(
      controller: controller,
      config: config,
      miniApp: miniAppEntity,
      onVerified: (status) {
        // When the async operation completes, update the state.
        state = AsyncData(
          state.value!.copyWith(
            status: status,
          ),
        );
      },
    );
  }

  void loadCompleted() {
    state = AsyncData(state.value!.copyWith(status: Verifying()));
  }

  void loadFailed(String? errorMessage) {
    print("Error loading mini-app: $errorMessage");
    state = AsyncData(state.value!.copyWith(status: Error()));
  }

  void updateCanGoBack(bool canGoBack) {
    state = AsyncData(state.value!.copyWith(canGoBack: canGoBack));
  }

  @override
  FutureOr<MiniAppEntityHostState> build() {
    // initializeBridge(controller, config);
    //  miniAppEntity = arg;

    return MiniAppEntityHostState(
      status: Loading(),
      canGoBack: false,
      miniApp: miniAppEntity,
    );
  }

  // @override
  // FutureOr<MiniAppEntityHostState> build(arg) {
  //   miniAppEntity = arg;

  //   return MiniAppEntityHostState(
  //     status: MiniAppStatus.loading,
  //     canGoBack: false,
  //     miniApp: miniAppEntity,
  //   );
  // }

  // @override
  // FutureOr<MiniAppEntityHostState> build() {
  //   // MiniAppEntity
  //   return MiniAppEntityHostState(
  //     status: MiniAppStatus.loading,
  //     canGoBack: false,
  //     miniApp: miniAppEntity,
  //   );
  // }
}

final miniAppHostProvider = AsyncNotifierProvider.autoDispose
    .family<MiniAppEntityHostNotifier, MiniAppEntityHostState, MiniAppEntity>(
      (entity) => MiniAppEntityHostNotifier(entity),
    );




// final miniAppProvider = AsyncNotifierProvider.autoDispose.family<, , >(.new);