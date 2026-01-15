import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:super_app_manager/src/utils/extentions.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../components/action_button.dart';

class CheckQrView extends StatefulHookConsumerWidget {
  const CheckQrView({super.key});

  @override
  ConsumerState<CheckQrView> createState() => _CheckQrViewState();
}

class _CheckQrViewState extends ConsumerState<CheckQrView>
    with WidgetsBindingObserver {
  MobileScannerController? controller;
  Barcode? _barcode;

  StreamSubscription<Object?>? _subscription;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the controller is not ready, do not try to start or stop it.
    // Permission dialogs can trigger lifecycle changes before the controller is ready.
    if (!controller!.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        // Restart the scanner when the app is resumed.
        print('scanner resumed');
        // Don't forget to resume listening to the barcode events.
        // _subscription = controller!.barcodes.listen(_handleBarcode);
        // controller.barcodes

        unawaited(controller!.start());
      case AppLifecycleState.inactive:
        // Stop the scanner when the app is paused.
        // Also stop the barcode events subscription.
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(controller!.stop());
    }
  }

  @override
  void initState() {
    log('init mobile scanner');

    controller = MobileScannerController(
      autoStart: false,
    );
    // Future.delayed(
    //   const Duration(milliseconds: 1000),
    //   () => controller!.start(),
    // );
    controller!.start();
    super.initState();
    // Start listening to lifecycle changes.
    WidgetsBinding.instance.addObserver(this);

    // Start listening to the barcode events.
    // _subscription = controller!.barcodes.listen(_handleBarcode);

    // Finally, start the scanner itself.
    // if (!controller.value.isInitialized) {
    log((!controller!.value.isInitialized).toString());
    // if (controller!.value.isInitialized) unawaited(controller!.start());
    // }
  }

  // void _handleBarcode(BarcodeCapture barcodes) {
  //   //barcodes.
  //   // if (ref.read(isScrolledProvider)) return;

  //   if (mounted) {
  //     setState(() {
  //       _barcode = barcodes.barcodes.firstOrNull;
  //     });
  //     ref
  //         .read(qrScanProvider.notifier)
  //         .handleQRCode(barcodes.barcodes.firstOrNull?.rawValue);
  //   }
  // }

  @override
  void didUpdateWidget(covariant CheckQrView oldWidget) {
    log('didUpdateWidget');
    setState(() {
      _barcode = null;
      // controller = MobileScannerController();
      controller!.stop();
      Future.delayed(
        const Duration(milliseconds: 1000),
        () => controller!.start(),
      );
      // controller.start();
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Future<void> dispose() async {
    // Stop listening to lifecycle changes.
    WidgetsBinding.instance.removeObserver(this);
    // // Stop listening to the barcode events.
    unawaited(_subscription?.cancel());
    _subscription = null;
    // // Dispose the widget itself.
    super.dispose();
    // // Finally, dispose of the controller.
    await controller!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final state = ref.watch(qrScanProvider);

    final torchEnabled = useState(false);
    controller?.addListener(() {
      torchEnabled.value = switch (controller!.value.torchState) {
        TorchState.on => true,
        _ => false,
      };
    });
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Spacer(),
            24.hGap,
            Center(
              child: ClipRRect(
                borderRadius: 16.cRadius,
                child: Container(
                  color: Colors.black,
                  width: context.width * .6,
                  height: context.width * .6,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: MobileScanner(
                          controller: controller,
                          placeholderBuilder: (context) => Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator.adaptive(),
                            ),
                          ),
                          errorBuilder:
                              (
                                context,
                                exception,
                              ) {
                                return const Text('err');
                              },
                        ),
                      ),
                      Container(
                        width: context.width * .65,
                        decoration: const BoxDecoration(
                          // color: Colors.white.withOpacity(.5),
                        ),
                        height: context.width * .65,
                        // clipBehavior: Clip.hardEdge,
                        // child: Center(
                        //   child: Lottie.asset(
                        //     'assets/lottiefiles/qr-bar.json',
                        //     width: context.width * .65,
                        //     height: context.width * .65,
                        //     errorBuilder: (context, error, stackTrace) =>
                        //         const SizedBox(),
                        //     // errorBuilder: (context, error, stackTrace) => Text(
                        //     //   error.toString(),
                        //     // ),
                        //   ),
                        // ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            16.hGap,
            ActionsButton(
              onPressed: () {
                controller?.toggleTorch();
              },
              backgroundColor: context.theme.primaryColor,
              icon: !torchEnabled.value ? Iconsax.flash_1 : Iconsax.flash_slash,

              //  AnimatedCrossFade(
              //   duration: Durations.long1,
              //   crossFadeState: !torchEnabled.value
              //       ? CrossFadeState.showFirst
              //       : CrossFadeState.showSecond,
              //   firstChild: const Icon(Iconsax.flash_1),
              //   secondChild: const Icon(Iconsax.flash_slash),
              // ),
            ),
            16.hGap,
            SizedBox(
              width: context.width * .6,
              child: Text(
                'وجه الكاميرا الى رمز الاستجابة السريع',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            16.hGap,
            TextButton.icon(
              icon: Icon(
                Iconsax.message_question,
                color: context.theme.colorScheme.secondary,
              ),
              onPressed: () {
                // showDialog(
                //   context: context,
                //   builder: (context) => const HowToUseDialog(),
                // );
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  context.theme.colorScheme.secondary.withValues(alpha: .2),
                ),
                foregroundColor: WidgetStatePropertyAll(
                  context.theme.colorScheme.secondary,
                ),
              ),
              label: const Text(
                'هل تعاني من مشكلة في القراءة؟',
              ),
            ),
            // Spacer(),
          ],
        ),
      ),
    );
  }
}
