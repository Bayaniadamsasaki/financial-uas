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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(
            height: 30,
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 22,
            ),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/avatar');
                  },
                  child: FutureBuilder(
                    future: SharedPrefUtils.readNameImage(),
                    builder: (context, snapshot) {
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: snapshot.data == null
                                ? const AssetImage('assets/image-1.png')
                                : AssetImage(
                                    'assets/${snapshot.data}.png',
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                FutureBuilder(
                  future: SharedPrefUtils.readNama(),
                  builder: (context, snapshot) {
                    return Text(
                      '${snapshot.data}',
                      style: blackTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: medium,
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 5,
                ),
                FutureBuilder(
                  future: SharedPrefUtils.readEmail(),
                  builder: (context, snapshot) {
                    return Text(
                      '${snapshot.data}',
                      style: blackTextStyle.copyWith(
                        fontSize: 15,
                        color: greyColor,
                        fontWeight: medium,
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 40,
                ),
                FutureBuilder(
                  future: SharedPrefUtils.readSaldo(),
                  builder: (context, snapshot) {
                    return ProfileMenuItem(
                      iconUrl: 'assets/money.png',
                      title: 'Saldo',
                      subTitle: snapshot.data.toString(),
                      tag: 1,
                    );
                  },
                ),
                FutureBuilder(
                  future: SharedPrefUtils.readTanggalGabung(),
                  builder: (context, snapshot) {
                    return ProfileMenuItem(
                      iconUrl: 'assets/user.png',
                      title: 'Bergabung Sejak',
                      subTitle: snapshot.data.toString(),
                      tag: 0,
                    );
                  },
                ),
                ProfileMenuItem(
                  iconUrl: 'assets/logout.png',
                  title: 'Log out',
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/sign-in', (route) => false);
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
