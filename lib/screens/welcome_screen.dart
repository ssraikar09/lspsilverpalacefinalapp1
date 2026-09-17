import 'package:flutter/material.dart';
import '../navigation/app_routes.dart';
import '../state/auth_state.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    // Start as guest silently
    globalAuthState.loginAsGuest();
    
    // Splash screen timer
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Elegant luxury gold color for text and ornaments
    const Color luxuryGold = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: Colors.black, // PURE BLACK BACKGROUND
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // 1. REAL LSP LOGO
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOut,
                builder: (context, double opacity, child) {
                  return Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: 0.95 + (0.05 * opacity),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/lsp_logo.png',
                      height: 190,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Text(
                        'LSP',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: luxuryGold,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // 2. BRAND NAME BELOW LOGO (Gold appearance)
                    Text(
                      'Shri',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w500,
                        color: luxuryGold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Laxmi Silver',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                        color: luxuryGold,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Palace',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w500,
                        color: luxuryGold,
                        fontSize: 22,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 3. GOLD ORNAMENT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 45,
                          height: 1.0,
                          color: luxuryGold,
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_left,
                          size: 16,
                          color: luxuryGold,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.0),
                          child: Icon(
                            Icons.diamond_outlined,
                            size: 10,
                            color: luxuryGold,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: luxuryGold,
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 45,
                          height: 1.0,
                          color: luxuryGold,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 4. TAGLINE
                    Text(
                      'Wholesale Dealers in',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        letterSpacing: 1.0,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'All Silver Ornaments',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        letterSpacing: 1.0,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '& Articals',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        letterSpacing: 1.0,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(flex: 3),
              
              // 5. LOADING INDICATOR
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD81B60)), // Deep pink from logo
                ),
              ),
              const SizedBox(height: 64),
            ],
          ),
        ),
      ),
    );
  }
}
