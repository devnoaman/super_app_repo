import 'package:flutter/material.dart';
import 'package:super_app_manager/src/components/check_qr_view.dart';
import 'package:super_app_manager/src/utils/extentions.dart';

class ScannerViewDialog extends StatefulWidget {
  const ScannerViewDialog({super.key});

  @override
  State<ScannerViewDialog> createState() => _ScannerViewDialogState();
}

class _ScannerViewDialogState extends State<ScannerViewDialog> {
  @override
  Widget build(BuildContext context) {
    // var tr = AppLocalizations.of(context);
    // final pageController = usePageController();
    // final permissions = ref.watch(permissionsProvider);

    return SizedBox(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: CloseButton(),
          ),
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              Expanded(
                child: QrHandleScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
