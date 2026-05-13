import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service to handle app permissions robustly across iOS and Android.
class PermissionService {
  /// Request photo library permission robustly for both iOS and Android.
  /// Handles iOS 14+ limited access gracefully.
  static Future<bool> requestPhotoPermission(BuildContext context) async {
    if (Platform.isIOS) {
      final status = await Permission.photos.request();
      // isLimited means the user selected "Select Photos" (partial access) on iOS 14+
      if (status.isGranted || status.isLimited) {
        return true;
      }

      if (status.isPermanentlyDenied) {
        if (context.mounted) _showSettingsDialog(context, 'Photo Library');
      }
      return false;
    } else {
      // Android: We request both since Android 13+ uses photos, and older uses storage.
      Map<Permission, PermissionStatus> statuses = await [
        Permission.photos,
        Permission.storage,
      ].request();

      final photosGranted = statuses[Permission.photos]?.isGranted ?? false;
      final storageGranted = statuses[Permission.storage]?.isGranted ?? false;

      if (photosGranted || storageGranted) {
        return true;
      }

      final photosDenied =
          statuses[Permission.photos]?.isPermanentlyDenied ?? false;
      final storageDenied =
          statuses[Permission.storage]?.isPermanentlyDenied ?? false;

      if (photosDenied || storageDenied) {
        if (context.mounted) _showSettingsDialog(context, 'Storage');
      }
      return false;
    }
  }

  /// Request camera permission
  static Future<bool> requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) _showSettingsDialog(context, 'Camera');
    }

    return false;
  }

  /// Shows a dialog directing the user to app settings
  static void _showSettingsDialog(BuildContext context, String permissionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permissionName Access Required'),
        content: Text(
          'This app needs $permissionName access to function properly. '
          'Please enable it in the app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }
}
