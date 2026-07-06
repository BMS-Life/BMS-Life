import '/flutter_flow/flutter_flow_util.dart';
import '/executive_dashboard/pm_detail/pm_detail_page_widget.dart';
import 'package:flutter/material.dart';

import '../dashboard_data.dart';

/// Drill-down รายผู้จัดการ — เปิดหน้า PM Detail (เนื้อหาแบบ drawer เดิม
/// ยกไปเป็นหน้าเต็มแล้ว) — ชื่อฟังก์ชันคงเดิมเพื่อไม่ต้องแก้ทุกจุดที่เรียก
Future<void> showManagerDetailSheet(
    BuildContext context, ManagerInfo m) async {
  context.pushNamed(
    PmDetailPageWidget.routeName,
    queryParameters: {'id': m.id},
  );
}
