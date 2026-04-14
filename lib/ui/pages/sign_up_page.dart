import 'package:finalcial_records/shared/date_timenow.dart';
import 'package:finalcial_records/shared/shared_preferences.dart';
import 'package:finalcial_records/shared/snackbar.dart';
import 'package:finalcial_records/shared/theme.dart';
import 'package:finalcial_records/ui/widgets/buttons.dart';
import 'package:finalcial_records/ui/widgets/forms.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _namaController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _isPasswordHidden = true;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutCubic,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _entranceController.forward();
      }
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _register() {
    final String nama = _namaController.text.trim();
    final String email = _emailController.text.trim();
    final String pass = _passwordController.text.trim();

    if (nama.isEmpty || email.isEmpty || pass.isEmpty) {
      CustomSnackBar.showToast(context, 'Semua input wajib diisi!');
      return;
    }

    if (!email.contains('@')) {
      CustomSnackBar.showToast(context, 'Format email belum valid!');
      return;
    }

    if (pass.length < 6) {
      CustomSnackBar.showToast(context, 'Password minimal 6 karakter!');
      return;
    }

    SharedPrefUtils.saveNama(nama);
    SharedPrefUtils.saveEmail(email);
    SharedPrefUtils.savePassword(pass);
    SharedPrefUtils.saveTanggalGabung(DateTimeNow.now());

    CustomSnackBar.showToast(context, 'Berhasil simpan!');
    Navigator.pushNamed(context, '/sign-in');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _AuthBackground(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      children: [
                        const _AuthHeaderCard(
                          chipText: 'Financial Records',
                          title: 'Mulai Kebiasaan Finansial Sehat',
                          subtitle:
                              'Daftar akun baru dan atur keuangan harian kamu langsung dalam satu tempat.',
                          icon: Icons.account_balance_wallet_rounded,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Daftar Akun',
                          style: blackTextStyle.copyWith(
                            fontSize: 32,
                            fontWeight: extraBold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Buat akun untuk mulai catat pemasukan dan pengeluaran.',
                          style: greyTextStyle.copyWith(
                            fontSize: 14,
                            fontWeight: medium,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: whiteColor,
                            boxShadow: [
                              BoxShadow(
                                color: blackColor.withValues(alpha: 0.06),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomFormField(
                                title: 'Nama Lengkap',
                                hintText: 'Masukkan nama lengkap',
                                controller: _namaController,
                                prefixIcon: Icons.person_outline_rounded,
                              ),
                              const SizedBox(height: 14),
                              CustomFormField(
                                title: 'Alamat Email',
                                hintText: 'nama@email.com',
                                controller: _emailController,
                                inputType: TextInputType.emailAddress,
                                prefixIcon: Icons.alternate_email_rounded,
                              ),
                              const SizedBox(height: 14),
                              CustomFormField(
                                title: 'Password',
                                hintText: 'Minimal 6 karakter',
                                obscureText: _isPasswordHidden,
                                controller: _passwordController,
                                prefixIcon: Icons.lock_outline_rounded,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordHidden = !_isPasswordHidden;
                                    });
                                  },
                                  icon: Icon(
                                    _isPasswordHidden
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: greyColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Password minimal 6 karakter agar akun lebih aman.',
                                style: greyTextStyle.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 26),
                              CustomFillButton(
                                title: 'Daftar Sekarang',
                                height: 54,
                                onPressed: _register,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sudah punya akun?',
                              style: greyTextStyle.copyWith(
                                fontSize: 14,
                                fontWeight: medium,
                              ),
                            ),
                            const SizedBox(width: 4),
                            CustomTextButton(
                              width: 82,
                              title: 'Sign In',
                              onPressed: () {
                                Navigator.pushNamed(context, '/sign-in');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthHeaderCard extends StatelessWidget {
  const _AuthHeaderCard({
    required this.chipText,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String chipText;
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff038EEA),
            Color(0xff20B3FF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: birulangit.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: whiteColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  chipText,
                  style: whiteTextStyle.copyWith(
                    fontSize: 12,
                    fontWeight: semiBold,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: whiteColor.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: whiteColor,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: whiteTextStyle.copyWith(
              fontSize: 24,
              fontWeight: extraBold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: whiteTextStyle.copyWith(
              fontSize: 13,
              height: 1.45,
              fontWeight: medium,
              color: whiteColor.withValues(alpha: 0.95),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthBackground extends StatelessWidget {
  const _AuthBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xffE7F5FF),
            lightBackgroundColor,
            whiteColor,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -110,
            right: -85,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    birulangit.withValues(alpha: 0.18),
                    birulangit.withValues(alpha: 0.02),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 150,
            left: -110,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    blueColor.withValues(alpha: 0.14),
                    blueColor.withValues(alpha: 0.02),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -130,
            right: -90,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    greenColor.withValues(alpha: 0.13),
                    greenColor.withValues(alpha: 0.01),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

