// T044: SocialLoginButtons widget for Google and Apple sign-in buttons

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import '../theme/app_theme_config.dart';

/// Social login buttons for Google and Apple Sign In
class SocialLoginButtons extends StatelessWidget {
  final VoidCallback? onGoogleSignIn;
  final VoidCallback? onAppleSignIn;
  final bool isLoading;
  final bool showGoogle;
  final bool showApple;

  const SocialLoginButtons({
    super.key,
    this.onGoogleSignIn,
    this.onAppleSignIn,
    this.isLoading = false,
    this.showGoogle = true,
    this.showApple = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveShowApple = showApple && Platform.isIOS;

    return Column(
      children: [
        if (showGoogle)
          _SocialButton(
            text: 'Continue with Google',
            onPressed: isLoading ? null : onGoogleSignIn,
            icon: Icons.g_mobiledata, // Placeholder, use actual Google icon asset
            backgroundColor: Colors.white,
            textColor: Colors.black87,
          ),
        if (showGoogle && effectiveShowApple) const SizedBox(height: 12),
        if (effectiveShowApple)
          _SocialButton(
            text: 'Continue with Apple',
            onPressed: isLoading ? null : onAppleSignIn,
            icon: Icons.apple,
            backgroundColor: Colors.black,
            textColor: Colors.white,
          ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;

  const _SocialButton({
    required this.text,
    this.onPressed,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemeConfig.borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: textColor),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
