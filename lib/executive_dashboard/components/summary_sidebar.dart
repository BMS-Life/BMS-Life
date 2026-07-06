import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

import '../dashboard_data.dart';
import 'manager_detail_sheet.dart';

// pastel palette ตาม reference
const _kPeach = Color(0xFFF2B48C);
const _kSalmon = Color(0xFFF2938C);
const _kPurple = Color(0xFF7C6FE8);
const _kTeal = Color(0xFF6FE0D2);

/// การ์ด "Task Summary" — กราฟแท่ง pastel + legend จุดสี (ตาม reference
/// Total Amount card)
class TaskSummaryCard extends StatelessWidget {
  const TaskSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final done = works.where((w) => w.status == WorkStatus.done).length;
    final inProgress = works
        .where((w) =>
            w.status == WorkStatus.inProgress ||
            w.status == WorkStatus.review)
        .length;
    final pending = works
        .where((w) =>
            w.status == WorkStatus.delayed ||
            w.status == WorkStatus.notStarted ||
            w.status == WorkStatus.waitInfo ||
            w.status == WorkStatus.waitDecision)
        .length;
    final highRisk = works.where((w) => w.isHighRisk).length;

    final bars = [
      (done, _kPeach, 'เสร็จแล้ว'),
      (inProgress, _kSalmon, 'กำลังทำ'),
      (pending, _kPurple, 'ค้าง / ล่าช้า'),
      (highRisk, _kTeal, 'เสี่ยงสูง'),
    ];
    final maxV = bars.map((b) => b.$1).reduce((a, b) => a > b ? a : b);
    final maxIdx =
        bars.indexWhere((b) => b.$1 == maxV);

    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'สรุปงานสัปดาห์นี้',
                  style: theme.titleMedium.override(
                    fontFamily: theme.titleMediumFamily,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.titleMediumIsCustom,
                  ),
                ),
              ),
              Text(
                'View All',
                style: theme.bodySmall.override(
                  fontFamily: theme.bodySmallFamily,
                  color: theme.secondaryText,
                  fontSize: 12.0,
                  decoration: TextDecoration.underline,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodySmallIsCustom,
                ),
              ),
            ],
          ),
          SizedBox(height: 18.0),
          // bar chart
          SizedBox(
            height: 150.0,
            child: LayoutBuilder(
              builder: (context, c) {
                const chartH = 110.0;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: bars.asMap().entries.map((e) {
                    final (v, color, _) = e.value;
                    final h =
                        maxV == 0 ? 4.0 : (v / maxV) * chartH + 4.0;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (e.key == maxIdx) ...[
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 3.0),
                                decoration: BoxDecoration(
                                  color: Color(0xFF1F2937),
                                  borderRadius: BorderRadius.circular(7.0),
                                ),
                                child: Text(
                                  '$v งาน',
                                  style: theme.bodySmall.override(
                                    fontFamily: theme.bodySmallFamily,
                                    color: Colors.white,
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.0,
                                    useGoogleFonts:
                                        !theme.bodySmallIsCustom,
                                  ),
                                ),
                              ),
                              SizedBox(height: 4.0),
                            ],
                            Container(
                              height: h,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(4.0)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          SizedBox(height: 16.0),
          // legend 2x2
          Row(
            children: [
              _legend(context, bars[0].$3, '${bars[0].$1} งาน', _kPeach),
              _legend(context, bars[1].$3, '${bars[1].$1} งาน', _kSalmon),
            ],
          ),
          SizedBox(height: 12.0),
          Row(
            children: [
              _legend(context, bars[2].$3, '${bars[2].$1} งาน', _kPurple),
              _legend(context, bars[3].$3, '${bars[3].$1} งาน', _kTeal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(
      BuildContext context, String label, String value, Color color) {
    final theme = FlutterFlowTheme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.bodySmall.override(
              fontFamily: theme.bodySmallFamily,
              color: theme.secondaryText,
              fontSize: 12.0,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodySmallIsCustom,
            ),
          ),
          SizedBox(height: 3.0),
          Row(
            children: [
              Container(
                width: 8.0,
                height: 8.0,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: 6.0),
              Text(
                value,
                style: theme.bodyLarge.override(
                  fontFamily: theme.bodyLargeFamily,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodyLargeIsCustom,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// การ์ด "รายงานประจำสัปดาห์" — list แบบ Customer Invoice ใน reference
class WeeklyReportsCard extends StatelessWidget {
  const WeeklyReportsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final submitted =
        managers.where((m) => m.reportSubmitted).take(6).toList();
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'รายงานประจำสัปดาห์',
                  style: theme.titleMedium.override(
                    fontFamily: theme.titleMediumFamily,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.titleMediumIsCustom,
                  ),
                ),
              ),
              Text(
                'View All',
                style: theme.bodySmall.override(
                  fontFamily: theme.bodySmallFamily,
                  color: theme.secondaryText,
                  fontSize: 12.0,
                  decoration: TextDecoration.underline,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodySmallIsCustom,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.0),
          ...submitted.map((m) => _reportRow(context, m)),
        ],
      ),
    );
  }

  Widget _reportRow(BuildContext context, ManagerInfo m) {
    final theme = FlutterFlowTheme.of(context);
    return InkWell(
      onTap: () => showManagerDetailSheet(context, m),
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 7.0),
        child: Row(
          children: [
            Container(
              width: 36.0,
              height: 36.0,
              decoration: BoxDecoration(
                color: Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(Icons.picture_as_pdf_rounded,
                  size: 18.0, color: Color(0xFFD03B3B)),
            ),
            SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'รายงานสัปดาห์ #${WeekInfo.weekNo}',
                    style: theme.bodyMedium.override(
                      fontFamily: theme.bodyMediumFamily,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.bodyMediumIsCustom,
                    ),
                  ),
                  Text(
                    m.name,
                    style: theme.bodySmall.override(
                      fontFamily: theme.bodySmallFamily,
                      color: theme.secondaryText,
                      fontSize: 11.5,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.bodySmallIsCustom,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.download_rounded,
                size: 17.0, color: theme.secondaryText),
          ],
        ),
      ),
    );
  }
}
