import '/flutter_flow/flutter_flow_util.dart';
import '/executive_dashboard/work_detail/work_detail_page_widget.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

import '../dashboard_data.dart';
import 'dashboard_widgets.dart';

/// Drill-down รายละเอียดงาน — เปิดเป็นหน้าเต็ม (Work Detail Page)
/// ชื่อฟังก์ชันคงเดิมเพื่อไม่ต้องแก้ทุกจุดที่เรียก
Future<void> showWorkDetailSheet(BuildContext context, WorkItem work) async {
  context.pushNamed(
    WorkDetailPageWidget.routeName,
    queryParameters: {'id': work.id},
  );
}

class WorkDetailSheet extends StatelessWidget {
  const WorkDetailSheet({super.key, required this.work});

  final WorkItem work;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            20.0, 16.0, 20.0, MediaQuery.paddingOf(context).bottom + 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: theme.alternate,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        work.title,
                        style: theme.headlineSmall.override(
                          fontFamily: theme.headlineSmallFamily,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.headlineSmallIsCustom,
                        ),
                      ),
                      SizedBox(height: 2.0),
                      Text(
                        '${work.id} · ${work.project}',
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
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: theme.secondaryText),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                StatusBadge(work.status),
                RiskBadge(work.riskLevel),
                if (work.decisionRequired)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(999.0),
                    ),
                    child: Text(
                      '⚑ ต้องให้ MD / CEO ตัดสินใจ',
                      style: theme.bodySmall.override(
                        fontFamily: theme.bodySmallFamily,
                        color: Color(0xFF92400E),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodySmallIsCustom,
                      ),
                    ),
                  ),
              ],
            ),
            if (work.status == WorkStatus.delayed) ...[
              SizedBox(height: 12.0),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Color(0xFFFECACA)),
                ),
                child: Text(
                  '! งานล่าช้ากว่าแผน — เกินกำหนด Due Date ${work.dueDate} ต้องติดตามใกล้ชิด',
                  style: theme.bodyMedium.override(
                    fontFamily: theme.bodyMediumFamily,
                    color: Color(0xFFB91C1C),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodyMediumIsCustom,
                  ),
                ),
              ),
            ],
            SizedBox(height: 16.0),
            _infoGrid(context),
            SizedBox(height: 16.0),
            _progress(context),
            ..._blocks(context),
            if (work.decisionRequired && work.escalationNote.isNotEmpty) ...[
              SizedBox(height: 14.0),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Color(0xFFFED7AA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚑ ต้องการผู้บริหารช่วย',
                      style: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        color: Color(0xFF9A3412),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodyMediumIsCustom,
                      ),
                    ),
                    SizedBox(height: 3.0),
                    Text(
                      work.escalationNote,
                      style: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodyMediumIsCustom,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 14.0),
            Text(
              'อัปเดตล่าสุด ${work.updatedAt}',
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
    );
  }

  Widget _infoGrid(BuildContext context) {
    final items = <MapEntry<String, String>>[
      MapEntry('ฝ่าย', work.department),
      MapEntry('ผู้รับผิดชอบ', work.owner),
      MapEntry('ผู้จัดการ', work.manager),
      MapEntry('สัปดาห์ที่รายงาน', '${work.weekNo}'),
      MapEntry('วันที่เริ่ม', work.startDate ?? 'ยังไม่กำหนด'),
      MapEntry('Due Date', work.dueDate),
    ];
    final theme = FlutterFlowTheme.of(context);
    return Wrap(
      spacing: 16.0,
      runSpacing: 10.0,
      children: items
          .map(
            (e) => SizedBox(
              width: (MediaQuery.sizeOf(context).width - 56.0) / 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.key,
                    style: theme.bodySmall.override(
                      fontFamily: theme.bodySmallFamily,
                      color: theme.secondaryText,
                      fontSize: 12.0,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.bodySmallIsCustom,
                    ),
                  ),
                  Text(
                    e.value,
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
          )
          .toList(),
    );
  }

  Widget _progress(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ความคืบหน้า ${work.progress}%',
          style: theme.bodySmall.override(
            fontFamily: theme.bodySmallFamily,
            color: theme.secondaryText,
            fontSize: 12.0,
            letterSpacing: 0.0,
            useGoogleFonts: !theme.bodySmallIsCustom,
          ),
        ),
        SizedBox(height: 6.0),
        ClipRRect(
          borderRadius: BorderRadius.circular(999.0),
          child: LinearProgressIndicator(
            value: work.progress / 100.0,
            minHeight: 8.0,
            backgroundColor: theme.alternate,
            valueColor: AlwaysStoppedAnimation(Color(0xFF2A78D6)),
          ),
        ),
      ],
    );
  }

  List<Widget> _blocks(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final blocks = <MapEntry<String, String>>[
      MapEntry('ปัญหาที่พบ', work.problem),
      MapEntry('วิธีการแก้ไข', work.solution),
      MapEntry('สรุปผล', work.summary),
      MapEntry('Next Action', work.nextAction),
      MapEntry('ผลกระทบ', work.impact),
    ].where((e) => e.value.isNotEmpty);
    return blocks
        .map<Widget>(
          (e) => Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.key,
                  style: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    color: theme.secondaryText,
                    fontSize: 12.0,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  ),
                ),
                SizedBox(height: 3.0),
                Text(
                  e.value,
                  style: theme.bodyMedium.override(
                    fontFamily: theme.bodyMediumFamily,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodyMediumIsCustom,
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }
}
