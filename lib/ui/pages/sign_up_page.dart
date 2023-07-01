import 'package:finalcial_records/shared/date_timenow.dart';
import 'package:finalcial_records/shared/shared_preferences.dart';
import 'package:finalcial_records/shared/snackbar.dart';
import 'package:finalcial_records/shared/theme.dart';
import 'package:finalcial_records/ui/widgets/buttons.dart';
import 'package:finalcial_records/ui/widgets/forms.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  void register(
    BuildContext ctx,
    String nama,
    String email,
    String pass,
  ) {
    SharedPrefUtils.saveNama(nama);
    SharedPrefUtils.saveEmail(email);
    SharedPrefUtils.savePassword(pass);
    SharedPrefUtils.saveTanggalGabung(DateTimeNow.now());

    CustomSnackBar.showToast(ctx, 'Berhasil simpan!');
    Navigator.pushNamed(ctx, '/sign-in');
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController namaCotroller = TextEditingController();
    final TextEditingController emailCotroller = TextEditingController();
    final TextEditingController passwordCotroller = TextEditingController();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          Container(
            width: 155,
            height: 80,
            margin: const EdgeInsets.only(
              top: 70,
              bottom: 80,
            ),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/financial_records.JPG'),
              ),
            ),
          ),
          Text(
            'Buat akun anda',
            style: blackTextStyle.copyWith(
              fontSize: 18,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), color: whiteColor),
            child: Column(
              children: [
                CustomFormField(
                  title: 'Nama',
                  controller: namaCotroller,
                ),
                const SizedBox(
                  height: 8,
                ),
                CustomFormField(
                  title: 'Alamat Email',
                  controller: emailCotroller,
                ),
                const SizedBox(
                  height: 8,
                ),
                CustomFormField(
                  title: 'Password',
                  obscureText: true,
                  controller: passwordCotroller,
                ),
                const SizedBox(
                  height: 38,
                ),
                CustomFillButton(
                  title: 'Register',
                  onPressed: () {
                    register(
                      context,
                      namaCotroller.text,
                      emailCotroller.text,
                      passwordCotroller.text,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          CustomTextButton(
            title: 'Sign In',
            onPressed: () {
              Navigator.pushNamed(context, '/sign-in');
            },
          )
        ],
      ),
    );
  }
}