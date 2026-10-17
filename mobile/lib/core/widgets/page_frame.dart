import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_colors.dart';

class PageFrame extends StatelessWidget {
  const PageFrame({
    super.key,
    required this.child,
    this.appBar,
    this.bottom,
    this.scrollable = true,
    this.gradient = true,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottom;
  final bool scrollable;
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    final horizontal = MediaQuery.sizeOf(context).width <= 340
        ? AppSpacing.x4
        : AppSpacing.x5;
    final content = SafeArea(
      top: appBar == null,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontal,
          AppSpacing.x5,
          horizontal,
          bottom == null ? AppSpacing.x6 : AppSpacing.x4,
        ),
        child: child,
      ),
    );
    final body = scrollable
        ? SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: content,
          )
        : content;
    return Scaffold(
      appBar: appBar,
      body: gradient
          ? DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.canvas,
                    AppColors.primarySoft,
                    AppColors.greenSoft,
                  ],
                  stops: [0, .62, 1],
                ),
              ),
              child: body,
            )
          : body,
      bottomNavigationBar: bottom == null
          ? null
          : SafeArea(
              minimum: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 12),
              child: bottom!,
            ),
    );
  }
}
