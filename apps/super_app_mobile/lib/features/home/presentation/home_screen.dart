import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shared/shared.dart';
import 'package:super_app_manager/super_app_manager.dart';
import 'package:super_app_mobile/features/home/providers/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider to get the async state (loading, data, error)
    final miniAppsAsyncValue = ref.watch(miniAppsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Super App Home')),

      body: miniAppsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (apps) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: apps.length,
                  itemBuilder: (context, index) {
                    final miniApp = apps[index];
                    return MiniAppEntityCard(miniApp: miniApp);
                  },
                ),
              ),
            ],
          );
        },
      ),
      // body: Padding(
      //   padding: const EdgeInsets.all(8.0),
      //   child: Wrap(
      //     spacing: 8,
      //     children: [
      //       ElevatedButton(
      //         onPressed: () async {
      //           var img = await AppOperations.openCamera();
      //           print(img);
      //         },
      //         child: Text(
      //           'open camera',
      //         ),
      //       ),
      //       ElevatedButton(onPressed: () {}, child: Text('data')),
      //     ],
      //   ),
      // ),
    );
  }
}

class MiniAppEntityCard extends StatelessWidget {
  const MiniAppEntityCard({super.key, required this.miniApp});
  final MiniAppEntity miniApp;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      color: miniApp.primaryColor.withOpacity(0.1),
      elevation: 0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: miniApp.primaryColor,
          backgroundImage: NetworkImage(miniApp.logoUrl),
        ),
        title: Text(
          miniApp.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(miniApp.description),
        onTap: () {
          // Navigate to the host screen, passing the selected mini-app.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MiniAppHostScreen(
                miniApp: miniApp,
                hostScreenType: HostScreenType.fullScreen,
              ),
            ),
          );
        },
      ),
    );
  }
}
