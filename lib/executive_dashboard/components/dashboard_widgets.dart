import 'dart:math' as math;

import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

import '../dashboard_data.dart';

// สีสถานะงาน — ผ่าน CVD validator (dataviz):
// เทา = Pending โดยเจตนา, เหลือง contrast ต่ำ → มี legend + ตัวเลขกำกับเสมอ
const Map<String, Color> statusColors = {
  WorkStatus.inProgress: Color(0xFF2A78D6),
  WorkStatus.done: Color(0xFF0CA30C),
  WorkStatus.notStarted: Color(0xFF898781),
  WorkStatus.delayed: Color(0xFFD03B3B),
  WorkStatus.waitDecision: Color(0xFFEDA100),
  WorkStatus.review: Color(0xFF4A3AA7),
  WorkStatus.waitInfo: Color(0xFFB8B6AE),
  WorkStatus.cancelled: Color(0xFFD6D4CC),
};

class _BadgeStyle {
  const _BadgeStyle(this.bg, this.fg, this.icon);
  final Color bg;
  final Color fg;
  final String icon;
}

const Map<String, _BadgeStyle> _statusBadge = {
  WorkStatus.notStarted: _BadgeStyle(Color(0xFFF1F5F9), Color(0xFF475569), '○'),
  WorkStatus.inProgress: _BadgeStyle(Color(0xFFEFF6FF), Color(0xFF1D4ED8), '◐'),
  WorkStatus.review: _BadgeStyle(Color(0xFFF5F3FF), Color(0xFF6D28D9), '◔'),
  WorkStatus.waitInfo: _BadgeStyle(Color(0xFFF1F5F9), Color(0xFF475569), '…'),
  WorkStatus.waitDecision:
      _BadgeStyle(Color(0xFFFFFBEB), Color(0xFF92400E), '⚑'),
  WorkStatus.done: _BadgeStyle(Color(0xFFF0FDF4), Color(0xFF166534), '✓'),
  WorkStatus.delayed: _BadgeStyle(Color(0xFFFEF2F2), Color(0xFFB91C1C), '!'),
  WorkStatus.cancelled: _BadgeStyle(Color(0xFFF1F5F9), Color(0xFF64748B), '✕'),
};

const Map<String, _BadgeStyle> _riskBadge = {
  RiskLevel.low: _BadgeStyle(Color(0xFFF0FDF4), Color(0xFF166534), '▁'),
  RiskLevel.medium: _BadgeStyle(Color(0xFFFFFBEB), Color(0xFF92400E), '▃'),
  RiskLevel.high: _BadgeStyle(Color(0xFFFFF1EE), Color(0xFFC2410C), '▅'),
  RiskLevel.critical: _BadgeStyle(Color(0xFFFEF2F2), Color(0xFFB91C1C), '▇'),
};

const Map<String, _BadgeStyle> _deptBadge = {
  'ปกติ': _BadgeStyle(Color(0xFFF0FDF4), Color(0xFF166534), '✓'),
  'เฝ้าระวัง': _BadgeStyle(Color(0xFFFFFBEB), Color(0xFF92400E), '◉'),
  'ต้องติดตาม': _BadgeStyle(Color(0xFFFFF1EE), Color(0xFFC2410C), '⚑'),
  'ต้องเร่งรัด': _BadgeStyle(Color(0xFFFEF2F2), Color(0xFFB91C1C), '⚠'),
};

class _Badge extends StatelessWidget {
  const _Badge(this.style, this.label);
  final _BadgeStyle style;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(999.0),
      ),
      child: Text(
        '${style.icon} $label',
        style: FlutterFlowTheme.of(context).bodySmall.override(
              fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
              color: style.fg,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
              useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
            ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});
  final String status;

  @override
  Widget build(BuildContext context) => _Badge(
      _statusBadge[status] ??
          _BadgeStyle(Color(0xFFF1F5F9), Color(0xFF475569), ''),
      status);
}

class RiskBadge extends StatelessWidget {
  const RiskBadge(this.level, {super.key});
  final String level;

  @override
  Widget build(BuildContext context) => _Badge(
      _riskBadge[level] ??
          _BadgeStyle(Color(0xFFF1F5F9), Color(0xFF475569), ''),
      level);
}

class DeptStatusBadge extends StatelessWidget {
  const DeptStatusBadge(this.status, {super.key});
  final String status;

  @override
  Widget build(BuildContext context) => _Badge(
      _deptBadge[status] ??
          _BadgeStyle(Color(0xFFF1F5F9), Color(0xFF475569), ''),
      status);
}

/// Avatar ของ PM — โหลดรูปจาก network, fallback เป็นตัวอักษรแรกของชื่อ
class PmAvatar extends StatelessWidget {
  const PmAvatar({
    super.key,
    required this.name,
    required this.avatarUrl,
    this.size = 38.0,
  });

  final String name;
  final String avatarUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final initial = name.isEmpty ? '?' : name.substring(0, 1);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.primary.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, _, __) => Center(
          child: Text(
            initial,
            style: theme.titleMedium.override(
              fontFamily: theme.titleMediumFamily,
              color: theme.primary,
              fontSize: size * 0.42,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.titleMediumIsCustom,
            ),
          ),
        ),
      ),
    );
  }
}

/// การ์ด KPI (สเปกข้อ 7.2) — สไตล์เดียวกับ Team Dashboard:
/// icon ในกล่องสีอ่อนด้านซ้าย + ตัวเลข + label, กดเพื่อกรองข้อมูลได้
class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.accent,
    required this.icon,
    this.onTap,
    this.active = false,
  });

  final String label;
  final int value;
  final Color accent;
  final IconData icon;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: active ? accent.withOpacity(0.08) : theme.primaryBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: active ? accent : theme.alternate,
            width: active ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(icon, color: accent, size: 22.0),
            ),
            SizedBox(width: 10.0),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$value',
                    style: theme.headlineMedium.override(
                      fontFamily: theme.headlineMediumFamily,
                      fontSize: 22.0,
                      fontWeight: FontWeight.w700,
                      color: accent,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.headlineMediumIsCustom,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.bodySmall.override(
                      fontFamily: theme.bodySmallFamily,
                      color: theme.secondaryText,
                      fontSize: 12.0,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.bodySmallIsCustom,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DonutSlice {
  const DonutSlice(this.label, this.value, this.color);
  final String label;
  final int value;
  final Color color;
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.slices, this.surface);
  final List<DonutSlice> slices;
  final Color surface;

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<int>(0, (s, d) => s + d.value);
    if (total == 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final stroke = radius * 0.32;
    final rect = Rect.fromCircle(center: center, radius: radius - stroke / 2);

    var start = -math.pi / 2;
    for (final s in slices) {
      final sweep = s.value / total * 2 * math.pi;
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = s.color,
      );
      start += sweep;
    }

    // ช่องว่าง 2px ระหว่าง segment (spacer ตาม mark spec)
    start = -math.pi / 2;
    for (final s in slices) {
      canvas.drawLine(
        center +
            Offset(math.cos(start), math.sin(start)) * (radius - stroke),
        center + Offset(math.cos(start), math.sin(start)) * radius,
        Paint()
          ..strokeWidth = 2.0
          ..color = surface,
      );
      start += s.value / total * 2 * math.pi;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.slices != slices || old.surface != surface;
}

/// Donut สถานะงานรวม (สเปกข้อ 7.3) พร้อมเลขรวมตรงกลาง + legend
class StatusDonut extends StatelessWidget {
  const StatusDonut({
    super.key,
    required this.slices,
    required this.total,
    this.onSelect,
  });

  final List<DonutSlice> slices;
  final int total;
  final ValueChanged<String>? onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 150.0,
          height: 150.0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(150.0, 150.0),
                painter: _DonutPainter(slices, theme.primaryBackground),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$total',
                    style: theme.headlineMedium.override(
                      fontFamily: theme.headlineMediumFamily,
                      fontSize: 28.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.headlineMediumIsCustom,
                    ),
                  ),
                  Text(
                    'งานทั้งหมด',
                    style: theme.bodySmall.override(
                      fontFamily: theme.bodySmallFamily,
                      color: theme.secondaryText,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.bodySmallIsCustom,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: slices
                .map(
                  (s) => InkWell(
                    onTap: onSelect == null ? null : () => onSelect!(s.label),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Container(
                            width: 10.0,
                            height: 10.0,
                            decoration: BoxDecoration(
                              color: s.color,
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              s.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.bodyMedium.override(
                                fontFamily: theme.bodyMediumFamily,
                                letterSpacing: 0.0,
                                useGoogleFonts: !theme.bodyMediumIsCustom,
                              ),
                            ),
                          ),
                          Text(
                            '${s.value}',
                            style: theme.bodyMedium.override(
                              fontFamily: theme.bodyMediumFamily,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.0,
                              useGoogleFonts: !theme.bodyMediumIsCustom,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

/// Bar แนวนอนจำนวนงานแยกตามฝ่าย (สเปกข้อ 7.3)
class DeptBars extends StatelessWidget {
  const DeptBars({super.key, required this.data, this.onSelect});

  final Map<String, int> data;
  final ValueChanged<String>? onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final maxValue =
        data.values.fold<int>(0, math.max).clamp(1, 1 << 30);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: data.entries
          .map(
            (e) => InkWell(
              onTap: onSelect == null ? null : () => onSelect!(e.key),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 120.0,
                      child: Text(
                        e.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.bodySmall.override(
                          fontFamily: theme.bodySmallFamily,
                          color: theme.secondaryText,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) => Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: constraints.maxWidth * e.value / maxValue,
                            height: 16.0,
                            decoration: BoxDecoration(
                              color: Color(0xFF2A78D6),
                              borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(4.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      '${e.value}',
                      style: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodyMediumIsCustom,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

/// กล่อง panel หัวข้อ + เนื้อหา
class DashboardPanel extends StatelessWidget {
  const DashboardPanel({
    super.key,
    required this.title,
    required this.child,
    this.leading,
    this.footnote,
  });

  final String title;
  final Widget child;
  final Widget? leading;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leading != null) ...[leading!, SizedBox(width: 8.0)],
              Expanded(
                child: Text(
                  title,
                  style: theme.titleMedium.override(
                    fontFamily: theme.titleMediumFamily,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.titleMediumIsCustom,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.0),
          child,
          if (footnote != null) ...[
            SizedBox(height: 10.0),
            Text(
              footnote!,
              style: theme.bodySmall.override(
                fontFamily: theme.bodySmallFamily,
                color: theme.secondaryText,
                fontSize: 12.0,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodySmallIsCustom,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Empty state (สเปกข้อ 16.3)
class DashboardEmpty extends StatelessWidget {
  const DashboardEmpty(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Center(
        child: Text(
          message,
          style: theme.bodyMedium.override(
            fontFamily: theme.bodyMediumFamily,
            color: theme.secondaryText,
            letterSpacing: 0.0,
            useGoogleFonts: !theme.bodyMediumIsCustom,
          ),
        ),
      ),
    );
  }
}
