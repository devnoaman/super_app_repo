import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:super_app_manager/src/utils/extentions.dart';

class ActionsButton extends StatelessWidget {
  const ActionsButton({
    required this.icon,
    super.key,
    this.onPressed,
    this.backgroundColor,
  });
  final Color? backgroundColor;
  final IconData icon;
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      constraints: const BoxConstraints(maxWidth: 65, maxHeight: 65),
      shape: RoundedRectangleBorder(
        borderRadius: 65.cRadius,
      ),
      onPressed: onPressed,
      child: ClipRRect(
        borderRadius: 65.cRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 65,
            height: 65,

            decoration: BoxDecoration(
              // shape: BoxShape.circle,
              color:
                  backgroundColor?.withAlpha(60) ?? Colors.grey.withAlpha(50),
            ),
            child: Icon(
              icon,
            ),
          ),
        ),
      ),
    );
  }
}
