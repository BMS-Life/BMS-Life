import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

import '../dashboard_data.dart';
import 'dashboard_widgets.dart';
import 'manager_detail_sheet.dart';
import 'pm_weekly_card.dart';
import 'work_detail_sheet.dart';

/// Executive Alert View (mobile) ตาม mockup —
/// รายการ Critical Alerts เรียงตาม PM: แถวแดง = งานค้าง/ล่าช้า/เสี่ยงสูง
/// พร้อมผลกระทบและ Next Action, แถวเขียว = สรุปงานที่ปกติ
class ExecutiveAlertView extends StatelessWidget {
  const ExecutiveAlertView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Executive Alert View',
          style: theme.titleMedium.override(
            fontFamily: theme.titleMediumFamily,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.0,
            useGoogleFonts: !theme.titleMediumIsCustom,
          ),
        ),
        SizedBox(height: 2.0),
        Text(
          'Critical Alerts · สัปดาห์ที่ ${WeekInfo.weekNo} / ${WeekInfo.year}',
          style: theme.bodySmall.override(
            fontFamily: theme.bodySmallFamily,
            color: theme.secondaryText,
            letterSpacing: 0.0,
            useGoogleFonts: !theme.bodySmallIsCustom,
          ),
        ),
        SizedBox(height: 10.0),
        ...managers.map((m) => _PmAlertGroup(manager: m)),
      ],
    );
  }
}

class _PmAlertGroup extends StatelessWidget {
  const _PmAlertGroup({required this.manager});

  final ManagerInfo manager;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final ws = works.where((w) => w.manager == manager.name).toList();
    final alerts = ws.where((w) => w.needsAttention).toList()
      ..sort((a, b) => (b.decisionRequired ? 1 : 0)
          .compareTo(a.decisionRequired ? 1 : 0));
    final normal = ws.length - alerts.length;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // หัวกลุ่ม: โปรไฟล์ PM
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
                    size: 32.0,
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          manager.name,
                          style: theme.bodyMedium.override(
                            fontFamily: theme.bodyMediumFamily,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodyMediumIsCustom,
                          ),
                        ),
                        Text(
                          '${manager.department} · ${ws.length} งาน',
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
                  Icon(Icons.chevron_right_rounded,
                      color: theme.secondaryText, size: 20.0),
                ],
              ),
            ),
          ),
          // แถว alert แดง
          ...alerts.map(
            (w) => InkWell(
              onTap: () => showWorkDetailSheet(context, w),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  border: Border(
                    left: BorderSide(color: kBandRed, width: 3.0),
                    top: BorderSide(color: Color(0xFFFECACA)),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${w.decisionRequired ? "⚑ " : ""}${w.title} · ${w.status}',
                      style: theme.bodySmall.override(
                        fontFamily: theme.bodySmallFamily,
                        color: Color(0xFFB91C1C),
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodySmallIsCustom,
                      ),
                    ),
                    if (w.impact.isNotEmpty)
                      Text(
                        'Impact: ${w.impact}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.bodySmall.override(
                          fontFamily: theme.bodySmallFamily,
                          color: theme.secondaryText,
                          fontSize: 11.5,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                    Text(
                      'Next: ${w.nextAction}',
                      maxLines: 2,
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
                  ],
                ),
              ),
            ),
          ),
          // แถวเขียว: งานปกติ
          if (normal > 0)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: Color(0xFFF0FDF4),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(10.0)),
                border: Border(
                  left: BorderSide(color: kBandGreen, width: 3.0),
                  top: BorderSide(color: Color(0xFFBBF7D0)),
                ),
              ),
              child: Text(
                '✓ ตามแผน $normal งาน',
                style: theme.bodySmall.override(
                  fontFamily: theme.bodySmallFamily,
                  color: Color(0xFF166534),
                  fontWeight: FontWeight.w600,
                  fontSize: 12.0,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodySmallIsCustom,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
