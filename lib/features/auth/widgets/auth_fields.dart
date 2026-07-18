import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../domain/validators.dart';
import 'auth_widgets.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.label,
    this.icon,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.suffixIcon,
    this.autofillHints,
    this.focusNode,
    this.onFieldSubmitted,
    this.inputFormatters,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
  });

  final String hint;
  final TextEditingController controller;

  final String? label;
  final IconData? icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final List<String>? autofillHints;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      autofillHints: autofillHints,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      enabled: enabled,
      onFieldSubmitted: onFieldSubmitted,
      style: AppTextStyles.bodyLarge,
      cursorColor: AppColors.primary,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon == null
            ? null
            : Icon(icon, size: 20, color: AppColors.textSecondary),
        suffixIcon: suffixIcon,
      ).applyDefaults(AuthStyles.inputTheme),
    );

    if (label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_FieldLabel(label!), const SizedBox(height: 8), field],
    );
  }
}

// just a text field for dial code, not a picker — most users are Rwandan
class PhoneNumberField extends StatelessWidget {
  const PhoneNumberField({
    super.key,
    required this.dialCodeController,
    required this.numberController,
    this.onFieldSubmitted,
    this.enabled = true,
  });

  final TextEditingController dialCodeController;
  final TextEditingController numberController;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Phone Number'),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 96,
              child: TextFormField(
                controller: dialCodeController,
                validator: Validators.dialCode,
                keyboardType: TextInputType.phone,
                enabled: enabled,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                cursorColor: AppColors.primary,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[+\d]')),
                  LengthLimitingTextInputFormatter(5),
                ],
                decoration: const InputDecoration(
                  hintText: '+250',
                ).applyDefaults(AuthStyles.inputTheme),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AuthTextField(
                hint: '078 000 0000',
                icon: Icons.phone_iphone_outlined,
                controller: numberController,
                validator: Validators.phone,
                keyboardType: TextInputType.phone,
                enabled: enabled,
                onFieldSubmitted: onFieldSubmitted,
                autofillHints: const [AutofillHints.telephoneNumberLocal],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(14),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PasswordVisibilityToggle extends StatelessWidget {
  const PasswordVisibilityToggle({
    super.key,
    required this.obscured,
    required this.onPressed,
  });

  final bool obscured;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      iconSize: 20,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      tooltip: obscured ? 'Show password' : 'Hide password',
      icon: Icon(
        obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.textSecondary,
      ),
    );
  }
}

// one hidden field behind drawn boxes, not N separate ones —
// that way paste and SMS auto-fill actually work
class OtpInput extends StatelessWidget {
  const OtpInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.length,
    this.onCompleted,
    this.hasError = false,
    this.enabled = true,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;
  final ValueChanged<String>? onCompleted;
  final bool hasError;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListenableBuilder(
          listenable: Listenable.merge([controller, focusNode]),
          builder: (context, _) {
            final text = controller.text;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(length, (i) {
                return Padding(
                  padding: EdgeInsets.only(right: i == length - 1 ? 0 : 8),
                  child: _OtpBox(
                    digit: i < text.length ? text[i] : null,
                    isActive: focusNode.hasFocus && i == text.length,
                    hasError: hasError,
                  ),
                );
              }),
            );
          },
        ),
        Positioned.fill(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.oneTimeCode],
            enableInteractiveSelection: false,
            showCursor: false,
            maxLength: length,
            style: const TextStyle(color: Colors.transparent, height: 0.01),
            // gotta clear all border states, default ones leak through
            // and paint a filled rect over the digit boxes
            decoration: const InputDecoration(
              counterText: '',
              filled: false,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(length),
            ],
            onChanged: (value) {
              if (value.length == length) onCompleted?.call(value);
            },
          ),
        ),
      ],
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.digit,
    required this.isActive,
    required this.hasError,
  });

  final String? digit;
  final bool isActive;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final filled = digit != null;
    final borderColor = hasError
        ? AppColors.error
        : (filled || isActive ? AppColors.primary : AppColors.inputBorder);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? AppColors.tertiary : AppColors.inputFill,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: filled ? 1.5 : 1),
      ),
      child: filled
          ? Text(
              digit!,
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primary,
              ),
            )
          : Container(width: 12, height: 2, color: AppColors.tertiaryDark),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTextStyles.titleSmall);
}
