import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;

class LiveCompass extends StatelessWidget {
  const LiveCompass({
    super.key,
    this.size = 52,
    this.backgroundColor = const Color(0xFF111111),
    this.ringColor = const Color(0xFF2A2A2A),
    this.northColor = const Color(0xFFE53935),
    this.textColor = Colors.white70,
    this.isActive = true,
  });

  final double size;
  final bool isActive;
  final Color backgroundColor;
  final Color ringColor;
  final Color northColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    FlutterCompass();
    return SizedBox(
      width: size,
      height: size,
      child: StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          final heading = (snapshot.data?.heading) ?? 0;

          return _buildContainer(
            child: Transform.rotate(
              angle: heading * math.pi / 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Kim Bắc (đỏ)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: size * 0.12,
                      height: size * 0.36,
                      decoration: BoxDecoration(
                        color: northColor,
                        borderRadius: BorderRadius.circular(99),
                        boxShadow: [
                          BoxShadow(
                            color: northColor.withOpacity(0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Tâm
                  Container(
                    width: size * 0.4,
                    height: size * 0.4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? Theme.of(context).primaryColor : Colors.grey,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContainer({required Widget child}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: ringColor, width: 2),
      ),
      child: ClipOval(child: child),
    );
  }
}
