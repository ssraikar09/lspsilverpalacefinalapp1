import 'package:flutter/material.dart';
import '../../data/sample_data.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
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
          'ADMIN DASHBOARD',
          style: TextStyle(
            color: goldColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: goldColor),
            onPressed: () => Navigator.pushReplacementNamed(context, '/main'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatsGrid(context, darkGrey, goldColor),
              const SizedBox(height: 32),
              Text(
                'MANAGEMENT',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              _buildMenuCard(
                context,
                title: 'Products',
                subtitle: 'Manage catalogue products',
                icon: Icons.inventory_2_outlined,
                route: '/admin/products',
                darkGrey: darkGrey,
                goldColor: goldColor,
              ),
              _buildMenuCard(
                context,
                title: 'Categories',
                subtitle: 'Manage categories and subcategories',
                icon: Icons.category_outlined,
                route: '/admin/categories',
                darkGrey: darkGrey,
                goldColor: goldColor,
              ),
              _buildMenuCard(
                context,
                title: 'Business Details',
                subtitle: 'Manage bank details and contact info',
                icon: Icons.business_outlined,
                route: '/admin/business_details',
                darkGrey: darkGrey,
                goldColor: goldColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Color darkGrey, Color goldColor) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          context,
          title: 'Total Products',
          value: SampleData.products.length.toString(),
          icon: Icons.inventory_2,
          darkGrey: darkGrey,
          goldColor: goldColor,
        ),
        _buildStatCard(
          context,
          title: 'Categories',
          value: SampleData.categories.length.toString(),
          icon: Icons.category,
          darkGrey: darkGrey,
          goldColor: goldColor,
        ),
        _buildStatCard(
          context,
          title: 'Enquiries',
          value: '0', // Hardcoded per requirements
          icon: Icons.message,
          darkGrey: darkGrey,
          goldColor: goldColor,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color darkGrey,
    required Color goldColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: darkGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: goldColor, size: 28),
              const Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
    required Color darkGrey,
    required Color goldColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: darkGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: goldColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: goldColor),
        ),
        title: Text(
          title, 
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade600),
        onTap: () {
          Navigator.pushNamed(context, route).then((_) {
            setState(() {});
          });
        },
      ),
    );
  }
}
