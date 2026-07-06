import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

import '../dashboard_data.dart';
import 'dashboard_widgets.dart';
import 'pm_weekly_card.dart' show kBandGreen, kBandBlue, kBandRed;
import 'work_detail_sheet.dart';

/// View mode "ตามสถานะ" — Kanban board: คอลัมน์ละ 1 สถานะ
/// ด้านในเป็น task tile พร้อม avatar + ชื่อ PM เจ้าของงาน
class StatusBoard extends StatelessWidget {
  const StatusBoard({super.key, required this.columns});

  final int columns;

  @override
  Widget build(BuildContext context) {
    final done = works.where((w) => w.status == WorkStatus.done).toList();
    final inProgress = works
        .where((w) =>
            w.status == WorkStatus.inProgress ||
            w.status == WorkStatus.review)
        .toList();
    final delayed = works
        .where((w) =>
            w.status == WorkStatus.delayed ||
            w.status == WorkStatus.notStarted ||
            w.status == WorkStatus.waitInfo ||
            w.status == WorkStatus.waitDecision)
        .toList()
      ..sort((a, b) => (b.decisionRequired ? 1 : 0)
          .compareTo(a.decisionRequired ? 1 : 0));

    final groups = [
      _StatusGroup('เสร็จแล้ว (COMPLETED)', kBandGreen, done),
      _StatusGroup('กำลังทำ (IN PROGRESS)', kBandBlue, inProgress),
      _StatusGroup('ล่าช้า / ค้าง (DELAYED)', kBandRed, delayed),
    ];

    if (columns == 1) {
      return Column(
        children: groups
            .map((g) => Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: _StatusColumn(group: g),
                ))
            .toList(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groups
          .asMap()
          .entries
          .map((e) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: e.key == groups.length - 1 ? 0.0 : 10.0),
                  child: _StatusColumn(group: e.value),
                ),
              ))
          .toList(),
    );
  }
}

class _StatusGroup {
  const _StatusGroup(this.label, this.color, this.items);
  final String label;
  final Color color;
  final List<WorkItem> items;
}

class _StatusColumn extends StatelessWidget {
  const _StatusColumn({required this.group});

  final _StatusGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // หัวคอลัมน์สถานะ
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: group.color,
              borderRadius: BorderRadius.vertical(top: Radius.circular(9.0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    group.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.bodyMedium.override(
                      fontFamily: theme.bodyMediumFamily,
                      color: Colors.white,
                      fontSize: 13.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.bodyMediumIsCustom,
                    ),
                  ),
                ),
                Container(
                  width: 24.0,
                  height: 24.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${group.items.length}',
                      style: theme.bodySmall.override(
                        fontFamily: theme.bodySmallFamily,
                        color: group.color,
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
          ),
          // รายการ task + PM
          if (group.items.isEmpty)
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'ไม่มีงานในสถานะนี้',
                  style: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children:
                    group.items.map((w) => _TaskTile(work: w)).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.work});

  final WorkItem work;

  ManagerInfo? get _pm {
    for (final m in managers) {
      if (m.name == work.manager) return m;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final pm = _pm;
    return Padding(
      padding: EdgeInsets.only(bottom: 6.0),
      child: InkWell(
        onTap: () => showWorkDetailSheet(context, work),
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: theme.alternate),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      work.decisionRequired
                          ? '⚑ ${work.title}'
                          : work.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodyMediumIsCustom,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.0),
                  RiskBadge(work.riskLevel),
                ],
              ),
              SizedBox(height: 6.0),
              Row(
                children: [
                  if (pm != null) ...[
                    PmAvatar(
                      name: pm.name,
                      avatarUrl: pm.avatarUrl,
                      size: 20.0,
                    ),
                    SizedBox(width: 6.0),
                  ],
                  Expanded(
                    child: Text(
                      '${work.manager} · ${work.department}',
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
                  ),
                  Text(
                    '${work.progress}%',
                    style: theme.bodySmall.override(
                      fontFamily: theme.bodySmallFamily,
                      color: _statusColorFor(work),
                      fontSize: 11.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.bodySmallIsCustom,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _statusColorFor(WorkItem w) {
  if (w.status == WorkStatus.done) return kBandGreen;
  if (w.status == WorkStatus.inProgress || w.status == WorkStatus.review) {
    return kBandBlue;
  }
  return kBandRed;
}
