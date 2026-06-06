import 'package:flutter/cupertino.dart';
import '../../core/theme/app_theme.dart';

/// Full-screen error state with optional retry.
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.exclamationmark_circle,
                size: 48, color: AppColors.textDisabled),
            const SizedBox(height: AppSpacing.base),
            Text(message,
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              CupertinoButton(
                onPressed: onRetry,
                child: Text('Try again',
                    style:
                        AppTextStyles.body.copyWith(color: AppColors.primary)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Animated shimmer placeholder for loading cards.
class SkeletonCard extends StatefulWidget {
  final double height;
  final double? width;

  const SkeletonCard({super.key, required this.height, this.width});

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        height: widget.height,
        width: widget.width ?? double.infinity,
        decoration: BoxDecoration(
          borderRadius: AppRadius.cardBR,
          color: Color.lerp(
            AppColors.backgroundSurface,
            AppColors.backgroundElevated,
            _anim.value,
          ),
        ),
      ),
    );
  }
}

/// Full-screen loading indicator — used sparingly, prefer skeleton cards.
class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CupertinoActivityIndicator());
}
