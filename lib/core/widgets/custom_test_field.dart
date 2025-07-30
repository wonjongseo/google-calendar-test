// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomTestField extends StatelessWidget {
  const CustomTestField({
    super.key,
    this.onTap,
    this.onChanged,
    this.onFieldSubmitted,
    this.controller,
    this.maxLines,
    this.hintText,
    this.labelText,
    this.suffixIcon,
    this.widget,
    this.obscureText,
    this.autofocus,
    this.readOnly,
    this.color,
    this.width,
    this.borderRadius,
    this.textInputAction,
    this.height,
    this.fontSize,
  });

  final Function()? onTap;
  final Function(String?)? onChanged;
  final Function(String?)? onFieldSubmitted;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final double? borderRadius;
  final double? fontSize;
  final int? maxLines;
  final String? hintText;
  final String? labelText;
  final Widget? suffixIcon;
  final Widget? widget;
  final bool? obscureText;
  final bool? autofocus;
  final bool? readOnly;
  final double? width;
  final double? height;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(borderRadius ?? 10),
        color: color ?? (Get.isDarkMode ? null : Colors.white),
      ),
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                readOnly: readOnly ?? false,
                onTap: onTap,
                autofocus: autofocus ?? false,
                maxLines: maxLines ?? 1,
                onChanged: onChanged,
                controller: controller,

                style: TextStyle(fontSize: fontSize ?? 12),
                onFieldSubmitted: onFieldSubmitted,
                obscureText: obscureText ?? false,
                textInputAction: textInputAction ?? TextInputAction.next,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  labelText: labelText,
                  hintText: hintText,
                  disabledBorder: customInputDecoration,
                  focusedBorder: customInputDecoration,
                  enabledBorder: customInputDecoration,
                  suffixIcon: suffixIcon,
                ),
              ),
            ),
            if (widget != null) widget!,
          ],
        ),
      ),
    );
  }

  InputBorder get customInputDecoration {
    return const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.all(Radius.circular(20)),
    );
  }
}
