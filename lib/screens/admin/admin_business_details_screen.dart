import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/notification_service.dart';

class AdminBusinessDetailsScreen extends StatefulWidget {
  const AdminBusinessDetailsScreen({super.key});

  @override
  State<AdminBusinessDetailsScreen> createState() => _AdminBusinessDetailsScreenState();
}

class _AdminBusinessDetailsScreenState extends State<AdminBusinessDetailsScreen> {
  final _bankNameController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _upiIdController = TextEditingController();
  final _bankNoteController = TextEditingController();
  final _shopPhoneController = TextEditingController();
  final _shopWhatsAppController = TextEditingController();

  dynamic _detailsId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('business_details')
          .select()
          .limit(1)
          .maybeSingle();

      if (response != null) {
        _detailsId = response['id'];
        setState(() {
          _bankNameController.text = response['bank_name']?.toString() ?? '';
          _accountNameController.text = response['bank_account_name']?.toString() ?? '';
          _accountNumberController.text = response['bank_account']?.toString() ?? '';
          _ifscController.text = response['ifsc_code']?.toString() ?? '';
          _upiIdController.text = response['upi_id']?.toString() ?? '';
          _bankNoteController.text = response['bank_note']?.toString() ?? '';
          _shopPhoneController.text = response['shop_phone']?.toString() ?? '';
          _shopWhatsAppController.text = response['shop_whatsapp']?.toString() ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load details: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveDetails() async {
    setState(() {
      _isLoading = true;
    });

    final data = {
      'bank_name': _bankNameController.text,
      'bank_account_name': _accountNameController.text,
      'bank_account': _accountNumberController.text,
      'ifsc_code': _ifscController.text,
      'upi_id': _upiIdController.text,
      'bank_note': _bankNoteController.text,
      'shop_phone': _shopPhoneController.text,
      'shop_whatsapp': _shopWhatsAppController.text,
    };

    try {
      if (_detailsId != null) {
        // Update existing record
        await Supabase.instance.client
            .from('business_details')
            .update(data)
            .eq('id', _detailsId!);
      } else {
        // Insert new record with an explicit fixed UUID
        final insertData = {
          ...data,
          'id': '00000000-0000-0000-0000-000000000001',
        };
        await Supabase.instance.client
            .from('business_details')
            .insert(insertData);
      }

      // Sync customer-facing details to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('shop_phone', _shopPhoneController.text);
      await prefs.setString('shop_whatsapp', _shopWhatsAppController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Details saved successfully!'), backgroundColor: Colors.green),
        );
      }
      
      // Instantly trigger check so the admin sees the notification icon light up (for testing)
      NotificationService.checkForUpdates();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save details: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _upiIdController.dispose();
    _bankNoteController.dispose();
    _shopPhoneController.dispose();
    _shopWhatsAppController.dispose();
    super.dispose();
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false, int maxLines = 1}) {
    const Color goldColor = Color(0xFFD4AF37);
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: goldColor),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color goldColor = Color(0xFFD4AF37);
    const Color darkGrey = Color(0xFF161616);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: goldColor),
        title: const Text(
          'BUSINESS DETAILS',
          style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, letterSpacing: 1.0, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: goldColor))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: darkGrey,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Shop Contact Details', style: TextStyle(color: goldColor, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        _buildTextField(_shopPhoneController, 'Shop Phone Number', isNumber: true),
                        const SizedBox(height: 16),
                        _buildTextField(_shopWhatsAppController, 'Shop WhatsApp Number', isNumber: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: darkGrey,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Bank Details', style: TextStyle(color: goldColor, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        _buildTextField(_bankNameController, 'Bank Name'),
                        const SizedBox(height: 16),
                        _buildTextField(_accountNameController, 'Account Name'),
                        const SizedBox(height: 16),
                        _buildTextField(_accountNumberController, 'Account Number'),
                        const SizedBox(height: 16),
                        _buildTextField(_ifscController, 'IFSC Code'),
                        const SizedBox(height: 16),
                        _buildTextField(_upiIdController, 'UPI ID'),
                        const SizedBox(height: 16),
                        _buildTextField(_bankNoteController, 'Bank Note', maxLines: 2),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goldColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _saveDetails,
                    child: const Text('SAVE DETAILS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
