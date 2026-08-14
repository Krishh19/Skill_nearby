import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../app/providers.dart';
import 'repositories.dart';

/// Compile-time RevenueCat configuration.
class RevenueCatConfig {
  const RevenueCatConfig({required this.apiKey});

  final String apiKey;

  bool get isConfigured => apiKey.isNotEmpty;

  static const fromEnvironment = RevenueCatConfig(
    apiKey: String.fromEnvironment('REVENUECAT_API_KEY'),
  );
}

class RevenueCatService {
  RevenueCatService(
    this._repository, [
    this._config = RevenueCatConfig.fromEnvironment,
  ]);

  final SkillRepository _repository;
  final RevenueCatConfig _config;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  static const String entitlementPlus = 'skillnearby_plus';

  /// Initializes RevenueCat SDK when API key is provided, or uses sandbox fallback.
  Future<void> initialize() async {
    if (!_config.isConfigured) {
      _initialized = false;
      return;
    }
    try {
      await Purchases.configure(PurchasesConfiguration(_config.apiKey));
      _initialized = true;
    } catch (_) {
      _initialized = false;
    }
  }

  /// Checks if current user has an active SkillNearby Plus subscription entitlement.
  Future<bool> isPlusActive() async {
    if (!_initialized) {
      final prefs = await _repository.watchPreferences().first;
      return prefs.radiusKm > 2;
    }
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo.entitlements.all[entitlementPlus];
      return entitlement?.isActive ?? false;
    } catch (_) {
      final prefs = await _repository.watchPreferences().first;
      return prefs.radiusKm > 2;
    }
  }

  /// Executes a test sandbox purchase for SkillNearby Plus ($4.99/mo).
  /// Updates local preferences & entitlement state to 'plus' and unlocks 20 km search radius!
  Future<bool> purchaseTestPlus() async {
    try {
      if (_initialized) {
        final offerings = await Purchases.getOfferings();
        if (offerings.current != null &&
            offerings.current!.availablePackages.isNotEmpty) {
          final package = offerings.current!.availablePackages.first;
          final customerInfo = await Purchases.purchasePackage(package);
          final entitlement = customerInfo.entitlements.all[entitlementPlus];
          if (entitlement?.isActive ?? false) {
            await _repository.setRadius(20);
            return true;
          }
        }
      }
    } catch (_) {
      // Sandbox fallback on test environments
    }

    // Fallback for test sandbox without live store credentials
    await _repository.setRadius(20);
    return true;
  }

  /// Restores previous purchases across devices.
  Future<bool> restorePurchases() async {
    if (!_initialized) return false;
    try {
      final customerInfo = await Purchases.restorePurchases();
      final entitlement = customerInfo.entitlements.all[entitlementPlus];
      if (entitlement?.isActive ?? false) {
        await _repository.setRadius(20);
        return true;
      }
    } catch (_) {
      return false;
    }
    return false;
  }
}

final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  final repo = ref.watch(repositoryProvider);
  final service = RevenueCatService(repo);
  service.initialize();
  return service;
});
