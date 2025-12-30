import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

class LiveCompass extends StatelessWidget {
  const LiveCompass({
    super.key,
    this.size = 52,
    this.backgroundColor = const Color(0xFF111111),
    this.ringColor = const Color(0xFF2A2A2A),
    this.northColor = const Color(0xFFE53935),
    this.textColor = Colors.white70,
  });

  final double size;
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
          print('CompassEvent snapshot: ${snapshot.data}');
          // heading: 0 = Bắc, 90 = Đông, ...
          final heading = (snapshot.data?.heading) ?? 0; // degrees (double?)
          if (heading == null) {
            return _buildContainer(
              child: const Center(
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          // Xoay mặt la bàn ngược lại để kim luôn chỉ Bắc
          final angleRad = -heading * (math.pi / 180.0);

          return _buildContainer(
            child: Transform.rotate(
              angle: angleRad,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // chữ N ở trên
                  Positioned(
                    top: 4,
                    child: Text(
                      'N',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ),
                  // Kim Bắc (đỏ)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 2.6,
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
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: ringColor, width: 1),
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
