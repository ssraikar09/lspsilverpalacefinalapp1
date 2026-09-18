import 'package:flutter/material.dart';
import '../navigation/app_routes.dart';
import '../state/auth_state.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  
  late Animation<double> _logoLSPReveal;
  late Animation<double> _ornamentScale;
  late Animation<double> _screenFadeOut;

  @override
  void initState() {
    super.initState();
    globalAuthState.loginAsGuest();
    
    // Main timeline ~5.5 seconds for the full cinematic effect
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5500),
    );

    // 1. Logo L-S-P reveal (Left to Right sweep)
    _logoLSPReveal = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.20, curve: Curves.easeInOut)),
    );

    // Ornament scales from center
    _ornamentScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.55, 0.65, curve: Curves.easeOutBack)),
    );

    // Final screen fade out before navigation
    _screenFadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.9, 1.0, curve: Curves.easeOut)),
    );

    _mainController.forward().then((_) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(), 
          ),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color luxuryGold = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _screenFadeOut,
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                
                // 1. REAL LSP LOGO - Premium Sweep Reveal
                AnimatedBuilder(
                  animation: _mainController,
                  builder: (context, child) {
                    // Combine scale and sweep for a highly attractive entrance
                    return Transform.scale(
                      scale: 0.9 + (_logoLSPReveal.value * 0.1), // Scales from 0.9 to 1.0
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          widthFactor: _logoLSPReveal.value, // Sweeps from left to right
                          child: Image.asset(
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
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                
                // 2. BRAND NAME BELOW LOGO (Vertically stacked, Word by Word)
                WordByWordReveal(
                  text: 'Shri',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w500,
                    color: luxuryGold,
                    fontSize: 22,
                  ),
                  initialDelay: const Duration(milliseconds: 1600),
                ),
                const SizedBox(height: 4),
                WordByWordReveal(
                  text: 'Laxmi Silver',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                    color: luxuryGold,
                    fontSize: 28,
                  ),
                  initialDelay: const Duration(milliseconds: 2000),
                ),
                const SizedBox(height: 4),
                WordByWordReveal(
                  text: 'Palace',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w500,
                    color: luxuryGold,
                    fontSize: 22,
                  ),
                  initialDelay: const Duration(milliseconds: 2600),
                ),
                
                const SizedBox(height: 24),
                
                // 3. GOLD ORNAMENT (Scaling)
                ScaleTransition(
                  scale: _ornamentScale,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 45, height: 1.0, color: luxuryGold),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_left, size: 16, color: luxuryGold),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.0),
                        child: Icon(Icons.diamond_outlined, size: 10, color: luxuryGold),
                      ),
                      const Icon(Icons.chevron_right, size: 16, color: luxuryGold),
                      const SizedBox(width: 4),
                      Container(width: 45, height: 1.0, color: luxuryGold),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 4. TAGLINE (Word by Word with movement)
                WordByWordReveal(
                  text: 'Wholesale Dealers in',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    letterSpacing: 1.0,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  initialDelay: const Duration(milliseconds: 3200),
                ),
                const SizedBox(height: 6),
                WordByWordReveal(
                  text: 'All Silver Ornaments',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    letterSpacing: 1.0,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  initialDelay: const Duration(milliseconds: 3800),
                ),
                const SizedBox(height: 6),
                WordByWordReveal(
                  text: '& Articals',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    letterSpacing: 1.0,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  initialDelay: const Duration(milliseconds: 4300),
                ),
                
                const Spacer(flex: 3),
                
                // 5. LOADING INDICATOR
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.0,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD81B60)),
                  ),
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WordByWordReveal extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration initialDelay;

  const WordByWordReveal({
    Key? key,
    required this.text,
    this.style,
    required this.initialDelay,
  }) : super(key: key);

  @override
  State<WordByWordReveal> createState() => _WordByWordRevealState();
}

class _WordByWordRevealState extends State<WordByWordReveal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<String> words = [];

  @override
  void initState() {
    super.initState();
    words = widget.text.split(' ');
    
    // 300ms per word delay + 500ms duration for the individual word animation
    int totalDuration = (words.length * 300) + 500;
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: totalDuration));
    Future.delayed(widget.initialDelay, () {
      if (mounted) _controller.forward();
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> wordWidgets = [];
    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      
      double start = (i * 300.0) / _controller.duration!.inMilliseconds;
      double end = start + (500.0 / _controller.duration!.inMilliseconds);
      if (end > 1.0) end = 1.0;

      Animation<double> opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.easeIn)),
      );
      // Upward movement
      Animation<Offset> offset = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.easeOutCubic)),
      );

      wordWidgets.add(
        FadeTransition(
          opacity: opacity,
          child: SlideTransition(
            position: offset,
            child: Text(word, style: widget.style),
          ),
        ),
      );
      
      // Add space between words
      if (i < words.length - 1) {
        wordWidgets.add(Text(' ', style: widget.style));
      }
    }

    return Wrap(
      alignment: WrapAlignment.center,
      children: wordWidgets,
    );
  }
}
