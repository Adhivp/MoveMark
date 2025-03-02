import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:movemark/main.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );

    // Start the animation
    _controller.forward();

    // Navigate to main screen after splash
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AttendanceDashboard()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textAnimation =
        _buildTextAnimation6(); // Change number (1-6) to try different animations

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1A237E)
                  : const Color(0xFF2196F3),
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF0D47A1)
                  : const Color(0xFF1976D2),
            ],
            stops: const [0.4, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            ...List.generate(
              20,
              (index) => Positioned(
                left: index * 20.0,
                top: index * 30.0,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        20 * _controller.value * (index % 2 == 0 ? 1 : -1),
                      ),
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with animations
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 15,
                                    spreadRadius: 5,
                                    offset: const Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.1),
                                    blurRadius: 20,
                                    spreadRadius: -5,
                                    offset: const Offset(0, -8),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/Logo.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  // Text animation (changeable)
                  textAnimation,
                  const SizedBox(height: 20),
                  // Subtitle with fade animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Walk In, Get Marked. Effortless Attendance with Gait',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Text Animation Option 1: Wavy
  Widget _buildTextAnimation1() {
    return DefaultTextStyle(
      style: GoogleFonts.poppins(
        fontSize: 44,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 2,
      ),
      child: AnimatedTextKit(
        animatedTexts: [
          WavyAnimatedText(
            'MoveMark',
            speed: const Duration(milliseconds: 200),
          ),
        ],
        isRepeatingAnimation: false,
      ),
    );
  }

  // Text Animation Option 2: Flicker
  Widget _buildTextAnimation2() {
    return DefaultTextStyle(
      style: GoogleFonts.poppins(
        fontSize: 44,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 2,
      ),
      child: AnimatedTextKit(
        animatedTexts: [
          FlickerAnimatedText(
            'MoveMark',
            speed: const Duration(milliseconds: 2000),
            entryEnd: 0.7,
          ),
        ],
        isRepeatingAnimation: false,
      ),
    );
  }

  // Text Animation Option 3: Scale and Fade
  Widget _buildTextAnimation3() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.5 + (value * 0.5),
            child: Text(
              'MoveMark',
              style: GoogleFonts.poppins(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3 * value),
                    offset: Offset(0, 4 * value),
                    blurRadius: 10 * value,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Text Animation Option 4: Colorful Reveal
  Widget _buildTextAnimation4() {
    return DefaultTextStyle(
      style: GoogleFonts.poppins(
        fontSize: 44,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
      child: AnimatedTextKit(
        animatedTexts: [
          ColorizeAnimatedText(
            'MoveMark',
            speed: const Duration(milliseconds: 2000),
            colors: [
              Colors.white,
              Colors.blue,
              Colors.lightBlueAccent,
              Colors.white,
            ],
            textStyle: GoogleFonts.poppins(
              fontSize: 44,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
        isRepeatingAnimation: false,
      ),
    );
  }

  // Text Animation Option 5: Typing
  Widget _buildTextAnimation5() {
    return DefaultTextStyle(
      style: GoogleFonts.poppins(
        fontSize: 44,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 2,
      ),
      child: AnimatedTextKit(
        animatedTexts: [
          TyperAnimatedText(
            'MoveMark',
            speed: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          ),
        ],
        isRepeatingAnimation: false,
      ),
    );
  }

  // Text Animation Option 6: Letter-by-letter Fade
  Widget _buildTextAnimation6() {
    final text = 'MoveMark';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        text.length,
        (index) => TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 500 + (index * 200)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Text(
                  text[index],
                  style: GoogleFonts.poppins(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
