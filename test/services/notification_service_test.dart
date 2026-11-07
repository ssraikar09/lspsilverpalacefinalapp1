import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lsp_silver_app/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      NotificationService.hasNewBankDetails.value = false;
      NotificationService.hasNewCatalogUpdates.value = false;
      NotificationService.latestBankDetails = null;
    });

    tearDown(() {
      NotificationService.stopPolling();
    });

    test('value notifiers initialize with false default state', () {
      expect(NotificationService.hasNewBankDetails.value, isFalse);
      expect(NotificationService.hasNewCatalogUpdates.value, isFalse);
      expect(NotificationService.latestBankDetails, isNull);
    });

    test('markAsRead resets hasNewBankDetails and updates cached hash in SharedPreferences', () async {
      NotificationService.hasNewBankDetails.value = true;
      final testBankDetails = {
        'bank_name': 'HDFC Bank',
        'bank_account_name': 'Shri Laxmi Silver Palace',
        'bank_account': '50200012345678',
        'ifsc_code': 'HDFC0001234',
        'upi_id': 'shrilaxmi@upi',
      };
      NotificationService.latestBankDetails = testBankDetails;

      await NotificationService.markAsRead();

      expect(NotificationService.hasNewBankDetails.value, isFalse);

      final prefs = await SharedPreferences.getInstance();
      final cachedHash = prefs.getString('cached_bank_details_hash');
      expect(cachedHash, equals(jsonEncode(testBankDetails)));
    });

    test('stopPolling safely cancels active polling timer without errors', () {
      expect(() => NotificationService.stopPolling(), returnsNormally);
      expect(() => NotificationService.stopPolling(), returnsNormally); // repeated call
    });

    test('checkForUpdates catches external connection exceptions gracefully without uncaught errors', () async {
      // In unit test environment, Supabase.instance is uninitialized,
      // which throws an assertion/exception caught inside try-catch of checkForUpdates
      await expectLater(NotificationService.checkForUpdates(), completes);
    });
  });
}
