// import 'package:shared/shared.dart';
import 'dart:io';

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
        id: 'أحداث',
        name: 'أحداث',
        version: '1.0.0',
        requiredVersion: '1.0.0',
        logoUrl: 'https://eu.ui-avatars.com/api/?name=Gudea+Events&size=250',
        description: 'احداث متنوعة تقدمها لكم Gudea',
        url: Platform.isAndroid
            ? "http://10.0.2.2:55414/"
            : "http://localhost:55414/",
        primaryColor: Color(0xff007A3D),
        requiredPermissions: [
          'camera',
          'storage',
          'scan',
          'location',
          'uri',
          'fileSave',
          'share',
        ],
        apiKey: 'apiKey',
        // apiKey: 'super-secret-key-123',
      ),
      MiniAppEntity(
        id: 'احداث ويب',
        name: 'أحداث',
        version: '1.0.0',
        requiredVersion: '1.0.0',
        logoUrl: 'https://eu.ui-avatars.com/api/?name=Gudea+Events&size=250',
        description: 'احداث متنوعة تقدمها لكم Gudea',
        url: "https://emenu-1e0da.web.app",
        primaryColor: Color(0xff007A3D),
        requiredPermissions: [
          'camera',
          'storage',
          'scan',
          'location',
          'uri',
          'fileSave',
          'share',
        ],
        apiKey: 'apiKey',
        // apiKey: 'super-secret-key-123',
      ),
      MiniAppEntity(
        id: 'Dummy Mini App',
        version: '1.0.0',
        requiredVersion: '1.0.0',
        name: 'Dummy Mini App',
        logoUrl: 'https://eu.ui-avatars.com/api/?name=Dummy+Mini+App&size=250',
        description: 'A dummy mini app for demonstration purposes.',
        url: 'https://uofapp.web.app', // The URL we were using before
        primaryColor: const Color.fromARGB(255, 231, 224, 42),
        requiredPermissions: [
          'camera',
          'storage',
          'scan',
          'location',
          'uri',
          'fileSave',
          'share',
        ],
        // apiKey: 'super-secret-key-123',
        apiKey: 'apiKey',
      ),
    ];
  }
}
