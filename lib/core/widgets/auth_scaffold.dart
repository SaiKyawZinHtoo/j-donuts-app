part of '../core_import.dart';

/// Shared chrome for auth screens: gradient, header (back/trailing), scrolling
/// body and a legal footer that hides while the keyboard is open.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    this.showBack = true,
    this.trailing,
    this.onTapTerms,
    this.onTapPrivacy,
    this.showFooter = true,
  });

  final Widget child;
  final bool showBack;
  final Widget? trailing;
  final VoidCallback? onTapTerms;
  final VoidCallback? onTapPrivacy;
  final bool showFooter;

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.authHorizontalPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: AppSpacing.backButtonSize,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (showBack) const AppBackButton(),
                            ?trailing,
                          ],
                        ),
                      ),
                      child,
                      const Spacer(),
                      if (showFooter && !keyboardOpen)
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          child: AppLegalFooter(
                            onTapTerms: onTapTerms ?? () {},
                            onTapPrivacy: onTapPrivacy ?? () {},
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
