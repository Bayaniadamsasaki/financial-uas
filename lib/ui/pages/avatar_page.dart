import 'package:finalcial_records/shared/shared_preferences.dart';
import 'package:finalcial_records/shared/theme.dart';
import 'package:flutter/material.dart';

class AvatarPage extends StatelessWidget {
  const AvatarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Avatar'),
        leading: IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: Icon(
              Icons.arrow_back,
              color: blackColor,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 30,
            crossAxisSpacing: 30,
            childAspectRatio: 1,
          ),
          itemCount: 11,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                SharedPrefUtils.saveNameImage('image-${index + 1}');
                Navigator.pushNamed(context, '/profile');
              },
              child: Image.asset('assets/image-${index + 1}.png'),
            );
          },
        ),
      ),
    );
  }
}
