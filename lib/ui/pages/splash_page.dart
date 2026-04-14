import 'dart:async';
import 'dart:math' as math;

import 'package:finalcial_records/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _ambientController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  Timer? _nextPageTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _fadeAnimation = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.07),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: Curves.easeOutCubic,
      ),
    );

    _introController.forward();

    _nextPageTimer = Timer(
      const Duration(milliseconds: 2800),
      _goToSignIn,
    );
  }

  void _goToSignIn() {
    if (!mounted || _hasNavigated) {
      return;
    }

    _hasNavigated = true;
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/sign-in',
      (route) => false,
    );
  }

  @override
  void dispose() {
    _nextPageTimer?.cancel();
    _introController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _goToSignIn,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _ambientController,
          builder: (context, _) {
            final double t = _ambientController.value;
            final double wave = math.sin(t * 2 * math.pi);
            final double pulse = 1 + (math.sin(t * 2 * math.pi) * 0.03);
            final double tapHintOpacity = 0.55 + (wave.abs() * 0.45);

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xffE7F6FF),
                    lightBackgroundColor,
                    whiteColor,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -90 + (wave * 16),
                    right: -80,
                    child: _SplashBlurOrb(
                      size: 260,
                      colors: [
                        birulangit.withValues(alpha: 0.2),
                        birulangit.withValues(alpha: 0.02),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: -110 - (wave * 14),
                    left: -70,
                    child: _SplashBlurOrb(
                      size: 250,
                      colors: [
                        greenColor.withValues(alpha: 0.16),
                        greenColor.withValues(alpha: 0.01),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 180 + (wave * 10),
                    left: -110,
                    child: _SplashBlurOrb(
                      size: 220,
                      colors: [
                        blueColor.withValues(alpha: 0.13),
                        blueColor.withValues(alpha: 0.01),
                      ],
                    ),
                  ),
                  Center(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 28),
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                whiteColor,
                                const Color(0xffF7FCFF),
                              ],
                            ),
                            border: Border.all(
                              color: blueColor.withValues(alpha: 0.15),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: blackColor.withValues(alpha: 0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: blueLightColor,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  'PERSONAL FINANCE TRACKER',
                                  style: blueTextStyle.copyWith(
                                    fontSize: 10,
                                    letterSpacing: 0.55,
                                    fontWeight: semiBold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Transform.scale(
                                scale: pulse,
                                child: Transform.translate(
                                  offset: Offset(0, wave * 3),
                                  child: Container(
                                    width: 112,
                                    height: 112,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          birulangit.withValues(alpha: 0.2),
                                          birulangit.withValues(alpha: 0.08),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: birulangit.withValues(alpha: 0.2),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: birulangit.withValues(alpha: 0.18),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: SvgPicture.asset(
                                      'assets/dollar_sky.svg',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Financial Records',
                                style: blackTextStyle.copyWith(
                                  fontSize: 27,
                                  fontWeight: extraBold,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Lacak pemasukan dan pengeluaran dengan cara yang lebih cerdas.',
                                textAlign: TextAlign.center,
                                style: greyBlackTextStyle.copyWith(
                                  fontSize: 13,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Opacity(
                                opacity: tapHintOpacity.clamp(0, 1),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.touch_app_rounded,
                                      size: 16,
                                      color: birulangit,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Tap untuk mulai',
                                      style: blueTextStyle.copyWith(
                                        fontSize: 12,
                                        fontWeight: semiBold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SplashBlurOrb extends StatelessWidget {
  const _SplashBlurOrb({
    required this.size,
    required this.colors,
  });

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}
