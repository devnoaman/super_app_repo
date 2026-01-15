// import 'package:shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:super_app_manager/super_app_manager.dart';
import 'package:super_app_mobile/features/home/domain/entities/mini_app.dart';

// This is a FAKE implementation for demonstration.
// In a real app, this would make an HTTP request to your server.
class HomeRepositoryImpl implements IHomeRepository {
  @override
  Future<List<MiniAppEntity>> getAvailableMiniApps() async {
    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 1));

    return [
      MiniAppEntity(
        id: 'profile_editor',
        name: 'Profile Editor',
        version: '1.0.0',
        requiredVersion: '1.0.0',
        logoUrl:
            'https://eu.ui-avatars.com/api/?name=Medical+Regulator&size=250',
        description: 'Edit your profile and update your photo.',
        url: "http://localhost:55414/",
        primaryColor: Colors.teal,
        requiredPermissions: ['camera', 'storage', 'scan', 'location', 'uri'],
        apiKey: 'super-secret-key-123',
      ),
      MiniAppEntity(
        id: 'Inspector',
        version: '1.0.0',
        requiredVersion: '1.0.0',
        name: 'Inspector app',
        logoUrl: 'https://eu.ui-avatars.com/api/?name=Inspector+App&size=250',
        description: 'Edit your profile and update your photo.',
        url: 'https://uofapp.web.app', // The URL we were using before
        primaryColor: const Color.fromARGB(255, 231, 224, 42),
        requiredPermissions: ['camera', 'storage'],
        apiKey: 'super-secret-key-123',
      ),
    ];
  }
}
