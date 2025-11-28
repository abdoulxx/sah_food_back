import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Service pour gérer les micro-interactions (haptic feedback, vibrations)
class ServiceInteractions {
  /// Vibration légère pour les actions simples (tap, selection)
  static Future<void> vibrationLegere() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(duration: 10);
      } else {
        // Fallback sur haptic feedback du système
        await HapticFeedback.lightImpact();
      }
    } catch (e) {
      // Fallback sur haptic feedback si vibration échoue
      await HapticFeedback.lightImpact();
    }
  }

  /// Vibration moyenne pour les actions importantes (validation, succès)
  static Future<void> vibrationMoyenne() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(duration: 50);
      } else {
        await HapticFeedback.mediumImpact();
      }
    } catch (e) {
      await HapticFeedback.mediumImpact();
    }
  }

  /// Vibration forte pour les événements majeurs (succès important, achievement)
  static Future<void> vibrationForte() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(duration: 100);
      } else {
        await HapticFeedback.heavyImpact();
      }
    } catch (e) {
      await HapticFeedback.heavyImpact();
    }
  }

  /// Pattern de vibration pour succès (double tap)
  static Future<void> vibrationSucces() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(
          pattern: [0, 50, 50, 50], // vibration, pause, vibration
        );
      } else {
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.mediumImpact();
      }
    } catch (e) {
      await HapticFeedback.mediumImpact();
    }
  }

  /// Pattern de vibration pour erreur (triple tap rapide)
  static Future<void> vibrationErreur() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(
          pattern: [0, 30, 30, 30, 30, 30], // 3 courtes vibrations
        );
      } else {
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 50));
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 50));
        await HapticFeedback.lightImpact();
      }
    } catch (e) {
      await HapticFeedback.lightImpact();
    }
  }

  /// Haptic feedback de sélection (iOS style)
  static Future<void> selectionChanged() async {
    await HapticFeedback.selectionClick();
  }
}
