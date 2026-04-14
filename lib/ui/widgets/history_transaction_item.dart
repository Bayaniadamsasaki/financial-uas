import 'package:finalcial_records/shared/theme.dart';
import 'package:flutter/material.dart';

class HistoryTransactionItem extends StatelessWidget {
  const HistoryTransactionItem({
    super.key,
    required this.iconUrl,
    required this.title,
    required this.date,
    required this.value,
    this.note,
    this.onDelete,
  });

  final String iconUrl;
  final String title;
  final String date;
  final String value;
  final String? note;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final bool isIncome = value.trim().startsWith('+');

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: blueLightColor.withValues(alpha: 0.42),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: whiteColor,
            ),
            child: Image.asset(
              iconUrl,
              width: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: blackTextStyle.copyWith(
                    fontSize: 15,
                    fontWeight: medium,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  date,
                  style: greyTextStyle.copyWith(
                    fontSize: 12,
                    fontWeight: regular,
                  ),
                ),
                if ((note ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    note!,
                    style: greyBlackTextStyle.copyWith(
                      fontSize: 12,
                      color: greyBlackColor.withValues(alpha: 0.86),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: blackTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: semiBold,
                  color: isIncome ? greenColor : readColor,
                ),
              ),
              if (onDelete != null) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(99),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      color: readColor.withValues(alpha: 0.1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 14,
                          color: readColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Hapus',
                          style: blackTextStyle.copyWith(
                            fontSize: 11,
                            fontWeight: semiBold,
                            color: readColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          )
        ],
      ),
    );
  }
}

