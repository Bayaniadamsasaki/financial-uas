import 'package:finalcial_records/shared/shared_methods.dart';
import 'package:finalcial_records/shared/shared_preferences.dart';
import 'package:finalcial_records/shared/theme.dart';
import 'package:finalcial_records/ui/widgets/profile_menu_item.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        leading: IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/menu');
            },
            icon: Icon(
              Icons.arrow_back,
              color: blackColor,
            )),
      ),
      body: Stack(
        children: [
          const _ProfileBackground(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
              children: [
                _buildProfileHeader(context),
                const SizedBox(height: 18),
                _buildSummarySection(),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: blackColor.withOpacity(0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pengaturan Akun',
                        style: blackTextStyle.copyWith(
                          fontSize: 16,
                          fontWeight: semiBold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ProfileMenuItem(
                        iconUrl: 'assets/user.png',
                        title: 'Pilih Avatar',
                        subTitle: 'Ubah',
                        onTap: () {
                          Navigator.pushNamed(context, '/avatar');
                        },
                      ),
                      FutureBuilder<int>(
                        future: SharedPrefUtils.readSaldo(),
                        builder: (context, snapshot) {
                          return ProfileMenuItem(
                            iconUrl: 'assets/money.png',
                            title: 'Saldo',
                            subTitle: formatCurrency(snapshot.data ?? 0),
                            tag: 1,
                          );
                        },
                      ),
                      FutureBuilder<String>(
                        future: SharedPrefUtils.readTanggalGabung(),
                        builder: (context, snapshot) {
                          return ProfileMenuItem(
                            iconUrl: 'assets/user.png',
                            title: 'Bergabung Sejak',
                            subTitle: (snapshot.data ?? '-').toString(),
                            tag: 0,
                          );
                        },
                      ),
                      ProfileMenuItem(
                        iconUrl: 'assets/logout.png',
                        title: 'Log out',
                        subTitle: 'Keluar',
                        onTap: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/sign-in', (route) => false);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff038EEA),
            Color(0xff28B3FF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: birulangit.withOpacity(0.28),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/avatar');
            },
            child: FutureBuilder<String>(
              future: SharedPrefUtils.readNameImage(),
              builder: (context, snapshot) {
                final String avatarName = (snapshot.data ?? '').toString();
                return Container(
                  width: 112,
                  height: 112,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: whiteColor,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: avatarName.isEmpty
                            ? const AssetImage('assets/image-1.png')
                            : AssetImage('assets/$avatarName.png'),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          FutureBuilder<String>(
            future: SharedPrefUtils.readNama(),
            builder: (context, snapshot) {
              final String userName =
                  (snapshot.data ?? '').toString().trim().isEmpty
                      ? 'Pengguna'
                      : snapshot.data.toString();

              return Text(
                userName,
                style: whiteTextStyle.copyWith(
                  fontSize: 22,
                  fontWeight: extraBold,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          FutureBuilder<String>(
            future: SharedPrefUtils.readEmail(),
            builder: (context, snapshot) {
              return Text(
                (snapshot.data ?? '-').toString(),
                style: whiteTextStyle.copyWith(
                  fontSize: 13,
                  color: whiteColor.withOpacity(0.9),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: whiteColor.withOpacity(0.18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.edit_outlined,
                  color: whiteColor,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Tap foto untuk ganti avatar',
                  style: whiteTextStyle.copyWith(
                    fontSize: 12,
                    fontWeight: medium,
                    color: whiteColor.withOpacity(0.95),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Row(
      children: [
        Expanded(
          child: FutureBuilder<int>(
            future: SharedPrefUtils.readSaldo(),
            builder: (context, snapshot) {
              return _summaryCard(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Saldo',
                value: formatCurrency(snapshot.data ?? 0),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FutureBuilder<String>(
            future: SharedPrefUtils.readTanggalGabung(),
            builder: (context, snapshot) {
              return _summaryCard(
                icon: Icons.event_available_rounded,
                title: 'Bergabung',
                value: (snapshot.data ?? '-').toString(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: whiteColor,
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: birulangit,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: greyTextStyle.copyWith(
              fontSize: 12,
              fontWeight: medium,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: blackTextStyle.copyWith(
              fontSize: 13,
              fontWeight: semiBold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ProfileBackground extends StatelessWidget {
  const _ProfileBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xffE8F6FF),
            lightBackgroundColor,
            whiteColor,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            left: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    birulangit.withOpacity(0.14),
                    birulangit.withOpacity(0.02),
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
