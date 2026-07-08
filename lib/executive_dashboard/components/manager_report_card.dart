import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

import '../dashboard_data.dart';
import 'dashboard_widgets.dart';
import 'manager_detail_sheet.dart';
import 'work_detail_sheet.dart';

/// การ์ดโปรไฟล์ Project Manager + task ประจำสัปดาห์ด้านใน
/// โครงตาม reference: หัวการ์ด (status dot + ชื่อ + chip คะแนน)
/// รายการ task พร้อม progress bar แบบมี % pill ลอยตามตำแหน่ง
class ManagerReportCard extends StatelessWidget {
  const ManagerReportCard({super.key, required this.manager});

  final ManagerInfo manager;

  List<WorkItem> get _myWorks => works
      .where((w) => w.manager == manager.name)
      .toList()
    ..sort((a, b) => (b.needsAttention ? 1 : 0) - (a.needsAttention ? 1 : 0));

  // สีสรุปสถานะของ PM: แดง = มีงานค้าง/ล่าช้า, เหลือง = มีเสี่ยงสูง, เขียว = ปกติ
  Color get _statusColor {
    final ws = _myWorks;
    if (ws.any((w) =>
        w.status == WorkStatus.notStarted || w.status == WorkStatus.delayed)) {
      return Color(0xFFD03B3B);
    }
    if (ws.any((w) => w.isHighRisk)) return Color(0xFFEDA100);
    return Color(0xFF0CA30C);
  }

  Color get _scoreColor {
    if (manager.score >= 85) return Color(0xFF0CA30C);
    if (manager.score >= 70) return Color(0xFFC77700);
    return Color(0xFFD03B3B);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final ws = _myWorks;

    return Container(
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- Header: โปรไฟล์ PM ----------
          InkWell(
            onTap: () => showManagerDetailSheet(context, manager),
            borderRadius: BorderRadius.vertical(top: Radius.circular(14.0)),
            child: Padding(
              padding: EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 10.0),
              child: Row(
                children: [
                  Container(
                    width: 10.0,
                    height: 10.0,
                    decoration: BoxDecoration(
                      color: _statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: theme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        manager.name.replaceAll('นาย ', '').substring(0, 1),
                        style: theme.titleMedium.override(
                          fontFamily: theme.titleMediumFamily,
                          color: theme.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.titleMediumIsCustom,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          manager.name,
                          style: theme.bodyLarge.override(
                            fontFamily: theme.bodyLargeFamily,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodyLargeIsCustom,
                          ),
                        ),
                        Text(
                          '${manager.department} · ${manager.reportSubmitted ? "ส่งรายงานแล้ว" : "ยังไม่ส่งรายงาน"}',
                          style: theme.bodySmall.override(
                            fontFamily: theme.bodySmallFamily,
                            color: manager.reportSubmitted
                                ? theme.secondaryText
                                : Color(0xFFB91C1C),
                            fontSize: 12.0,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodySmallIsCustom,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // chip คะแนน (ตำแหน่งเดียวกับ Days Left ใน reference)
                  Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    showDuration: Duration(seconds: 6),
                    message: 'คะแนน = % งานที่เสร็จจากงานทั้งหมด'
                        'ของสัปดาห์นี้ (เสร็จ ÷ ทั้งหมด × 100)',
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: _scoreColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${manager.score}',
                            style: theme.titleMedium.override(
                              fontFamily: theme.titleMediumFamily,
                              color: _scoreColor,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.0,
                              useGoogleFonts: !theme.titleMediumIsCustom,
                            ),
                          ),
                          Text(
                            'คะแนน',
                            style: theme.bodySmall.override(
                              fontFamily: theme.bodySmallFamily,
                              color: _scoreColor,
                              fontSize: 10.0,
                              letterSpacing: 0.0,
                              useGoogleFonts: !theme.bodySmallIsCustom,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1.0, color: theme.alternate),
          // ---------- Body: task ประจำสัปดาห์ ----------
          if (ws.isEmpty)
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined,
                        color: theme.secondaryText, size: 28.0),
                    SizedBox(height: 6.0),
                    Text(
                      'ยังไม่มีข้อมูล',
                      style: theme.bodySmall.override(
                        fontFamily: theme.bodySmallFamily,
                        color: theme.secondaryText,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodySmallIsCustom,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.fromLTRB(14.0, 4.0, 14.0, 12.0),
              child: Column(
                children: ws.map((w) => _TaskRow(work: w)).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.work});

  final WorkItem work;

  Color get _progressColor {
    if (work.status == WorkStatus.done) return Color(0xFF0CA30C);
    if (work.status == WorkStatus.delayed) return Color(0xFFEB6834);
    if (work.status == WorkStatus.notStarted) return Color(0xFFD03B3B);
    if (work.progress >= 60) return Color(0xFF2A78D6);
    return Color(0xFFEDA100);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return InkWell(
      onTap: () => showWorkDetailSheet(context, work),
      borderRadius: BorderRadius.circular(10.0),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(
                    color: statusColors[work.status] ?? Color(0xFF898781),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    work.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.bodyMedium.override(
                      fontFamily: theme.bodyMediumFamily,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.bodyMediumIsCustom,
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                RiskBadge(work.riskLevel),
              ],
            ),
            SizedBox(height: 4.0),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                work.startDate == null
                    ? 'ยังไม่กำหนดวันเริ่ม  |  Due: ${work.dueDate}'
                    : 'เริ่ม: ${work.startDate}  |  Due: ${work.dueDate}',
                style: theme.bodySmall.override(
                  fontFamily: theme.bodySmallFamily,
                  color: theme.secondaryText,
                  fontSize: 11.5,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodySmallIsCustom,
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: _ProgressWithPill(
                progress: work.progress,
                color: _progressColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Progress bar แบบ reference — pill % ลอยตามตำแหน่งความคืบหน้า
class _ProgressWithPill extends StatelessWidget {
  const _ProgressWithPill({required this.progress, required this.color});

  final int progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return SizedBox(
      height: 24.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          const pillW = 44.0;
          final x = (w - pillW) * progress / 100.0;
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 6.0,
                decoration: BoxDecoration(
                  color: theme.alternate,
                  borderRadius: BorderRadius.circular(999.0),
                ),
              ),
              Container(
                height: 6.0,
                width: w * progress / 100.0,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999.0),
                ),
              ),
              Positioned(
                left: x,
                child: Container(
                  width: pillW,
                  padding: EdgeInsets.symmetric(vertical: 2.0),
                  decoration: BoxDecoration(
                    color: theme.primaryBackground,
                    borderRadius: BorderRadius.circular(999.0),
                    border: Border.all(color: color, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4.0,
                        color: Color(0x22000000),
                        offset: Offset(0.0, 1.0),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$progress%',
                      style: theme.bodySmall.override(
                        fontFamily: theme.bodySmallFamily,
                        color: color,
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodySmallIsCustom,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
