import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

import '../dashboard_data.dart';
import 'dashboard_widgets.dart';
import 'manager_detail_sheet.dart';

// สีตาม Figma node 85:193
const _kSegGreen = Color(0xFF21C45D);
const _kSegBlue = Color(0xFF0485F7);
const _kSegGray = Color(0xFFD9D9D9);
const _kFooterGreen = Color(0xFF16833E);
const _kFooterRed = Color(0xFFB3261E);

/// สถานะรวมของ PM — ใช้กับ tab กรองบนหน้า dashboard
enum PmCardStatus { inProgress, pending, delayed, completed }

PmCardStatus pmCardStatus(ManagerInfo m) {
  final ws = works.where((w) => w.manager == m.name).toList();
  if (ws.isNotEmpty && ws.every((w) => w.status == WorkStatus.done)) {
    return PmCardStatus.completed;
  }
  if (ws.any((w) => w.status == WorkStatus.delayed)) {
    return PmCardStatus.delayed;
  }
  if (ws.any((w) =>
      w.status == WorkStatus.notStarted ||
      w.status == WorkStatus.waitDecision ||
      w.status == WorkStatus.waitInfo)) {
    return PmCardStatus.pending;
  }
  return PmCardStatus.inProgress;
}

bool pmPinned(ManagerInfo m) =>
    works.any((w) => w.manager == m.name && w.decisionRequired);

extension PmCardStatusX on PmCardStatus {
  String get label => switch (this) {
        PmCardStatus.inProgress => 'In Progress',
        PmCardStatus.pending => 'Pending',
        PmCardStatus.delayed => 'Delayed',
        PmCardStatus.completed => 'Completed',
      };

  Color get color => switch (this) {
        PmCardStatus.inProgress => Color(0xFF1FA34C),
        PmCardStatus.pending => Color(0xFFC98500),
        PmCardStatus.delayed => Color(0xFFD03B3B),
        PmCardStatus.completed => Color(0xFFEB6834),
      };

  Color get bg => switch (this) {
        PmCardStatus.inProgress => Color(0xFFEAF7EE),
        PmCardStatus.pending => Color(0xFFFFF7E0),
        PmCardStatus.delayed => Color(0xFFFDEDED),
        PmCardStatus.completed => Color(0xFFFDEFE7),
      };
}

/// ผลงานสัปดาห์ก่อนหน้า — สรุปจากชุด mock prevWeekTasks
(int done, int total) prevWeekStats(ManagerInfo m) {
  final tasks = prevWeekTasks(m);
  final done = tasks.where((t) => t.group == 'done').length;
  return (done, tasks.length);
}

/// การ์ด PM ตาม Figma (node 85:193):
/// header avatar + ชื่อ/ฝ่าย + pill "อ่านรายละเอียด" · เส้นประ ·
/// แถบ segment สถานะงานสัปดาห์นี้ / สัปดาห์ก่อนหน้า ·
/// footer สถานะการรายงาน (เขียว = ส่งแล้ว / แดง = ยังไม่ส่ง)
class PmProjectCard extends StatelessWidget {
  const PmProjectCard({super.key, required this.manager});

  final ManagerInfo manager;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final ws = works.where((w) => w.manager == manager.name).toList();
    final doneThisWeek =
        ws.where((w) => w.status == WorkStatus.done).length;
    final (prevDone, prevTotal) = prevWeekStats(manager);

    Color segColor(WorkItem w) {
      if (w.status == WorkStatus.done) return _kSegGreen;
      if (w.status == WorkStatus.inProgress ||
          w.status == WorkStatus.review) {
        return _kSegBlue;
      }
      return _kSegGray;
    }

    return InkWell(
      onTap: () => showManagerDetailSheet(context, manager),
      borderRadius: BorderRadius.circular(24.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: theme.alternate),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- header ----------
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PmAvatar(
                    name: manager.name,
                    avatarUrl: manager.avatarUrl,
                    size: 56.0,
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          manager.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.bodyLarge.override(
                            fontFamily: theme.bodyLargeFamily,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodyLargeIsCustom,
                          ),
                        ),
                        Text(
                          manager.department,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.bodyMedium.override(
                            fontFamily: theme.bodyMediumFamily,
                            fontSize: 14.0,
                            color: Colors.black.withOpacity(0.6),
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodyMediumIsCustom,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.0),
                  // pill อ่านรายละเอียด
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'อ่านรายละเอียด',
                          style: theme.bodySmall.override(
                            fontFamily: theme.bodySmallFamily,
                            fontSize: 12.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodySmallIsCustom,
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded,
                            size: 16.0, color: Colors.black),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.0),
            // ---------- เส้นประ ----------
            CustomPaint(
              size: Size(double.infinity, 1.0),
              painter: _DashedLinePainter(color: Colors.black26),
            ),
            SizedBox(height: 8.0),
            // ---------- สถานะงานประจำสัปดาห์ ----------
            _segmentSection(
              context,
              title: 'สถานะงานประจำสัปดาห์',
              trailing: 'สำเร็จ $doneThisWeek จาก ${ws.length}',
              segments: ws.isEmpty
                  ? [_kSegGray]
                  : ws.map(segColor).toList(),
            ),
            SizedBox(height: 16.0),
            // ---------- งานสัปดาห์ก่อนหน้า ----------
            _segmentSection(
              context,
              title: 'งานสัปดาห์ก่อนหน้า',
              trailing: 'สำเร็จ $prevDone จาก $prevTotal',
              segments: List.generate(
                prevTotal,
                (i) => i < prevDone ? _kSegGreen : _kSegGray,
              ),
            ),
            SizedBox(height: 16.0),
            // ---------- footer สถานะการรายงาน ----------
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: manager.reportSubmitted
                    ? _kFooterGreen
                    : _kFooterRed,
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'สถานะการรายงาน',
                      style: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        fontSize: 14.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodyMediumIsCustom,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      manager.reportSubmitted ? 'ส่งแล้ว' : 'ยังไม่ส่ง',
                      style: theme.bodySmall.override(
                        fontFamily: theme.bodySmallFamily,
                        fontSize: 12.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodySmallIsCustom,
                      ),
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

  Widget _segmentSection(
    BuildContext context, {
    required String title,
    required String trailing,
    required List<Color> segments,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.bodyMedium.override(
                    fontFamily: theme.bodyMediumFamily,
                    fontSize: 14.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodyMediumIsCustom,
                  ),
                ),
              ),
              Text(
                trailing,
                style: theme.bodyMedium.override(
                  fontFamily: theme.bodyMediumFamily,
                  fontSize: 14.0,
                  color: Colors.black.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodyMediumIsCustom,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.0),
          Row(
            children: segments
                .asMap()
                .entries
                .map(
                  (e) => Expanded(
                    child: Container(
                      height: 16.0,
                      margin: EdgeInsets.only(
                          right:
                              e.key == segments.length - 1 ? 0.0 : 8.0),
                      decoration: BoxDecoration(
                        color: e.value,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const dash = 6.0;
    const gap = 4.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}
