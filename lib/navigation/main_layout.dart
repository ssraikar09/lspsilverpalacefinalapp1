import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/wishlist_screen.dart';
import '../screens/account_screen.dart';
import '../services/visual_search_service.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CategoriesScreen(),
    WishlistScreen(),
    AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Delay preheating Visual Search so it doesn't block startup or affect the splash screen
    VisualSearchService().preheat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1.0),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: Theme.of(context).colorScheme.secondary,
          unselectedItemColor: Colors.grey.withValues(alpha: 0.6),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5),
          unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 1.0),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.home_outlined, size: 22)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.home, size: 24)),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.grid_view_outlined, size: 22)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.grid_view_rounded, size: 24)),
              label: 'CATEGORIES',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.favorite_border, size: 22)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.favorite, size: 24)),
              label: 'WISHLIST',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.person_outline, size: 22)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.person, size: 24)),
              label: 'ACCOUNT',
            ),
          ],
        ),
      ),
    );
  }
}
