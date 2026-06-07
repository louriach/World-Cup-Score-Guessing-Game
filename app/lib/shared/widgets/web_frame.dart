import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// On web, constrains content to a mobile-width column centred on screen.
/// On native, renders children as-is.
class WebFrame extends StatelessWidget {
  final Widget child;
  const WebFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    // On desktop the sidebar shell handles its own layout
    final isDesktop = MediaQuery.of(context).size.width > 600;
    if (isDesktop) return child;

    return ColoredBox(
      color: const Color(0xFF000000),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: child,
        ),
      ),
    );
  }
}
