import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PVButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final bool loading;
  final IconData? icon;
  final double? width;
  const PVButton({super.key, required this.label, this.onPressed,
    this.outlined = false, this.loading = false, this.icon, this.width});

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(height: 18, width: 18,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
        : Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 6)],
            Text(label),
          ]);
    final btn = outlined
        ? OutlinedButton(onPressed: loading ? null : onPressed, child: child)
        : ElevatedButton(onPressed: loading ? null : onPressed, child: child);
    return width != null ? SizedBox(width: width, child: btn) : btn;
  }
}
