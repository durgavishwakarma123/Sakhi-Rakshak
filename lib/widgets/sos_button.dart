import 'package:flutter/material.dart';
import '../utils/colors.dart';

class SosPulseButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isActive;

  const SosPulseButton({
    super.key,
    required this.onTap,
    required this.isActive,
  });

  @override
  State<SosPulseButton> createState() => _SosPulseButtonState();
}

class _SosPulseButtonState extends State<SosPulseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isActive ? _pulseAnimation.value : 1.0,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: widget.isActive
                      ? [AppColors.primary, AppColors.primaryDark]
                      : [AppColors.secondary, AppColors.primary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.isActive ? AppColors.primary : AppColors.secondary)
                        .withOpacity(0.5),
                    blurRadius: widget.isActive ? 40 : 20,
                    spreadRadius: widget.isActive ? 25 : 10,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.isActive ? Icons.emergency : Icons.security,
                      size: 65,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.isActive ? 'SOS ON' : 'HELP SOS',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.isActive ? 'ALERT SENT' : 'SHAKE OR PRESS',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}