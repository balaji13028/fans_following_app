import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

class LegalAcceptanceText extends StatelessWidget {
  final String action;

  const LegalAcceptanceText({
    super.key,
    required this.action,
  });

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    const baseStyle = TextStyle(
      color: Colors.white54,
      fontSize: 12,
      height: 1.5,
    );
    const linkStyle = TextStyle(
      color: AppColors.primary,
      fontSize: 12,
      height: 1.5,
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('By $action, you agree to our ', style: baseStyle),
          GestureDetector(
            onTap: () => _launchUrl(AppConstants.termsAndConditionsUrl),
            child: const Text('Terms & Conditions', style: linkStyle),
          ),
          const Text(' and ', style: baseStyle),
          GestureDetector(
            onTap: () => _launchUrl(AppConstants.privacyPolicyUrl),
            child: const Text('Privacy Policy', style: linkStyle),
          ),
          const Text('.', style: baseStyle),
        ],
      ),
    );
  }
}
