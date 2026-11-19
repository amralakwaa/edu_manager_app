// ========================================
// custom_button.dart - زر مخصص
// نظام إدارة التعليم / Education Management System
// ========================================

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// زر مخصص فخم / Premium Custom Button
class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final IconData? icon;
  final bool iconAtEnd;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.borderRadius = 12,
    this.icon,
    this.iconAtEnd = false,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => _controller.forward() : null,
      onTapUp: isEnabled ? (_) => _controller.reverse() : null,
      onTapCancel: isEnabled ? () => _controller.reverse() : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient:
                widget.isOutlined
                    ? null
                    : LinearGradient(
                      colors:
                          isEnabled
                              ? [
                                widget.backgroundColor ?? AppColors.accent,
                                widget.backgroundColor?.withOpacity(0.8) ??
                                    AppColors.accentLight,
                              ]
                              : [Colors.grey.shade600, Colors.grey.shade500],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border:
                widget.isOutlined
                    ? Border.all(
                      color: widget.backgroundColor ?? AppColors.accent,
                      width: 2,
                    )
                    : null,
            boxShadow:
                widget.isOutlined || !isEnabled
                    ? null
                    : [
                      BoxShadow(
                        color: (widget.backgroundColor ?? AppColors.accent)
                            .withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled ? widget.onPressed : null,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Center(
                child:
                    widget.isLoading
                        ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.isOutlined
                                  ? (widget.backgroundColor ?? AppColors.accent)
                                  : Colors.white,
                            ),
                          ),
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null && !widget.iconAtEnd) ...[
                              Icon(
                                widget.icon,
                                color:
                                    widget.isOutlined
                                        ? (widget.textColor ??
                                            widget.backgroundColor ??
                                            AppColors.accent)
                                        : (widget.textColor ?? Colors.white),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.text,
                              style: TextStyle(
                                color:
                                    widget.isOutlined
                                        ? (widget.textColor ??
                                            widget.backgroundColor ??
                                            AppColors.accent)
                                        : (widget.textColor ?? Colors.white),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.icon != null && widget.iconAtEnd) ...[
                              const SizedBox(width: 8),
                              Icon(
                                widget.icon,
                                color:
                                    widget.isOutlined
                                        ? (widget.textColor ??
                                            widget.backgroundColor ??
                                            AppColors.accent)
                                        : (widget.textColor ?? Colors.white),
                                size: 20,
                              ),
                            ],
                          ],
                        ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// زر ذهبي مميز / Premium Gold Button
class GoldButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const GoldButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: CustomButton(
        text: text,
        onPressed: onPressed,
        isLoading: isLoading,
        icon: icon,
        backgroundColor: Colors.transparent,
        textColor: AppColors.textDark,
      ),
    );
  }
}
