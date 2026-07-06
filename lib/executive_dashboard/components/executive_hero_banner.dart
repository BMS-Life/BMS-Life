import '/flutter_flow/flutter_flow_util.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

import '../dashboard_data.dart';

/// Hero banner ของหน้า Executive Dashboard — โครงเดียวกับ
/// booking_hero_banner (การ์ดขาว + gradient ฟ้าด้านขวาบน desktop)
class ExecutiveHeroBanner extends StatelessWidget {
  const ExecutiveHeroBanner({
    super.key,
    required this.totalWork,
    required this.highRisk,
    required this.decision,
  });

  final int totalWork;
  final int highRisk;
  final int decision;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x0D0C0C0D),
            offset: Offset(0.0, 1.0),
          ),
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x1A0C0C0D),
            offset: Offset(0.0, 1.0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 120.0),
          child: Stack(
            children: [
              // Left: Text content
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BMS Executive Project Monitoring Dashboard',
                      style: theme.titleSmall.override(
                        fontFamily: theme.titleSmallFamily,
                        color: theme.primaryText,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        useGoogleFonts: !theme.titleSmallIsCustom,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Opacity(
                      opacity: 0.8,
                      child: Text(
                        'ติดตามภาพรวมแผนงานผู้จัดการและโครงการสำหรับผู้บริหาร',
                        style: theme.bodySmall.override(
                          fontFamily: theme.bodySmallFamily,
                          color: theme.secondaryText,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                    ),
                    SizedBox(height: 6.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 6.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Opacity(
                          opacity: 0.8,
                          child: Text(
                            'รอบรายงาน',
                            style: theme.bodySmall.override(
                              fontFamily: theme.bodySmallFamily,
                              color: theme.secondaryText,
                              letterSpacing: 0.0,
                              useGoogleFonts: !theme.bodySmallIsCustom,
                            ),
                          ),
                        ),
                        _pill(
                          context,
                          'สัปดาห์ที่ ${WeekInfo.weekNo} / ${WeekInfo.year} · ${WeekInfo.dateRange}',
                          Color(0x80000000),
                        ),
                        _pill(context, 'งานทั้งหมด $totalWork',
                            Color(0xB3205295)),
                        if (highRisk > 0)
                          _pill(context, 'เสี่ยงสูง $highRisk',
                              Color(0xB3D03B3B)),
                        if (decision > 0)
                          _pill(context, 'ต้องตัดสินใจ $decision',
                              Color(0xB3C77700)),
                      ],
                    ),
                  ],
                ),
              ),
              // Right: Gradient + chart graphic
              if (responsiveVisibility(
                context: context,
                phone: false,
                tablet: false,
              ))
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 240.0,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          Color(0xFF8FC6FD),
                          Color(0xFF007DFA),
                        ],
                        stops: [0.3038, 0.649, 1.0],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: ClipRect(
                      child: Stack(
                        children: [
                          Positioned(
                            right: 96.0,
                            bottom: -14.0,
                            child: Icon(
                              Icons.pie_chart_rounded,
                              size: 88.0,
                              color: Color(0x33FFFFFF),
                            ),
                          ),
                          Positioned(
                            right: 20.0,
                            top: 10.0,
                            child: Icon(
                              Icons.insights_rounded,
                              size: 116.0,
                              color: Color(0xE6FFFFFF),
                            ),
                          ),
                          Positioned(
                            right: 130.0,
                            top: 6.0,
                            child: Icon(
                              Icons.leaderboard_rounded,
                              size: 44.0,
                              color: Color(0x59FFFFFF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(BuildContext context, String label, Color bg) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100.0),
      ),
      padding: EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 12.0, 4.0),
      child: Text(
        label,
        style: theme.bodySmall.override(
          fontFamily: theme.bodySmallFamily,
          color: Color(0xFFF5F8FB),
          letterSpacing: 0.0,
          fontWeight: FontWeight.w600,
          useGoogleFonts: !theme.bodySmallIsCustom,
        ),
      ),
    );
  }
}
