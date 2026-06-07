import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../../core/theme/app_theme.dart';

/// Shows a one-time "Add to Home Screen" prompt on web.
class PwaInstallBanner extends StatefulWidget {
  final Widget child;
  const PwaInstallBanner({super.key, required this.child});

  @override
  State<PwaInstallBanner> createState() => _PwaInstallBannerState();
}

class _PwaInstallBannerState extends State<PwaInstallBanner> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _show = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || !_show) return widget.child;

    return Stack(
      children: [
        widget.child,
        Positioned(
          bottom: 80,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.borderSubtle),
              boxShadow: AppShadows.cardShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    // Use the web icon which has a black background
                    child: Image.network(
                      'icons/Icon-192.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Image.asset('assets/images/app_icon.png'),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.base),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Add to Home Screen', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 2),
                      Text('Tap Share ⎙ then "Add to Home Screen"', style: AppTextStyles.caption),
                    ],
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => setState(() => _show = false),
                  child: const Icon(
                    CupertinoIcons.xmark_circle_fill,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
