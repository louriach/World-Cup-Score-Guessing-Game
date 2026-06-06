import 'package:flutter/cupertino.dart';
import '../../core/theme/app_theme.dart';

enum ToastStyle { success, info, error }

class Toast {
  /// Show a toast at the top of the screen. Auto-dismisses after [duration].
  static void show(
    BuildContext context,
    String message, {
    String? subtitle,
    ToastStyle style = ToastStyle.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        subtitle: subtitle,
        style: style,
        onTap: onTap,
        onDismiss: () => entry.remove(),
        duration: duration,
      ),
    );

    overlay.insert(entry);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final String? subtitle;
  final ToastStyle style;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;
  final Duration duration;

  const _ToastWidget({
    required this.message,
    this.subtitle,
    required this.style,
    this.onTap,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AppDurations.standard,
    );

    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.forward();

    Future.delayed(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _ctrl.reverse();
    if (mounted) widget.onDismiss();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _bgColor => switch (widget.style) {
        ToastStyle.success => AppColors.success,
        ToastStyle.error => AppColors.error,
        ToastStyle.info => AppColors.backgroundElevated,
      };

  IconData get _icon => switch (widget.style) {
        ToastStyle.success => CupertinoIcons.checkmark_circle_fill,
        ToastStyle.error => CupertinoIcons.xmark_circle_fill,
        ToastStyle.info => CupertinoIcons.info_circle_fill,
      };

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + AppSpacing.base,
      left: AppSpacing.pagePadding,
      right: AppSpacing.pagePadding,
      child: FadeTransition(
        opacity: _opacity,
        child: SlideTransition(
          position: _slide,
          child: GestureDetector(
            onTap: () {
              widget.onTap?.call();
              _dismiss();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.cardShadow,
              ),
              child: Row(
                children: [
                  Icon(_icon, color: AppColors.textPrimary, size: 20),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.message,
                          style: AppTextStyles.bodyLargeBold.copyWith(
                            color: widget.style == ToastStyle.info
                                ? AppColors.textPrimary
                                : AppColors.textInverse,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            widget.subtitle!,
                            style: AppTextStyles.caption.copyWith(
                              color: widget.style == ToastStyle.info
                                  ? AppColors.textSecondary
                                  : AppColors.textInverse.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (widget.onTap != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Icon(
                      CupertinoIcons.chevron_right,
                      size: 14,
                      color: widget.style == ToastStyle.info
                          ? AppColors.textSecondary
                          : AppColors.textInverse.withOpacity(0.7),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
