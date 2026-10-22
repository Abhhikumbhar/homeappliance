import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/appliance_service.dart';
import '../utils/colors.dart';

/// Live Appliance Animation Card
/// Provides rich, hardware-accelerated live animations:
/// 1. AC: Live cool wind gusts, flowing breeze waves & frost sparkles blowing out from the vent
/// 2. Fan: Smooth spinning fan blades with concentric wind swirls & speed blur
/// 3. RO Filter: Live water tap stream, falling water droplets & splash ripples
/// 4. Washing Machine: Swirling water vortex drum & floating soapy bubbles
class LiveApplianceAnimationCard extends StatefulWidget {
  final String imageAsset;
  final ServiceCategory category;
  final IconData fallbackIcon;
  final double width;
  final double height;
  final double borderRadius;

  const LiveApplianceAnimationCard({
    super.key,
    required this.imageAsset,
    required this.category,
    required this.fallbackIcon,
    this.width = 136,
    this.height = 136,
    this.borderRadius = 22,
  });

  @override
  State<LiveApplianceAnimationCard> createState() =>
      _LiveApplianceAnimationCardState();
}

class _LiveApplianceAnimationCardState extends State<LiveApplianceAnimationCard>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late AnimationController _fanController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // Fast, authentic ceiling fan rotation (480ms per full 360-degree rotation)
    _fanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    _fanController.dispose();
    super.dispose();
  }

  bool get _isFan =>
      widget.imageAsset.contains('fan') ||
      widget.fallbackIcon == Icons.wind_power_rounded;

  bool get _isAc =>
      widget.category == ServiceCategory.ac && !_isFan;

  bool get _isRo =>
      widget.category == ServiceCategory.roWater ||
      widget.imageAsset.contains('ro');

  bool get _isWashingMachine =>
      widget.category == ServiceCategory.washingMachine ||
      widget.imageAsset.contains('wm');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 2.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius - 2.5),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Base Appliance Image or Studio Backdrop for Fan
            _buildBaseApplianceImage(),

            // 2. Specialized Live Animation Overlays
            if (_isAc)
              _buildAcLiveWindOverlay(),
            if (_isFan)
              _buildFanLiveSpinOverlay(),
            if (_isRo)
              _buildRoLiveWaterOverlay(),
            if (_isWashingMachine)
              _buildWashingMachineLiveOverlay(),

            // 3. Subtle Live Glow Badge in Top-Right corner
            Positioned(
              top: 6,
              right: 6,
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, _) {
                  final pulse = (math.sin(_animController.value * 2 * math.pi) + 1) / 2;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 0.6,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5.5,
                          height: 5.5,
                          decoration: BoxDecoration(
                            color: Color.lerp(
                              const Color(0xFF10B981),
                              const Color(0xFF34D399),
                              pulse,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.5 + pulse * 0.4),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 3.5),
                        const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 7.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBaseApplianceImage() {
    if (_isFan) {
      // For fan, render the authentic studio backdrop so live 3D fan blades spin cleanly
      return Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, 0.05),
            radius: 0.85,
            colors: [
              Color(0xFFF3F4F6),
              Color(0xFFE5E7EB),
              Color(0xFFD1D5DB),
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
      );
    }
    return Image.asset(
      widget.imageAsset,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: AppColors.primary.withValues(alpha: 0.08),
        alignment: Alignment.center,
        child: Icon(
          widget.fallbackIcon,
          size: widget.width * 0.42,
          color: AppColors.primary,
        ),
      ),
    );
  }

  // ========================================================
  // 1. AC LIVE WIND / AIR BREEZE ANIMATION
  // ========================================================
  Widget _buildAcLiveWindOverlay() {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _AcWindPainter(progress: _animController.value),
        );
      },
    );
  }

  // ========================================================
  // 2. CEILING FAN REALISTIC HIGH-SPEED ROTATION OVERLAY
  // ========================================================
  Widget _buildFanLiveSpinOverlay() {
    return AnimatedBuilder(
      animation: _fanController,
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _FanRealisticPainter(
            rotationProgress: _fanController.value,
            windProgress: _animController.value,
          ),
        );
      },
    );
  }



  // ========================================================
  // 3. RO FILTER LIVE WATER DROPS & STREAM ANIMATION
  // ========================================================
  Widget _buildRoLiveWaterOverlay() {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _RoWaterStreamPainter(progress: _animController.value),
        );
      },
    );
  }

  // ========================================================
  // 4. WASHING MACHINE VORTEX & SOAP BUBBLES ANIMATION
  // ========================================================
  Widget _buildWashingMachineLiveOverlay() {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _WashingMachineDrumPainter(progress: _animController.value),
        );
      },
    );
  }
}

// ==========================================================
// PAINTER 1: AC COOL WIND FLOW & BREEZE GUSTS (WAND)
// ==========================================================
class _AcWindPainter extends CustomPainter {
  final double progress;
  _AcWindPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // The AC vent is typically located horizontally around 48% - 55% from the top
    final ventY = h * 0.52;
    final ventLeft = w * 0.15;
    final ventRight = w * 0.85;

    // Glowing Cold Air Blue Gradient wash flowing down
    final flowGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        const Color(0x3300D4FF).withValues(alpha: 0.15 + 0.1 * math.sin(progress * 2 * math.pi)),
        const Color(0x4460A5FA).withValues(alpha: 0.2),
        Colors.transparent,
      ],
      stops: const [0.45, 0.60, 0.80, 1.0],
    );

    final rect = Rect.fromLTWH(0, ventY, w, h - ventY);
    final glowPaint = Paint()..shader = flowGradient.createShader(rect);
    canvas.drawRect(rect, glowPaint);

    // 4 Flowing Wind Streams emanating from the vent downwards with animated phase
    final streams = [
      {'startX': w * 0.28, 'curv': -14.0, 'delay': 0.0, 'len': 0.44},
      {'startX': w * 0.45, 'curv': -4.0, 'delay': 0.25, 'len': 0.48},
      {'startX': w * 0.60, 'curv': 8.0, 'delay': 0.50, 'len': 0.45},
      {'startX': w * 0.74, 'curv': 16.0, 'delay': 0.75, 'len': 0.42},
    ];

    for (var stream in streams) {
      final startX = stream['startX'] as double;
      final curv = stream['curv'] as double;
      final delay = stream['delay'] as double;
      final len = stream['len'] as double;

      final waveT = (progress + delay) % 1.0;
      final alpha = math.sin(waveT * math.pi).clamp(0.0, 1.0);

      // Draw curved wind wave line
      final path = Path();
      path.moveTo(startX, ventY + 4);

      final cp1X = startX + curv * 0.8 + math.sin(waveT * 2 * math.pi) * 6;
      final cp1Y = ventY + (h * len) * 0.5;

      final endX = startX + curv + math.sin((waveT + 0.2) * 2 * math.pi) * 8;
      final endY = ventY + (h * len);

      path.quadraticBezierTo(cp1X, cp1Y, endX, endY);

      final windPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..color = Color(0xFF38BDF8).withValues(alpha: 0.75 * alpha);

      canvas.drawPath(path, windPaint);

      // Draw lighter outer wind aura
      final auraPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFBAE6FD).withValues(alpha: 0.35 * alpha);

      canvas.drawPath(path, auraPaint);
    }

    // Floating frosty snowflake / mist particles drifting down
    final particles = [
      {'x': w * 0.32, 'yOffset': 0.1, 'speed': 0.85, 'r': 2.0},
      {'x': w * 0.50, 'yOffset': 0.35, 'speed': 1.1, 'r': 2.5},
      {'x': w * 0.68, 'yOffset': 0.6, 'speed': 0.95, 'r': 1.8},
      {'x': w * 0.40, 'yOffset': 0.8, 'speed': 1.2, 'r': 2.2},
      {'x': w * 0.58, 'yOffset': 0.2, 'speed': 0.75, 'r': 2.4},
    ];

    for (var p in particles) {
      final xBase = p['x'] as double;
      final yOff = p['yOffset'] as double;
      final speed = p['speed'] as double;
      final r = p['r'] as double;

      final pProg = (progress * speed + yOff) % 1.0;
      final px = xBase + math.sin(pProg * 2 * math.pi + yOff) * 7;
      final py = ventY + 5 + pProg * (h - ventY - 10);
      final pAlpha = (math.sin(pProg * math.pi)).clamp(0.0, 1.0);

      final pPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.85 * pAlpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(px, py), r, pPaint);
    }

    // Power Indicator green LED on AC panel
    final ledX = ventRight - 10;
    final ledY = ventY - 14;
    final ledPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(ledX, ledY), 2.2, ledPaint);
  }

  @override
  bool shouldRepaint(covariant _AcWindPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ==========================================================
// PAINTER 2: CEILING FAN REALISTIC 360° HIGH-SPEED ROTATION
// ==========================================================
class _FanRealisticPainter extends CustomPainter {
  final double rotationProgress;
  final double windProgress;

  _FanRealisticPainter({
    required this.rotationProgress,
    required this.windProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Center of fan motor hub
    final cx = w * 0.50;
    final cy = h * 0.52;
    final hubRadius = w * 0.115;
    final bladeLen = w * 0.42;
    final maxBladeWidth = w * 0.11;

    // -----------------------------------------------------------
    // 1. STATIONARY CEILING MOUNT (CANOPY) & DOWNROD
    // -----------------------------------------------------------
    // Ceiling mount cup at top
    final canopyTop = h * 0.12;
    final canopyBottom = h * 0.20;
    final canopyWidth = w * 0.22;
    final canopyRect = Rect.fromCenter(
      center: Offset(cx, (canopyTop + canopyBottom) / 2),
      width: canopyWidth,
      height: canopyBottom - canopyTop,
    );
    final canopyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: const [
          Color(0xFF2C2E33),
          Color(0xFF4A4E56),
          Color(0xFF737882),
          Color(0xFF4A4E56),
          Color(0xFF1E2024),
        ],
        stops: const [0.0, 0.25, 0.50, 0.75, 1.0],
      ).createShader(canopyRect);

    final canopyPath = Path()
      ..moveTo(cx - canopyWidth * 0.35, canopyTop)
      ..lineTo(cx + canopyWidth * 0.35, canopyTop)
      ..quadraticBezierTo(
        cx + canopyWidth * 0.5,
        canopyBottom,
        cx + canopyWidth * 0.25,
        canopyBottom,
      )
      ..lineTo(cx - canopyWidth * 0.25, canopyBottom)
      ..quadraticBezierTo(
        cx - canopyWidth * 0.5,
        canopyBottom,
        cx - canopyWidth * 0.35,
        canopyTop,
      )
      ..close();
    canvas.drawPath(canopyPath, canopyPaint);

    // Downrod connecting canopy to motor hub
    final rodWidth = w * 0.038;
    final rodRect = Rect.fromLTRB(
      cx - rodWidth / 2,
      canopyBottom - 2,
      cx + rodWidth / 2,
      cy - hubRadius * 0.5,
    );
    final rodPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: const [
          Color(0xFF2D3036),
          Color(0xFF5A5F6B),
          Color(0xFF9EA3AF),
          Color(0xFF4A4E56),
          Color(0xFF1F2124),
        ],
        stops: const [0.0, 0.28, 0.50, 0.75, 1.0],
      ).createShader(rodRect);
    canvas.drawRect(rodRect, rodPaint);

    // -----------------------------------------------------------
    // 2. LIVE ROTATING AIR BREEZE SWIRL TRAILS (Behind Blades)
    // -----------------------------------------------------------
    final swirlAngle = rotationProgress * 2 * math.pi;
    for (int i = 0; i < 4; i++) {
      final rRadius = hubRadius + (bladeLen - hubRadius) * (0.35 + i * 0.22);
      final arcStart = swirlAngle + (i * math.pi / 2);
      final sweepAngle = math.pi * 0.75;
      final breezeRect = Rect.fromCircle(center: Offset(cx, cy), radius: rRadius);
      final breezePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 + i * 0.8
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          center: Alignment.center,
          startAngle: arcStart,
          endAngle: arcStart + sweepAngle,
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.18 + i * 0.05),
            Colors.white.withValues(alpha: 0.40 + i * 0.08),
          ],
          stops: const [0.0, 0.5, 1.0],
          transform: GradientRotation(arcStart),
        ).createShader(breezeRect);

      canvas.drawArc(breezeRect, arcStart, sweepAngle, false, breezePaint);
    }

    // -----------------------------------------------------------
    // 3. MOTION BLUR SWEPT DISC (Photorealistic High-Speed Spin)
    // -----------------------------------------------------------
    final discRect = Rect.fromCircle(center: Offset(cx, cy), radius: bladeLen);
    final discPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF1E2024).withValues(alpha: 0.04),
          const Color(0xFF1E2024).withValues(alpha: 0.14),
          const Color(0xFF1E2024).withValues(alpha: 0.06),
          Colors.transparent,
        ],
        stops: [
          0.0,
          hubRadius / bladeLen,
          (hubRadius + bladeLen * 0.6) / bladeLen,
          0.92,
          1.0,
        ],
      ).createShader(discRect);
    canvas.drawCircle(Offset(cx, cy), bladeLen, discPaint);

    // -----------------------------------------------------------
    // 4. ROTATING BLADES (3 Aerodynamic Contoured Blades with Ghost Blur)
    // -----------------------------------------------------------
    final baseAngle = rotationProgress * 2 * math.pi;

    // Helper to draw a single sculpted blade
    void drawBlade(double angle, double opacity, bool isGhost) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);

      final bladePath = Path();
      bladePath.moveTo(hubRadius * 0.5, -maxBladeWidth * 0.35);

      // Leading edge curve (aerodynamic wing chord)
      bladePath.cubicTo(
        bladeLen * 0.30,
        -maxBladeWidth * 0.85,
        bladeLen * 0.70,
        -maxBladeWidth * 0.80,
        bladeLen * 0.95,
        -maxBladeWidth * 0.50,
      );

      // Rounded winglet tip
      bladePath.arcToPoint(
        Offset(bladeLen, maxBladeWidth * 0.20),
        radius: Radius.circular(maxBladeWidth * 0.35),
      );

      // Trailing edge contour back to motor hub
      bladePath.cubicTo(
        bladeLen * 0.75,
        maxBladeWidth * 0.65,
        bladeLen * 0.35,
        maxBladeWidth * 0.50,
        hubRadius * 0.5,
        maxBladeWidth * 0.35,
      );
      bladePath.close();

      final bladeBBox = Rect.fromLTWH(
        hubRadius * 0.5,
        -maxBladeWidth,
        bladeLen,
        maxBladeWidth * 2,
      );

      if (isGhost) {
        final ghostPaint = Paint()
          ..color = const Color(0xFF1E2024).withValues(alpha: opacity)
          ..style = PaintingStyle.fill;
        canvas.drawPath(bladePath, ghostPaint);
      } else {
        // Metallic carbon shading with specular light edge
        final bladeGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF4A4E57).withValues(alpha: opacity), // Highlight leading edge
            const Color(0xFF282A2E).withValues(alpha: opacity), // Main body
            const Color(0xFF141518).withValues(alpha: opacity), // Trailing shadow
          ],
          stops: const [0.0, 0.45, 1.0],
        );
        final bladePaint = Paint()
          ..shader = bladeGradient.createShader(bladeBBox)
          ..style = PaintingStyle.fill;
        canvas.drawPath(bladePath, bladePaint);

        // Highlight sheen line along blade center
        final sheenPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = Colors.white.withValues(alpha: 0.18 * opacity);
        final sheenPath = Path()
          ..moveTo(hubRadius * 0.8, -maxBladeWidth * 0.2)
          ..cubicTo(
            bladeLen * 0.4,
            -maxBladeWidth * 0.35,
            bladeLen * 0.7,
            -maxBladeWidth * 0.30,
            bladeLen * 0.9,
            -maxBladeWidth * 0.20,
          );
        canvas.drawPath(sheenPath, sheenPaint);
      }

      canvas.restore();
    }

    // Draw for each of the 3 blades at 0, 120, 240 deg with motion blur ghosting
    for (int b = 0; b < 3; b++) {
      final bladeBase = baseAngle + (b * 2 * math.pi / 3);

      // Trailing Motion Blur Ghosts (Simulates continuous fluid spin)
      drawBlade(bladeBase - 0.28, 0.12, true);
      drawBlade(bladeBase - 0.14, 0.24, true);

      // Main Crisp Blade
      drawBlade(bladeBase, 0.98, false);
    }

    // -----------------------------------------------------------
    // 5. CENTER MOTOR HOUSING (SPHERICAL BELL & ACCENT RINGS)
    // -----------------------------------------------------------
    // Motor drop shadow beneath the center
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(Offset(cx, cy + 2), hubRadius * 0.95, shadowPaint);

    // Main Motor Housing Bell
    final motorRect = Rect.fromCircle(center: Offset(cx, cy), radius: hubRadius);
    final motorPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        radius: 0.95,
        colors: const [
          Color(0xFF6B707B), // Light specular reflection
          Color(0xFF383B42),
          Color(0xFF222428),
          Color(0xFF141517),
        ],
        stops: const [0.0, 0.40, 0.75, 1.0],
      ).createShader(motorRect);
    canvas.drawCircle(Offset(cx, cy), hubRadius, motorPaint);

    // Motor Chrome Accent Ring
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.25);
    canvas.drawCircle(Offset(cx, cy), hubRadius * 0.75, ringPaint);

    // Central Dome Cap
    final capRadius = hubRadius * 0.52;
    final capRect = Rect.fromCircle(center: Offset(cx, cy), radius: capRadius);
    final capPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 0.85,
        colors: const [
          Color(0xFF5A5E66),
          Color(0xFF2E3036),
          Color(0xFF181A1D),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(capRect);
    canvas.drawCircle(Offset(cx, cy), capRadius, capPaint);

    // Little central chrome dot
    final centerDotPaint = Paint()..color = Colors.white.withValues(alpha: 0.35);
    canvas.drawCircle(Offset(cx - 1, cy - 1), 1.6, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant _FanRealisticPainter oldDelegate) =>
      oldDelegate.rotationProgress != rotationProgress ||
      oldDelegate.windProgress != windProgress;
}



// ==========================================================
// PAINTER 3: RO PURIFIER LIVE FLOWING WATER & DROPS
// ==========================================================
class _RoWaterStreamPainter extends CustomPainter {
  final double progress;
  _RoWaterStreamPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Purifier tap origin usually in lower center-left/center
    final tapX = w * 0.48;
    final tapY = h * 0.55;
    final bottomY = h * 0.90;

    // 1. Crystal Water Stream from Tap
    final streamPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    final streamGlow = Paint()
      ..color = const Color(0xFFE0F2FE).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final streamPath = Path();
    streamPath.moveTo(tapX, tapY);
    streamPath.lineTo(tapX, bottomY);

    canvas.drawPath(streamPath, streamGlow);
    canvas.drawPath(streamPath, streamPaint);

    // 2. Continuous Falling Teardrop Water Droplets
    final drops = [0.0, 0.33, 0.66];
    for (var offset in drops) {
      final dropProg = (progress + offset) % 1.0;
      final dy = tapY + dropProg * (bottomY - tapY);

      if (dropProg < 0.92) {
        // Falling teardrop shape
        final dropPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(tapX - 3.5, dy - 5, 7, 10));

        final dropPath = Path();
        dropPath.moveTo(tapX, dy - 5);
        dropPath.quadraticBezierTo(tapX + 4, dy + 1, tapX, dy + 5);
        dropPath.quadraticBezierTo(tapX - 4, dy + 1, tapX, dy - 5);
        canvas.drawPath(dropPath, dropPaint);

        // Highlight glint
        final glintPaint = Paint()..color = Colors.white;
        canvas.drawCircle(Offset(tapX - 1, dy - 1), 1.2, glintPaint);
      } else {
        // Splash ripples at the bottom
        final splashProg = (dropProg - 0.92) / 0.08;
        final rippleRadius = splashProg * 14.0;
        final rippleAlpha = (1.0 - splashProg).clamp(0.0, 1.0);

        final ripplePaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..color = const Color(0xFF38BDF8).withValues(alpha: 0.8 * rippleAlpha);

        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(tapX, bottomY),
            width: rippleRadius * 2,
            height: rippleRadius * 0.9,
          ),
          ripplePaint,
        );
      }
    }

    // 3. Floating Pure Water Bubbles Rising inside reservoir
    final bubbles = [
      {'x': w * 0.32, 'delay': 0.1, 'r': 3.0},
      {'x': w * 0.64, 'delay': 0.45, 'r': 2.5},
      {'x': w * 0.22, 'delay': 0.8, 'r': 3.5},
      {'x': w * 0.72, 'delay': 0.6, 'r': 2.0},
    ];

    for (var b in bubbles) {
      final bx = b['x'] as double;
      final delay = b['delay'] as double;
      final r = b['r'] as double;

      final bProg = (progress + delay) % 1.0;
      final by = bottomY - bProg * (bottomY - tapY * 0.7);
      final bAlpha = math.sin(bProg * math.pi).clamp(0.0, 1.0);

      final bubblePaint = Paint()
        ..color = const Color(0xFF0284C7).withValues(alpha: 0.35 * bAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      canvas.drawCircle(Offset(bx, by), r, bubblePaint);

      // Bubble shine dot
      final shinePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.7 * bAlpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(bx - r * 0.35, by - r * 0.35), r * 0.3, shinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RoWaterStreamPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ==========================================================
// PAINTER 4: WASHING MACHINE DRUM VORTEX & BUBBLES
// ==========================================================
class _WashingMachineDrumPainter extends CustomPainter {
  final double progress;
  _WashingMachineDrumPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.52;
    final cy = size.height * 0.56;
    final radius = size.width * 0.28;

    // Rotating Water Swirl Rings inside Drum
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(progress * 2 * math.pi);

    final swirlPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = const Color(0xFF06B6D4).withValues(alpha: 0.55);

    final rect = Rect.fromCircle(center: Offset.zero, radius: radius);
    canvas.drawArc(rect, 0, math.pi * 0.9, false, swirlPaint);
    canvas.drawArc(rect, math.pi, math.pi * 0.9, false, swirlPaint);

    canvas.restore();

    // Floating soap foam bubbles
    for (int i = 0; i < 4; i++) {
      final bProg = (progress + i * 0.25) % 1.0;
      final bx = cx + math.cos(i * 1.5 + bProg) * (radius * 0.6);
      final by = cy + (1.0 - bProg * 2) * (radius * 0.5);
      final alpha = math.sin(bProg * math.pi).clamp(0.0, 1.0);

      final bubblePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.8 * alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(bx, by), 2.2, bubblePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WashingMachineDrumPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
