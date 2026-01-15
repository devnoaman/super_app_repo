import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'
    hide NumDurationExtensions;
import 'package:flutter_hooks/flutter_hooks.dart';

// import 'package:gudea/views/scanner/provider/scanner_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:super_app_manager/src/components/action_button.dart';
import 'package:super_app_manager/src/utils/extentions.dart';

class QrHandleScreen extends HookConsumerWidget {
  const QrHandleScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(child: const CheckQrView());
  }
}

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
        _subscription = controller!.barcodes.listen(_handleBarcode);
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
    log('iniyt');

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
    _subscription = controller!.barcodes.listen(_handleBarcode);

    // Finally, start the scanner itself.
    // if (!controller.value.isInitialized) {
    log((!controller!.value.isInitialized).toString());
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    //barcodes.
    // if (ref.read(isScrolledProvider)) return;

    if (mounted) {
      setState(() {
        _barcode = barcodes.barcodes.firstOrNull;
      });
      // pop the scanned value
      // context.pop();
      Navigator.of(context).pop(barcodes.barcodes.firstOrNull?.rawValue);
      // ref
      //     .read(qrScanProvider.notifier)
      //     .handleQRCode(barcodes.barcodes.firstOrNull?.rawValue);
    }
  }

  @override
  void didUpdateWidget(covariant CheckQrView oldWidget) {
    log('didUpdateWidget');
    setState(() {
      _barcode = null;
      controller!.stop();

      // if(controller.)
      Future.delayed(
        const Duration(milliseconds: 1000),
        () {
          if (mounted &&
              controller != null &&
              controller!.value.isInitialized) {
            controller?.start();
          }
        },
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
    final dialogController = useAnimationController();
    // final permissionDenied =
    //     ref.watch(permissionsProvider).locationGranted == false;
    final torchEnabled = useState(false);
    controller?.addListener(() {
      torchEnabled.value = switch (controller!.value.torchState) {
        TorchState.on => true,
        _ => false,
      };
    });

    // var permissions = ref.watch(permissionsProvider);
    // var permissionsRef = ref.read(permissionsProvider.notifier);

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // if (permissionDenied)
            //   Padding(
            //         padding: const EdgeInsets.all(8),
            //         child: RawMaterialButton(
            //           fillColor: const Color(0xff3BC982),
            //           clipBehavior: Clip.hardEdge,
            //           // fillColor: Color(0xff8B5DFF),

            //           // fillColor: context.theme.cardTheme.color,
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(24),
            //           ),
            //           onPressed: () async {
            //             // const cameraPermissionStatus =await Permission.camera.;
            //             // final cameraGranted = permissions.cameraGranted;
            //             // await context.push(
            //             //   PermissionPage.route,
            //             // );
            //             // if (cameraGranted == false) {
            //             //   // await cameraPermissionStatus.request();
            //             //   // await openAppSettings();
            //             //   var res = await context.push(
            //             //     PermissionPage.route,
            //             //   );

            //             //   if (permissions.cameraGranted) {
            //             //     context.replace('/scanner');
            //             //   }
            //             // } else {
            //             //   var st = await permissionsRef.requestPermission(
            //             //     Permission.camera,
            //             //     tr?.permissionName(tr.camera) ??
            //             //         'Camera Permission',
            //             //   );
            //             //   if (st) {
            //             //     if (context.mounted) {
            //             //       context.replace('/scanner');
            //             //     }
            //             //   }
            //             // }

            //             // if (status.isDenied) {
            //             //   await Permission.camera.request().then((
            //             //     onValue,
            //             //   ) {
            //             //     if (onValue.isGranted) {
            //             //       if (context.mounted) {
            //             //         context.replace('/scanner');
            //             //       }
            //             //     }
            //             //   });
            //             // }

            //             // if (status.isGranted) {
            //             //   if (context.mounted) {
            //             //     context.replace('/scanner');
            //             //   }
            //             // }
            //           },
            //           child: SizedBox(
            //             width: context.width,
            //             height: context.height * .15,
            //             child: Stack(
            //               children: [
            //                 // const PositionedDirectional(
            //                 //   top: -16,
            //                 //   start: -16,
            //                 //   child: CircleShape(),
            //                 // ),
            //                 // const PositionedDirectional(
            //                 //   end: -16,
            //                 //   bottom: -16,
            //                 //   child: CircleShape(),
            //                 // ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                   children: [
            //                     Expanded(
            //                       child: Padding(
            //                         padding: const EdgeInsets.all(8),
            //                         child: Column(
            //                           crossAxisAlignment:
            //                               CrossAxisAlignment.start,
            //                           mainAxisAlignment:
            //                               MainAxisAlignment.spaceAround,
            //                           children: [
            //                             Text(
            //                               'tr!.locationAccessPrompt',
            //                               style: context.textTheme.bodyMedium!
            //                                   .copyWith(
            //                                     fontWeight: FontWeight.bold,
            //                                   ),
            //                               maxLines: 2,
            //                               overflow: TextOverflow.ellipsis,
            //                             ),
            //                             Container(
            //                               decoration: BoxDecoration(
            //                                 color: const Color(
            //                                   0xffFFF7D1,
            //                                 ),
            //                                 borderRadius: BorderRadius.circular(
            //                                   24,
            //                                 ),
            //                               ),
            //                               child: Padding(
            //                                 padding: const EdgeInsets.all(
            //                                   8,
            //                                 ),
            //                                 child: Text(
            //                                   tr.requestPermission,
            //                                   style: context
            //                                       .textTheme
            //                                       .bodyMedium!
            //                                       .copyWith(
            //                                         fontWeight: FontWeight.bold,
            //                                         color: const Color(
            //                                           0xff3BC982,
            //                                         ),
            //                                       ),
            //                                 ),
            //                               ),
            //                             ),
            //                           ],
            //                         ),
            //                       ),
            //                     ),
            //                     // Spacer(),
            //                     Padding(
            //                       padding: const EdgeInsets.all(8),
            //                       child: CircleAvatar(
            //                         radius: 45,
            //                         child: Padding(
            //                           padding: const EdgeInsets.all(8),
            //                           child: Lottie.asset(
            //                             'assets/lottiefiles/camera.json',
            //                           ),

            //                           // Icon(
            //                           //   Icons.qr_code,
            //                           //   size: 65,
            //                           //   color: Color(0xffFFF7D1),
            //                           // ),
            //                         ),
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ),
            //       )
            //       .animate(
            //         controller: dialogController,
            //         delay: Durations.medium4,
            //         onComplete: (controller) {
            //           if (dialogController.isCompleted) {
            //             Future.delayed(Durations.medium4).then((_) {
            //               dialogController.reverse();
            //             });
            //           } else {
            //             Future.delayed(Durations.medium4).then((_) {
            //               dialogController.forward();
            //             });
            //           }
            //         },
            //         // onComplete: (controller) async {
            //         //   // Future.delayed(500.ms).then((_) {
            //         //   //   controller.repeat();
            //         //   // });
            //         //   await Future.delayed(1.seconds).then((_) {
            //         //     controller.repeat();
            //         //   });
            //         // },
            //       )
            //       .shake()
            // else
            //   const SizedBox.shrink(),
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
                        child: Center(
                          child: Lottie.asset(
                            'assets/lottiefiles/qr-bar.json',
                            width: context.width * .65,
                            height: context.width * .65,
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox(),
                            // errorBuilder: (context, error, stackTrace) => Text(
                            //   error.toString(),
                            // ),
                          ),
                        ),
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
            ),
            16.hGap,
            SizedBox(
              width: context.width * .6,
              child: Text(
                'وجه الكاميرا الى رمز الاستجابة السريع ',
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
              label: Text(
                // 'هل تعاني من مشكلة في القراءة؟',
                'كيفية استخدام الماسح',
              ),
            ),
            // Spacer(),
          ],
        ),
      ),

      // child: switch (state) {
      //   Initial() =>,

      //   Loading() => const SizedBox(
      //     child: Center(
      //       child: CircularProgressIndicator.adaptive(),
      //     ),
      //   ),

      //   Loaded() => const SizedBox(),

      //   Error() => SizedBox(
      //     width: context.width,
      //     height: context.height * .8,
      //     child: ListView(
      //       padding: 16.8.symetric,
      //       children: [
      //         Lottie.asset(
      //           'assets/lottiefiles/qr-error.json',
      //           width: context.width * .5,
      //         ),
      //         Text(
      //           state.e.toString(),
      //           textAlign: TextAlign.center,
      //           style: context.textTheme.bodyLarge,
      //         ),
      //         16.hGap,
      //         Padding(
      //           padding: const EdgeInsets.all(8),
      //           child: RawMaterialButton(
      //             fillColor: context.theme.primaryColor,
      //             elevation: 0,
      //             constraints: BoxConstraints(
      //               minWidth: context.width,
      //               minHeight: 55,
      //             ),
      //             shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(24),
      //             ),
      //             onPressed: () {
      //               // setState(() {
      //               _barcode = null;
      //               ref.read(qrScanProvider.notifier).scanNew();
      //               // controller?.;
      //               // });
      //               setState(() {});
      //             },
      //             child: Text(
      //               'مسح جديد',
      //               style: context.textTheme.bodyLarge!.copyWith(
      //                 color: Colors.white,
      //               ),
      //             ),
      //           ),
      //         ),
      //         // if (type == ErrorType.wrongQr)
      //         //   Image.asset('assets/images/label.png'),
      //       ],
      //     ),
      //   ),
      // },
    );
  }
}
