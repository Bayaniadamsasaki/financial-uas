import 'package:finalcial_records/shared/theme.dart';
import 'package:flutter/material.dart';

class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    super.key,
    required this.iconUrl,
    required this.title,
    this.subTitle = '',
    this.tag = 0,
    this.onTap,
  });

  final String iconUrl;
  final String title;
  final String subTitle;
  final int tag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 30,
        ),
        child: Row(
          children: [
            Image.asset(
              iconUrl,
              width: 24,
            ),
            const SizedBox(
              width: 18,
            ),
            Text(
              title,
              style: blackTextStyle.copyWith(
                fontWeight: medium,
              ),
            ),
            const Spacer(),
            tag == 1
                ? Container(
                    width: 90,
                    height: 20,
                    decoration: BoxDecoration(
                      color: purpleLight2Color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        subTitle,
                        style: blackTextStyle.copyWith(
                          color: purpleColor,
                          fontWeight: semiBold,
                        ),
                      ),
                    ),
                  )
                : Text(
                    subTitle,
                    style: blackTextStyle.copyWith(
                      fontWeight: medium,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
