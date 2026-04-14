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
          bottom: 12,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: blueLightColor.withOpacity(0.45),
          border: Border.all(
            color: blueColor.withOpacity(0.22),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: whiteColor,
              ),
              child: Image.asset(
                iconUrl,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: blackTextStyle.copyWith(
                  fontWeight: medium,
                ),
              ),
            ),
            tag == 1
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: blueLightColor,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      subTitle,
                      style: blackTextStyle.copyWith(
                        color: birulangit,
                        fontWeight: semiBold,
                        fontSize: 12,
                      ),
                    ),
                  )
                : subTitle.isEmpty
                    ? const SizedBox()
                    : Text(
                        subTitle,
                        style: blackTextStyle.copyWith(
                          color: greyBlackColor,
                          fontWeight: medium,
                          fontSize: 13,
                        ),
                      ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: greyColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
