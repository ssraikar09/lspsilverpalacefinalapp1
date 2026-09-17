import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final ValueNotifier<bool> hasNewBankDetails = ValueNotifier(false);
  static final ValueNotifier<bool> hasNewCatalogUpdates = ValueNotifier(false);
  static Map<String, dynamic>? latestBankDetails;
  static Timer? _pollingTimer;

  static void startPolling() {
    if (_pollingTimer != null) return;
    checkForUpdates(); // initial check
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      checkForUpdates();
    });
  }

  static void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  static Future<void> checkForUpdates() async {
    try {
      final response = await Supabase.instance.client
          .from('business_details')
          .select()
          .limit(1)
          .maybeSingle();

      if (response != null) {
        // We only care about bank-related fields
        final bankDetails = {
          'bank_name': response['bank_name']?.toString() ?? '',
          'bank_account_name': response['bank_account_name']?.toString() ?? '',
          'bank_account': response['bank_account']?.toString() ?? '',
          'ifsc_code': response['ifsc_code']?.toString() ?? '',
          'upi_id': response['upi_id']?.toString() ?? '',
        };

        // Compute a simple hash/string of current details
        final currentHash = jsonEncode(bankDetails);
        
        final prefs = await SharedPreferences.getInstance();
        final cachedHash = prefs.getString('cached_bank_details_hash');

        if (cachedHash != null && cachedHash != currentHash) {
          hasNewBankDetails.value = true;
          latestBankDetails = bankDetails;
        } else if (cachedHash == null) {
          await prefs.setString('cached_bank_details_hash', currentHash);
        }
      }

      // Check for catalog updates (products & categories)
      final productResponse = await Supabase.instance.client
          .from('products')
          .select('id')
          .order('id', ascending: true);
          
      final categoryResponse = await Supabase.instance.client
          .from('categories')
          .select('id')
          .order('id', ascending: true);
          
      if (productResponse.isNotEmpty || categoryResponse.isNotEmpty) {
        final currentCatalogHash = jsonEncode({'products': productResponse, 'categories': categoryResponse});
        final prefs = await SharedPreferences.getInstance();
        final cachedCatalogHash = prefs.getString('cached_catalog_hash');

        if (cachedCatalogHash != null && cachedCatalogHash != currentCatalogHash) {
          hasNewCatalogUpdates.value = true;
        } else if (cachedCatalogHash == null) {
          await prefs.setString('cached_catalog_hash', currentCatalogHash);
        }
      }

    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }

  static Future<void> markAsRead() async {
    hasNewBankDetails.value = false;
    if (latestBankDetails != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_bank_details_hash', jsonEncode(latestBankDetails));
    }
  }

  static Future<void> markCatalogAsRead() async {
    hasNewCatalogUpdates.value = false;
    final productResponse = await Supabase.instance.client
          .from('products')
          .select('id')
          .order('id', ascending: true);
    final categoryResponse = await Supabase.instance.client
          .from('categories')
          .select('id')
          .order('id', ascending: true);
    final currentCatalogHash = jsonEncode({'products': productResponse, 'categories': categoryResponse});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_catalog_hash', currentCatalogHash);
  }
}
