import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Lucide SVG icons used throughout the app.
class AppIcon extends StatelessWidget {
  final String _asset;
  final double size;
  final Color? color;

  const AppIcon.home({super.key, this.size = 24, this.color})
      : _asset = 'assets/icons/home.svg';
  const AppIcon.scores({super.key, this.size = 24, this.color})
      : _asset = 'assets/icons/flag.svg';
  const AppIcon.leagues({super.key, this.size = 24, this.color})
      : _asset = 'assets/icons/trophy.svg';
  const AppIcon.me({super.key, this.size = 24, this.color})
      : _asset = 'assets/icons/user-circle.svg';
  const AppIcon.pencil({super.key, this.size = 24, this.color})
      : _asset = 'assets/icons/pencil.svg';
  const AppIcon.user({super.key, this.size = 24, this.color})
      : _asset = 'assets/icons/user.svg';
  const AppIcon.circleCheck({super.key, this.size = 24, this.color})
      : _asset = 'assets/icons/circle-check.svg';
  const AppIcon.clipboard({super.key, this.size = 24, this.color})
      : _asset = 'assets/icons/clipboard.svg';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _asset,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}
