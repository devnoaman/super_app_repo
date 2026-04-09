// The screen now takes the MiniApp as a parameter.

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:super_app_manager/super_app_manager.dart';

class UnAuthrizedMiniAppScreen extends StatelessWidget {
  const UnAuthrizedMiniAppScreen({super.key, required this.miniApp});
  final MiniAppEntity miniApp;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.lock),

          const Center(
            child: Text(
              "عذرا ",
            ),
          ),
          const Center(
            child: Text(
              "لا يمكن تشغيل هذا التطبيق في الوقت الحالي ",
            ),
          ),
          const Center(
            child: Text(
              "حاول مجددا في وقت لاحق",
            ),
          ),

          // application information
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text('الاصدار الحالي'),
                  subtitle: Text(miniApp.version),
                ),
                ListTile(
                  title: Text('الاصدار المطلوب'),
                  subtitle: Text(miniApp.requiredVersion),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            label: Text("ارسال بلاغ"),
          ),
        ],
      ),
    );
  }
}
