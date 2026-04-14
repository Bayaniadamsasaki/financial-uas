import 'package:finalcial_records/shared/theme.dart';
import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  const CustomFormField({
    super.key,
    required this.title,
    this.obscureText = false,
    this.controller,
    this.isShowTitle = true,
    this.onTap,
    this.readOnly = false,
    this.inputType = TextInputType.name,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.maxLines = 1,
  });

  final String title;
  final bool obscureText;
  final TextEditingController? controller;
  final bool isShowTitle;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextInputType inputType;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isShowTitle)
          Text(
            title,
            style: blackTextStyle.copyWith(
              fontWeight: medium,
            ),
          ),
        if (isShowTitle)
          const SizedBox(
            height: 8,
          ),
        TextFormField(
          obscureText: obscureText,
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          maxLines: obscureText ? 1 : maxLines,
          keyboardType: inputType,
          decoration: InputDecoration(
            hintText: hintText ?? (!isShowTitle ? title : null),
            hintStyle: greyTextStyle.copyWith(
              fontWeight: regular,
              fontSize: 14,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    size: 20,
                    color: greyBlackColor.withOpacity(0.75),
                  )
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: blueLightColor.withOpacity(0.35),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: blueColor.withOpacity(0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: blueColor.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: birulangit,
                width: 1.4,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
