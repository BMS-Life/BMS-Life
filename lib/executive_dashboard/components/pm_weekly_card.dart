import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

import '../dashboard_data.dart';
import 'dashboard_widgets.dart';
import 'manager_detail_sheet.dart';
import 'work_detail_sheet.dart';

const Color kBandGreen = Color(0xFF1FA34C);
const Color kBandBlue = Color(0xFF1E88E5);
const Color kBandRed = Color(0xFFD32F2F);

/// การ์ด "Individual PM Weekly Focus" ตาม mockup:
/// avatar + ชื่อ PM ด้านบน, แถบสถานะ 3 สี (เสร็จแล้ว / กำลังทำ / ล่าช้า)
/// พร้อมจำนวนและรายการงานในแถบ, ปิดท้ายด้วยบรรทัด Summary
class PmWeeklyCard extends StatelessWidget {
  const PmWeeklyCard({
    super.key,
    required this.manager,
    required this.index,
  });

  final ManagerInfo manager;
  final int index;

  List<WorkItem> get _myWorks =>
      works.where((w) => w.manager == manager.name).toList();

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final ws = _myWorks;
    final done =
        ws.where((w) => w.status == WorkStatus.done).toList();
    final delayed =
        ws.where((w) => w.status == WorkStatus.delayed).toList();
    final pending = ws
        .where((w) =>
            w.status == WorkStatus.notStarted ||
            w.status == WorkStatus.waitInfo ||
            w.status == WorkStatus.waitDecision)
        .toList();
    final inProgress = ws
        .where((w) =>
            w.status == WorkStatus.inProgress ||
            w.status == WorkStatus.review)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: theme.alternate),
        boxShadow: [
          BoxShadow(
            blurRadius: 3.0,
            color: Color(0x14000000),
            offset: Offset(0.0, 1.0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- โปรไฟล์ PM ----------
          InkWell(
            onTap: () => showManagerDetailSheet(context, manager),
            borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                children: [
                  PmAvatar(
                    name: manager.name,
                    avatarUrl: manager.avatarUrl,
                    size: 38.0,
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$index. ${manager.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.bodyMedium.override(
                            fontFamily: theme.bodyMediumFamily,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodyMediumIsCustom,
                          ),
                        ),
                        Text(
                          '(PM$index · ${manager.department})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.bodySmall.override(
                            fontFamily: theme.bodySmallFamily,
                            color: theme.secondaryText,
                            fontSize: 11.0,
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
          ),
          // ---------- แถบสถานะ ----------
          Padding(
            padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
            child: Column(
              children: [
                _StatusBand(
                  color: kBandGreen,
                  label: 'เสร็จแล้ว (COMPLETED)',
                  items: done,
                ),
                SizedBox(height: 6.0),
                _StatusBand(
                  color: kBandBlue,
                  label: 'กำลังทำ (IN PROGRESS)',
                  items: inProgress,
                ),
                SizedBox(height: 6.0),
                _StatusBand(
                  color: kBandRed,
                  label: 'ล่าช้า / ค้าง (DELAYED)',
                  items: [...delayed, ...pending],
                ),
                SizedBox(height: 8.0),
                Text(
                  'Summary: ${done.length} เสร็จ · ${inProgress.length} กำลังทำ · ${delayed.length + pending.length} ค้าง',
                  style: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    color: theme.primary,
                    fontWeight: FontWeight.w700,
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
    );
  }
}

class _StatusBand extends StatelessWidget {
  const _StatusBand({
    required this.color,
    required this.label,
    required this.items,
  });

  final Color color;
  final String label;
  final List<WorkItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  ),
                ),
              ),
              Container(
                width: 22.0,
                height: 22.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${items.length}',
                    style: theme.bodySmall.override(
                      fontFamily: theme.bodySmallFamily,
                      color: color,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.bodySmallIsCustom,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (items.isNotEmpty) ...[
            SizedBox(height: 6.0),
            ...items.map(
              (w) => Padding(
                padding: EdgeInsets.only(top: 2.0),
                child: InkWell(
                  onTap: () => showWorkDetailSheet(context, w),
                  borderRadius: BorderRadius.circular(6.0),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      w.decisionRequired ? '⚑ ${w.title}' : w.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.bodySmall.override(
                        fontFamily: theme.bodySmallFamily,
                        color: Color(0xFF1F2937),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodySmallIsCustom,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
