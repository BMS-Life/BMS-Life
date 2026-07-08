import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

import '../dashboard_data.dart';
import 'dashboard_widgets.dart';
import 'manager_detail_sheet.dart';

/// การ์ดรายละเอียด PM สไตล์ reference (Customers Details):
/// avatar + ชื่อ + ฝ่าย, Project Name, grid ข้อมูล 6 ช่อง
/// พร้อม Work Status เป็นข้อความสี
class PmDetailCard extends StatelessWidget {
  const PmDetailCard({super.key, required this.manager});

  final ManagerInfo manager;

  List<WorkItem> get _myWorks =>
      works.where((w) => w.manager == manager.name).toList();

  WorkItem? get _mainWork {
    final ws = _myWorks;
    if (ws.isEmpty) return null;
    final attention = ws.where((w) => w.needsAttention).toList();
    return attention.isNotEmpty ? attention.first : ws.first;
  }

  // Work Status รวมของ PM — ข้อความสีแบบ reference
  (String, Color) get _workStatus {
    final ws = _myWorks;
    if (ws.any((w) => w.status == WorkStatus.delayed)) {
      return ('Delayed', Color(0xFFD03B3B));
    }
    if (ws.any((w) =>
        w.status == WorkStatus.notStarted ||
        w.status == WorkStatus.waitDecision)) {
      return ('Pending', Color(0xFFE8930C));
    }
    if (ws.every((w) => w.status == WorkStatus.done)) {
      return ('Done', Color(0xFF1FA34C));
    }
    if (ws.any((w) => w.status == WorkStatus.waitInfo)) {
      return ('On Hold', Color(0xFF8B5CF6));
    }
    return ('Working On', Color(0xFF1E88E5));
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final main = _mainWork;
    final ws = _myWorks;
    final (statusLabel, statusColor) = _workStatus;

    return InkWell(
      onTap: () => showManagerDetailSheet(context, manager),
      borderRadius: BorderRadius.circular(14.0),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: theme.alternate),
          boxShadow: [
            BoxShadow(
              blurRadius: 6.0,
              color: Color(0x0A000000),
              offset: Offset(0.0, 2.0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header: avatar + ชื่อ + ฝ่าย + เมนู
            Row(
              children: [
                PmAvatar(
                  name: manager.name,
                  avatarUrl: manager.avatarUrl,
                  size: 44.0,
                ),
                SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        manager.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.bodyLarge.override(
                          fontFamily: theme.bodyLargeFamily,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodyLargeIsCustom,
                        ),
                      ),
                      Text(
                        manager.department,
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
                Container(
                  width: 30.0,
                  height: 30.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.alternate),
                  ),
                  child: Icon(Icons.more_vert_rounded,
                      size: 16.0, color: theme.secondaryText),
                ),
              ],
            ),
            SizedBox(height: 12.0),
            // Project Name
            Text(
              'Project Name',
              style: theme.bodySmall.override(
                fontFamily: theme.bodySmallFamily,
                color: theme.secondaryText,
                fontSize: 11.5,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodySmallIsCustom,
              ),
            ),
            SizedBox(height: 2.0),
            Text(
              main?.title ?? 'ยังไม่มีงานในสัปดาห์นี้',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodyMediumIsCustom,
              ),
            ),
            SizedBox(height: 12.0),
            // grid ข้อมูล 2 แถว x 3 ช่อง
            Row(
              children: [
                _field(context, 'งานทั้งหมด', '${ws.length} งาน'),
                _field(context, 'Start Date', main?.startDate ?? '—'),
                _field(context, 'End Date', main?.dueDate ?? '—'),
              ],
            ),
            SizedBox(height: 10.0),
            Row(
              children: [
                _field(context, 'Work ID', main != null ? '#${main.id}' : '—'),
                _fieldWidget(
                  context,
                  'คะแนน',
                  Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    showDuration: Duration(seconds: 6),
                    message: 'คะแนน = % งานที่เสร็จจากงานทั้งหมด'
                        'ของสัปดาห์นี้ (เสร็จ ÷ ทั้งหมด × 100)',
                    child: Text(
                      '${manager.score}/100',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodyMediumIsCustom,
                      ),
                    ),
                  ),
                ),
                _fieldWidget(
                  context,
                  'Work Status',
                  Text(
                    statusLabel,
                    style: theme.bodyMedium.override(
                      fontFamily: theme.bodyMediumFamily,
                      color: statusColor,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.bodyMediumIsCustom,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(BuildContext context, String label, String value) {
    final theme = FlutterFlowTheme.of(context);
    return _fieldWidget(
      context,
      label,
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.bodyMedium.override(
          fontFamily: theme.bodyMediumFamily,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.0,
          useGoogleFonts: !theme.bodyMediumIsCustom,
        ),
      ),
    );
  }

  Widget _fieldWidget(BuildContext context, String label, Widget value) {
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
              fontSize: 11.5,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodySmallIsCustom,
            ),
          ),
          SizedBox(height: 2.0),
          value,
        ],
      ),
    );
  }
}
