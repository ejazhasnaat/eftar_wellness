// lib/core/dev/reset_utils.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:eftar_wellness/app/di/db_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dev helper to reset local app state.
class ResetUtils {
  /// Close Drift DB, delete DB file, and clear SharedPreferences.
  /// Accepts [WidgetRef] to match usage from ConsumerWidget build methods.
  static Future<void> resetAll(WidgetRef ref) async {
    await Future.wait([
      deleteDb(ref),
      clearPrefs(),
    ]);
  }

  /// Delete only the DB file. Safe if DB was never opened.
  static Future<void> deleteDb(WidgetRef ref) async {
    try {
      // Try to close if open
      try {
        final db = ref.read(dbProvider);
        await db.close();
      } catch (_) {}
      final docs = await getApplicationDocumentsDirectory();
      final sep = Platform.pathSeparator;
      final dbFile = File('${docs.path}${sep}eftar.db');
      if (await dbFile.exists()) {
        await dbFile.delete();
      }
    } catch (e, st) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('ResetUtils.deleteDb error: $e');
        print(st);
      }
    }
  }

  /// Clear only SharedPreferences.
  static Future<void> clearPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e, st) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('ResetUtils.clearPrefs error: $e');
        print(st);
      }
    }
  }
}
