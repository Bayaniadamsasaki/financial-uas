import 'dart:async';

import 'package:finalcial_records/shared/theme.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.84,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();

    Timer(
      const Duration(milliseconds: 2300),
      () {
        if (!mounted) {
          return;
        }
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/sign-in',
          (route) => false,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              top: -80,
              right: -70,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      birulangit.withOpacity(0.22),
                      birulangit.withOpacity(0.03),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -90,
              left: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      greenColor.withOpacity(0.17),
                      greenColor.withOpacity(0.02),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 28),
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          whiteColor,
                          const Color(0xffF7FCFF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: blueColor.withOpacity(0.15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: blackColor.withOpacity(0.08),
                          blurRadius: 22,
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
                            borderRadius: BorderRadius.circular(99),
                            color: blueLightColor,
                          ),
                          child: Text(
                            'PERSONAL FINANCE TRACKER',
                            style: blueTextStyle.copyWith(
                              fontSize: 10,
                              letterSpacing: 0.5,
                              fontWeight: semiBold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        ScaleTransition(
                          scale: _logoScaleAnimation,
                          child: Container(
                            width: 98,
                            height: 98,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  birulangit.withOpacity(0.2),
                                  birulangit.withOpacity(0.08),
                                ],
                              ),
                              border: Border.all(
                                color: birulangit.withOpacity(0.2),
                              ),
                            ),
                            child: const Image(
                              image: AssetImage('assets/money.png'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Financial Records',
                          style: blackTextStyle.copyWith(
                            fontSize: 24,
                            fontWeight: extraBold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Merapikan pemasukan dan pengeluaranmu setiap hari.',
                          textAlign: TextAlign.center,
                          style: greyBlackTextStyle.copyWith(
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: 180,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              minHeight: 7,
                              backgroundColor: blueLightColor,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                birulangit,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Menyiapkan dashboard kamu...',
                          style: greyTextStyle.copyWith(
                            fontSize: 12,
                            fontWeight: medium,
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
      ),
    );
  }
}
