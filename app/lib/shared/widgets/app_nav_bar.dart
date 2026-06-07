import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../../core/theme/app_theme.dart';

/// Returns a CupertinoNavigationBar on mobile, null on desktop web.
/// Use as the `navigationBar` argument of CupertinoPageScaffold.
/// On desktop, the AppShell top nav replaces per-screen nav bars.
ObstructingPreferredSizeWidget? appNavBar({
  Widget? middle,
  Widget? leading,
  Widget? trailing,
  BuildContext? context,
}) {
  if (kIsWeb && context != null && MediaQuery.of(context).size.width > 600) {
    return null;
  }
  return CupertinoNavigationBar(
    middle: middle,
    leading: leading,
    trailing: trailing,
    backgroundColor: AppColors.backgroundSurface,
    border: const Border(
      bottom: BorderSide(color: AppColors.borderSubtle, width: 0.5),
    ),
  );
}
