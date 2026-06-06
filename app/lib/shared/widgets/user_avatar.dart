import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import '../../core/theme/app_theme.dart';

/// Reusable circular avatar. Falls back to a person icon if url is null or fails.
class UserAvatar extends StatelessWidget {
  final String? url;
  final double size;

  const UserAvatar({super.key, this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.backgroundElevated,
      ),
      clipBehavior: Clip.antiAlias,
      child: url != null
          ? CachedNetworkImage(
              imageUrl: url!,
              fit: BoxFit.cover,
              placeholder: (_, __) => const SizedBox.shrink(),
              errorWidget: (_, __, ___) => _placeholder(size),
            )
          : _placeholder(size),
    );
  }

  Widget _placeholder(double size) => Icon(
        CupertinoIcons.person_fill,
        size: size * 0.5,
        color: AppColors.textDisabled,
      );
}
