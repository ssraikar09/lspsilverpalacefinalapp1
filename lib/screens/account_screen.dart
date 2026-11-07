import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../navigation/app_routes.dart';
import '../navigation/main_layout.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final String _mapUrl = 'https://maps.app.goo.gl/f1Aic1BQ7g5MCGm9A';
  Map<String, dynamic>? _businessDetailsCache;

  @override
  void initState() {
    super.initState();
    _fetchBusinessDetails();
  }

  Future<void> _fetchBusinessDetails() async {
    try {
      final data = await Supabase.instance.client.from('business_details').select().limit(1).maybeSingle();
      if (data != null && mounted) {
        setState(() {
          _businessDetailsCache = data;
        });
      }
    } catch (e) {
      // Fail silently, cache remains null
    }
  }

  Future<void> _launchPhone(BuildContext context) async {
    final phone = _businessDetailsCache?['shop_phone']?.toString() ?? '+919886855425';
    final url = Uri.parse('tel:$phone');
    final success = await launchUrl(url);
    if (!success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch Phone Dialer.')));
      }
    }
  }

  Future<void> _launchMapsUrl(BuildContext context) async {
    final url = Uri.parse(_mapUrl);
    final success = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch Maps.')));
      }
    }
  }

  void _showStoreLocation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161616),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Store Location', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Address:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Mahajan Complex, Opp. B. Mahendra New Killa, Durgadbail, HUBBALLI-20', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.map, size: 20),
                label: const Text('OPEN IN MAPS', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.pop(context);
                  _launchMapsUrl(context);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFFD4AF37))),
          ),
        ],
      ),
    );
  }

  void _showAboutUs(BuildContext context) {
    final phone = _businessDetailsCache?['shop_phone']?.toString() ?? '+919886855425';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161616),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('About Us', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Shri Laxmi Silver Palace', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Wholesale Dealers in All Silver Ornaments & Anticals', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 16),
            const Text('Address:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const Text('Mahajan Complex, Opp. B. Mahendra New Killa, Durgadbail, HUBBALLI-20', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            const Text('Contact:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            Text('WhatsApp / Call: $phone', style: const TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFFD4AF37))),
          ),
        ],
      ),
    );
  }

  void _showBankDetails(BuildContext context) {
    if (_businessDetailsCache == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Loading bank details, please try again in a moment...')));
      return;
    }

    final data = _businessDetailsCache!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161616),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Bank Details', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Bank Name', data['bank_name'], Icons.account_balance),
                _buildDetailRow('Account Name', data['bank_account_name'], Icons.person_outline),
                _buildDetailRow('Account Number', data['bank_account'], Icons.numbers),
                _buildDetailRow('IFSC Code', data['ifsc_code'], Icons.account_tree_outlined),
                _buildDetailRow('UPI ID', data['upi_id'], Icons.qr_code_2),
                if (data['bank_note'] != null && data['bank_note'].toString().isNotEmpty) ...[
                  const Divider(color: Colors.white24, height: 24),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFFD4AF37), size: 18),
                      const SizedBox(width: 8),
                      const Text('Note:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(data['bank_note'].toString(), style: const TextStyle(color: Colors.grey)),
                ]
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Color(0xFFD4AF37))),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, dynamic value, IconData icon) {
    if (value == null || value.toString().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value.toString(), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color goldColor = Color(0xFFD4AF37);
    const Color darkGrey = Color(0xFF161616);

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black,
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: goldColor, size: 24),
              onPressed: () => MainLayoutState.navigateToHome(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
              title: const Text(
                'My Account',
                style: TextStyle(
                  color: goldColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              background: Container(
                color: Colors.black,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0), // Adjust to center visually above the title
                    child: Image.asset(
                      'assets/images/lsp_logo_new.png',
                      height: 120, // slightly larger to look more impactful
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // MY CATALOG Section
                  Text(
                    'MY CATALOG',
                    style: TextStyle(
                      color: goldColor.withValues(alpha: 0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: darkGrey,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      children: [
                        _buildListTile(
                          icon: Icons.favorite_border,
                          title: 'Wishlist',
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.wishlist);
                          },
                        ),
                        Divider(height: 1, color: Colors.white.withValues(alpha: 0.05), indent: 16, endIndent: 16),
                        _buildListTile(
                          icon: Icons.history,
                          title: 'Recently Viewed',
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.recentlyViewed);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // STORE INFORMATION Section
                  Text(
                    'STORE INFORMATION',
                    style: TextStyle(
                      color: goldColor.withValues(alpha: 0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: darkGrey,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      children: [
                        _buildListTile(
                          icon: Icons.info_outline,
                          title: 'About Us',
                          onTap: () => _showAboutUs(context),
                        ),
                        Divider(height: 1, color: Colors.white.withValues(alpha: 0.05), indent: 16, endIndent: 16),
                        _buildListTile(
                          icon: Icons.account_balance_outlined,
                          title: 'Bank Details',
                          onTap: () => _showBankDetails(context),
                        ),
                        Divider(height: 1, color: Colors.white.withValues(alpha: 0.05), indent: 16, endIndent: 16),
                        _buildListTile(
                          icon: Icons.location_on_outlined,
                          title: 'Store Location',
                          onTap: () => _showStoreLocation(context),
                        ),
                        Divider(height: 1, color: Colors.white.withValues(alpha: 0.05), indent: 16, endIndent: 16),
                        _buildListTile(
                          icon: Icons.call_outlined,
                          title: 'Contact Us',
                          onTap: () => _launchPhone(context),
                        ),
                        Divider(height: 1, color: Colors.white.withValues(alpha: 0.05), indent: 16, endIndent: 16),
                        _buildListTile(
                          icon: Icons.admin_panel_settings_outlined,
                          title: 'Admin Access',
                          onTap: () => Navigator.pushNamed(context, AppRoutes.adminLogin),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({required IconData icon, required String title, required VoidCallback onTap}) {
    const Color goldColor = Color(0xFFD4AF37);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: goldColor.withValues(alpha: 0.7), size: 22),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey.shade600, size: 14),
      onTap: onTap,
    );
  }
}
