import 'package:flutter/material.dart';
import 'package:finalcial_records/shared/theme.dart';

enum ToastType { info, success, warning, error }

class CustomSnackBar {
  static void showToast(
    BuildContext ctx,
    String msg, {
    ToastType type = ToastType.info,
  }) {
    final _ToastStyle style = _resolveToastStyle(type);
    final scaffold = ScaffoldMessenger.of(ctx);
    scaffold
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 22),
          backgroundColor: Colors.transparent,
          duration: const Duration(seconds: 2),
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: style.gradient,
              ),
              boxShadow: [
                BoxShadow(
                  color: style.gradient.first.withOpacity(0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  style.icon,
                  color: style.foregroundColor,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    msg,
                    style: whiteTextStyle.copyWith(
                      fontWeight: semiBold,
                      color: style.foregroundColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  static Future<bool> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Lanjutkan',
    String cancelLabel = 'Batal',
    IconData icon = Icons.help_outline_rounded,
    Color? accentColor,
  }) async {
    final Color activeAccent = accentColor ?? birulangit;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: blackColor.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activeAccent.withOpacity(0.12),
                  ),
                  child: Icon(
                    icon,
                    color: activeAccent,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: blackTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: semiBold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: greyBlackTextStyle.copyWith(
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext, false);
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          side: BorderSide(
                            color: blueColor.withOpacity(0.35),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          cancelLabel,
                          style: greyBlackTextStyle.copyWith(
                            fontWeight: semiBold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext, true);
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          backgroundColor: activeAccent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          confirmLabel,
                          style: whiteTextStyle.copyWith(
                            fontWeight: semiBold,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );

    return confirm ?? false;
  }

  static _ToastStyle _resolveToastStyle(ToastType type) {
    switch (type) {
      case ToastType.success:
        return _ToastStyle(
          icon: Icons.check_circle_outline_rounded,
          gradient: const [Color(0xff0D9F73), Color(0xff26C28D)],
          foregroundColor: whiteColor,
        );
      case ToastType.warning:
        return _ToastStyle(
          icon: Icons.warning_amber_rounded,
          gradient: const [Color(0xffF09B0C), Color(0xffF5B638)],
          foregroundColor: whiteColor,
        );
      case ToastType.error:
        return _ToastStyle(
          icon: Icons.error_outline_rounded,
          gradient: const [Color(0xffD9476C), Color(0xffEE5A7A)],
          foregroundColor: whiteColor,
        );
      case ToastType.info:
        return _ToastStyle(
          icon: Icons.info_outline_rounded,
          gradient: const [Color(0xff038EEA), Color(0xff20B3FF)],
          foregroundColor: whiteColor,
        );
    }
  }
}

class _ToastStyle {
  const _ToastStyle({
    required this.icon,
    required this.gradient,
    required this.foregroundColor,
  });

  final IconData icon;
  final List<Color> gradient;
  final Color foregroundColor;
}
