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
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    const hPad = EdgeInsets.symmetric(
      horizontal: AppSpacing.authHorizontalPadding,
    );
    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: hPad,
                child: SizedBox(
                  height: AppSpacing.backButtonSize,
                  child: Row(
                    children: [
                      if (showBack) const AppBackButton(),
                      const Spacer(),
                      ?trailing,
                    ],
                  ),
                ),
              ),
              Expanded(
                // Not SliverFillRemaining: it needs intrinsic sizes, which
                // LayoutBuilder-based children (AppButton) cannot provide.
                child: LayoutBuilder(
                  builder: (context, constraints) => CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Padding(padding: hPad, child: child),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (showFooter && !keyboardOpen)
                Padding(
                  padding: hPad.copyWith(
                    top: AppSpacing.md,
                    bottom: AppSpacing.md,
                  ),
                  child: AppLegalFooter(
                    onTapTerms: onTapTerms ?? () {},
                    onTapPrivacy: onTapPrivacy ?? () {},
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
