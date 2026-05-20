import 'package:flutter/material.dart';

/// PastelButton — Tombol bergaya ElevatedButton dengan gradient pastel
/// dan sudut membulat. Mendukung mode solid dan outline.
class PastelButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final bool isOutlined;
  final IconData? icon;

  const PastelButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.isOutlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? Theme.of(context).colorScheme.primary;

    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: baseColor,
          side: BorderSide(color: baseColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: _buildChild(baseColor),
      );
    }

    // Tombol solid dengan gradient
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            baseColor,
            baseColor.withValues(alpha: 0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: _buildChild(Colors.white),
      ),
    );
  }

  Widget _buildChild(Color textColor) {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: textColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }
}
