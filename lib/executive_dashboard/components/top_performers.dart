import 'dart:math' as math;

import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../dashboard_data.dart';
import 'dashboard_widgets.dart';
import 'manager_detail_sheet.dart';

/// Widget stats "Top Performers" — โพเดียมแท่ง 2.5D isometric 5 อันดับ
/// พร้อม filter สลับ Top ดีสุด / Top แย่สุด และ effect:
/// แท่งโตจากพื้นแบบ stagger, shimmer บนอันดับ 1, glow avatar
class TopPerformers extends StatefulWidget {
  const TopPerformers({super.key, this.compact = false});

  /// compact = โพเดียม 3 คนสำหรับคอลัมน์แคบ (ไม่มี filter)
  final bool compact;

  @override
  State<TopPerformers> createState() => _TopPerformersState();
}

class _TopPerformersState extends State<TopPerformers> {
  bool _best = true;

  List<ManagerInfo> get _top5 {
    final sorted = [...managers]..sort((a, b) =>
        _best ? b.score.compareTo(a.score) : a.score.compareTo(b.score));
    return sorted.take(widget.compact ? 3 : 5).toList();
  }

  Widget _filterChip(BuildContext context, String label, IconData icon,
      bool value) {
    final theme = FlutterFlowTheme.of(context);
    final selected = _best == value;
    return InkWell(
      onTap: () => setState(() => _best = value),
      borderRadius: BorderRadius.circular(999.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white
              : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(999.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14.0,
                color: selected
                    ? (value ? Color(0xFF1FA34C) : Color(0xFFD03B3B))
                    : Colors.white70),
            SizedBox(width: 5.0),
            Text(
              label,
              style: theme.bodySmall.override(
                fontFamily: theme.bodySmallFamily,
                color: selected ? Color(0xFF0F2A52) : Colors.white70,
                fontSize: 12.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodySmallIsCustom,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final top = _top5;
    // ลำดับบนเวที (compact: 2,1,3 · เต็ม: 4,2,1,3,5) อันดับ 1 กลางสูงสุด
    final stage = widget.compact
        ? [top[1], top[0], top[2]]
        : [top[3], top[1], top[0], top[2], top[4]];
    final ranks = widget.compact ? [2, 1, 3] : [4, 2, 1, 3, 5];
    final heights = widget.compact
        ? [86.0, 120.0, 64.0]
        : [66.0, 112.0, 150.0, 92.0, 54.0];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 18.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _best
              ? [Color(0xFF0F2A52), Color(0xFF1D4E8F)]
              : [Color(0xFF3B0D0D), Color(0xFF7A1F1F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _best
                    ? Icons.emoji_events_rounded
                    : Icons.trending_down_rounded,
                color: _best ? Color(0xFFF5B301) : Color(0xFFFF8A80),
                size: 20.0,
              ),
              SizedBox(width: 6.0),
              Expanded(
                child: Text(
                  widget.compact
                      ? (_best
                          ? 'Top PM of the Week'
                          : 'PM ต้องปรับปรุง')
                      : (_best
                          ? 'Top Performers ประจำสัปดาห์'
                          : 'ต้องปรับปรุง (คะแนนต่ำสุด)'),
                  style: theme.titleMedium.override(
                    fontFamily: theme.titleMediumFamily,
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.titleMediumIsCustom,
                  ),
                ),
              ),
              if (!widget.compact) ...[
                _filterChip(
                    context, 'Top ดีสุด', Icons.trending_up_rounded, true),
                SizedBox(width: 6.0),
                _filterChip(context, 'Top แย่สุด',
                    Icons.trending_down_rounded, false),
              ],
            ],
          ),
          if (widget.compact) ...[
            SizedBox(height: 10.0),
            Row(
              children: [
                _filterChip(
                    context, 'ดีสุด', Icons.trending_up_rounded, true),
                SizedBox(width: 6.0),
                _filterChip(
                    context, 'แย่สุด', Icons.trending_down_rounded, false),
              ],
            ),
          ],
          SizedBox(height: 14.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              key: ValueKey(_best),
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(stage.length, (i) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                  child: _PodiumSlot(
                    manager: stage[i],
                    rank: ranks[i],
                    pillarHeight: heights[i],
                    order: i,
                    best: _best,
                    compact: widget.compact,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  const _PodiumSlot({
    required this.manager,
    required this.rank,
    required this.pillarHeight,
    required this.order,
    required this.best,
    this.compact = false,
  });

  final ManagerInfo manager;
  final int rank;
  final double pillarHeight;
  final int order;
  final bool best;
  final bool compact;

  Color get _color => best
      ? switch (rank) {
          1 => Color(0xFFF5B301), // ทอง
          2 => Color(0xFFB7BEC8), // เงิน
          3 => Color(0xFFC97C3C), // ทองแดง
          4 => Color(0xFF4C8DD6),
          _ => Color(0xFF5EC4B2),
        }
      : switch (rank) {
          1 => Color(0xFFE5484D), // แย่สุด = แดง
          2 => Color(0xFFF76B15),
          3 => Color(0xFFFFB224),
          4 => Color(0xFF9BA1A6),
          _ => Color(0xFF7E868C),
        };

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    final slot = InkWell(
      onTap: () => showManagerDetailSheet(context, manager),
      borderRadius: BorderRadius.circular(10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (rank == 1)
            Text(best ? '👑' : '⚠️', style: TextStyle(fontSize: 20.0))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 0, end: -4, duration: 900.ms),
          SizedBox(height: 2.0),
          // avatar + glow ตามสีอันดับ
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _color, width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: _color.withOpacity(0.55),
                  blurRadius: rank == 1 ? 18.0 : 10.0,
                  spreadRadius: rank == 1 ? 2.0 : 0.0,
                ),
              ],
            ),
            child: PmAvatar(
              name: manager.name,
              avatarUrl: manager.avatarUrl,
              size: compact
                  ? (rank == 1 ? 38.0 : 32.0)
                  : (rank == 1 ? 46.0 : 38.0),
            ),
          ),
          SizedBox(height: 6.0),
          SizedBox(
            width: compact ? 90.0 : 126.0,
            child: Text(
              // จอแคบใช้ชื่อหน้าอย่างเดียวให้อ่านเต็ม
              compact ? manager.name.split(' ').first : manager.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.bodySmall.override(
                fontFamily: theme.bodySmallFamily,
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodySmallIsCustom,
              ),
            ),
          ),
          Text(
            '${manager.score} คะแนน',
            style: theme.bodySmall.override(
              fontFamily: theme.bodySmallFamily,
              color: _color,
              fontSize: 11.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodySmallIsCustom,
            ),
          ),
          SizedBox(height: 6.0),
          // แท่ง 2.5D isometric — โตจากพื้น
          _IsoPillar(
            color: _color,
            height: pillarHeight,
            rank: rank,
            width: compact ? 58.0 : 92.0,
          )
              .animate(delay: (200 + order * 130).ms)
              .scaleY(
                begin: 0.0,
                end: 1.0,
                duration: 550.ms,
                curve: Curves.easeOutBack,
                alignment: Alignment.bottomCenter,
              )
              .fadeIn(duration: 300.ms),
          // เงารูปวงรีใต้แท่ง
          Container(
            width: compact ? 70.0 : 108.0,
            height: 8.0,
            margin: EdgeInsets.only(top: 3.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.elliptical(54.0, 4.0)),
              color: Colors.black.withOpacity(0.35),
            ),
          ),
        ],
      ),
    );

    return slot
        .animate(delay: (order * 130).ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.18, duration: 450.ms, curve: Curves.easeOut);
  }
}

/// แท่ง isometric: หน้า (gradient) + ด้านข้าง (เข้ม) + หน้าบน (สว่าง)
class _IsoPillar extends StatelessWidget {
  const _IsoPillar({
    required this.color,
    required this.height,
    required this.rank,
    this.width = 92.0,
  });

  final Color color;
  final double height;
  final int rank;
  final double width;

  @override
  Widget build(BuildContext context) {
    final w = width;
    const dx = 14.0; // ระยะเฉียงของ isometric
    const dy = 10.0;

    Widget pillar = CustomPaint(
      size: Size(w + dx, height + dy),
      painter: _IsoPillarPainter(color: color, rank: rank),
    );

    // shimmer วนเฉพาะแชมป์
    if (rank == 1) {
      pillar = pillar
          .animate(onPlay: (c) => c.repeat())
          .shimmer(
            delay: 1200.ms,
            duration: 1800.ms,
            color: Colors.white.withOpacity(0.45),
            angle: math.pi / 4,
          );
    }
    return pillar;
  }
}

class _IsoPillarPainter extends CustomPainter {
  _IsoPillarPainter({required this.color, required this.rank});

  final Color color;
  final int rank;

  @override
  void paint(Canvas canvas, Size size) {
    const dx = 14.0;
    const dy = 10.0;
    final w = size.width - dx;
    final h = size.height;

    Color darken(Color c, double f) => Color.fromARGB(
          c.alpha,
          (c.red * f).round(),
          (c.green * f).round(),
          (c.blue * f).round(),
        );
    Color lighten(Color c, double f) => Color.fromARGB(
          c.alpha,
          (c.red + (255 - c.red) * f).round(),
          (c.green + (255 - c.green) * f).round(),
          (c.blue + (255 - c.blue) * f).round(),
        );

    // หน้าแท่ง (gradient บนสว่าง → ล่างเข้ม)
    final front = Path()
      ..moveTo(0, dy)
      ..lineTo(w, dy)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      front,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [lighten(color, 0.25), darken(color, 0.82)],
        ).createShader(Rect.fromLTWH(0, dy, w, h - dy)),
    );

    // ด้านข้างขวา (เข้มสุด)
    final side = Path()
      ..moveTo(w, dy)
      ..lineTo(w + dx, 0)
      ..lineTo(w + dx, h - dy)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(side, Paint()..color = darken(color, 0.55));

    // หน้าบน (สว่างสุด)
    final top = Path()
      ..moveTo(0, dy)
      ..lineTo(dx, 0)
      ..lineTo(w + dx, 0)
      ..lineTo(w, dy)
      ..close();
    canvas.drawPath(top, Paint()..color = lighten(color, 0.5));

    // เส้นขอบบาง ๆ ให้ดูคม
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withOpacity(0.25);
    canvas.drawPath(top, edge);
    canvas.drawLine(Offset(w, dy), Offset(w, h), edge);

    // เลขอันดับกลางหน้าแท่ง
    final tp = TextPainter(
      text: TextSpan(
        text: '$rank',
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: rank == 1 ? 34.0 : 26.0,
          fontWeight: FontWeight.w800,
          shadows: [
            Shadow(color: Colors.black26, blurRadius: 4.0),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset((w - tp.width) / 2, dy + (h - dy - tp.height) / 2),
    );
  }

  @override
  bool shouldRepaint(_IsoPillarPainter old) =>
      old.color != color || old.rank != rank;
}
