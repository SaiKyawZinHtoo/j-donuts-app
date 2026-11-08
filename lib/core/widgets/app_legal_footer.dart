part of '../core_import.dart';

/// Shared "By continuing..." sentence with tappable Terms of Use / Privacy
/// Policy spans, shown at the bottom of every auth screen per the reference
/// design.
class AppLegalFooter extends StatelessWidget {
  const AppLegalFooter({super.key, required this.onTapTerms, required this.onTapPrivacy});

  final VoidCallback onTapTerms;
  final VoidCallback onTapPrivacy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notice = l10n.termsPrivacyNotice;
    final termsOfUse = l10n.termsOfUse;
    final privacyPolicy = l10n.privacyPolicy;
    final linkStyle = AppTextStyles.caption.copyWith(color: AppColors.primary);

    final spans = <InlineSpan>[];
    var remaining = notice;
    for (final (label, onTap) in [
      (termsOfUse, onTapTerms),
      (privacyPolicy, onTapPrivacy),
    ]) {
      final index = remaining.indexOf(label);
      if (index == -1) {
        spans.add(TextSpan(text: remaining));
        remaining = '';
        break;
      }
      spans.add(TextSpan(text: remaining.substring(0, index)));
      spans.add(
        TextSpan(
          text: label,
          style: linkStyle,
          recognizer: TapGestureRecognizer()..onTap = onTap,
        ),
      );
      remaining = remaining.substring(index + label.length);
    }
    if (remaining.isNotEmpty) spans.add(TextSpan(text: remaining));

    return Text.rich(
      TextSpan(style: AppTextStyles.caption, children: spans),
      textAlign: TextAlign.center,
    );
  }
}
