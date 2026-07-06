import 'dart:math' as math;

import '/components/sidebar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/executive_dashboard/dashboard_data.dart';
import '/executive_dashboard/components/dashboard_widgets.dart';
import '/executive_dashboard/components/manager_detail_sheet.dart';
import '/executive_dashboard/components/top_performers.dart';
import '/executive_dashboard/components/work_detail_sheet.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'executive_dashboard_model.dart';
export 'executive_dashboard_model.dart';

// design tokens ตาม reference
const _kBlue = Color(0xFF2158E5);
const _kInk = Color(0xFF17181C);
const _kMuted = Color(0xFF8A8F98);
const _kCardRadius = 20.0;

/// BMS Executive Project Monitoring Dashboard — SaaS layout:
/// แถวบน (greeting + need attention + report queue),
/// PM Pipeline (stage + รายชื่อ) + คอลัมน์ขวา (CTA + อัตราส่งรายงาน)
class ExecutiveDashboardWidget extends StatefulWidget {
  const ExecutiveDashboardWidget({super.key});

  static String routeName = 'executive-dashboard';
  static String routePath = '/executiveDashboard';

  @override
  State<ExecutiveDashboardWidget> createState() =>
      _ExecutiveDashboardWidgetState();
}

class _ExecutiveDashboardWidgetState extends State<ExecutiveDashboardWidget> {
  late ExecutiveDashboardModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  int _stage = 0; // index ของ stat card ที่เลือก (default: ทั้งหมด)
  String _pipelineSearch = '';
  String _rateSearch = '';
  int _rateFilter = 0; // 0=ทั้งหมด 1=ส่งแล้ว 2=ยังไม่ส่ง
  int _fYear = 2569;
  String _fMonth = 'ก.ค.';
  String _fWeek = 'ทั้งเดือน';
  String _fDept = 'ทุกแผนก';
  final Set<String> _collapsedPms = {};
  final ScrollController _pipelineCtrl = ScrollController();
  final Map<String, bool> _pmWeekThis = {};
  final Map<String, bool> _pmGroupOpen = {};
  String? _hoverPm; // PM ที่เมาส์ hover อยู่ (โชว์ปุ่มดูรายละเอียด)

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ExecutiveDashboardModel());
    pinnedPms.addListener(_onPinChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  void _onPinChanged() => safeSetState(() {});

  @override
  void dispose() {
    pinnedPms.removeListener(_onPinChanged);
    _model.dispose();
    _pipelineCtrl.dispose();

    super.dispose();
  }

  /* ---------- stat cards (สถานะรายงานของ PM) ---------- */

  List<
      ({
        String label,
        int count,
        IconData icon,
        Color color,
        Color bg,
        List<WorkItem> items
      })> get _stages {
    List<WorkItem> byPmStatus(String status) => works.where((w) {
          final m = _pmOf(w.manager);
          return m != null && m.reportStatus == status;
        }).toList();
    int pmCountOf(String status) =>
        managers.where((m) => m.reportStatus == status).length;
    return [
      (
        label: 'ทั้งหมด',
        count: managers.length,
        icon: Icons.groups_rounded,
        color: Color(0xFF1D2A4D),
        bg: Color(0xFFE9EBF2),
        items: works,
      ),
      (
        label: 'ส่งแล้ว',
        count: pmCountOf('sent'),
        icon: Icons.check_circle_rounded,
        color: Color(0xFF14804A),
        bg: Color(0xFFE3F5EB),
        items: byPmStatus('sent'),
      ),
      (
        label: 'ฉบับร่าง',
        count: pmCountOf('draft'),
        icon: Icons.edit_note_rounded,
        color: Color(0xFFE8930C),
        bg: Color(0xFFFDF3E3),
        items: byPmStatus('draft'),
      ),
      (
        label: 'ยังไม่ส่ง',
        count: pmCountOf('none'),
        icon: Icons.warning_amber_rounded,
        color: Color(0xFFD03B3B),
        bg: Color(0xFFFDEDED),
        items: byPmStatus('none'),
      ),
    ];
  }

  ManagerInfo? _pmOf(String name) {
    for (final m in managers) {
      if (m.name == name) return m;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final showSidebar = responsiveVisibility(
      context: context,
      phone: false,
      tablet: false,
      tabletLandscape: false,
    );
    return Material(
      color: Color(0xFFEDEEF1),
      child: Stack(
        children: [
          Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showSidebar)
            wrapWithModel(
              model: _model.sidebarModel,
              updateCallback: () => safeSetState(() {}),
              child: SidebarWidget(),
            ),
          Expanded(
            child: Column(
              children: [
                if (!showSidebar) _buildMobileAppBar(context),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final wide = w >= 1080.0;
                      final mid = w >= 720.0;
                      final topRow = mid
                          ? IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                      flex: 5,
                                      child: _greetingCard(context)),
                                  SizedBox(width: 14.0),
                                  Expanded(
                                      flex: 3,
                                      child: _attentionCard(context)),
                                  SizedBox(width: 14.0),
                                  Expanded(
                                      flex: 3, child: _queueCard(context)),
                                ],
                              ),
                            )
                          : null;
                      if (wide) {
                        // จอกว้าง: pipeline ยืดเต็มความสูงที่เหลือของจอ
                        return Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              topRow!,
                              SizedBox(height: 14.0),
                              Expanded(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                        child: _pipelineCard(context,
                                            fill: true)),
                                    SizedBox(width: 14.0),
                                    SizedBox(
                                      width: 300.0,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            TopPerformers(compact: true),
                                            SizedBox(height: 14.0),
                                            _reportRateCard(context),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return SingleChildScrollView(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (topRow != null)
                              topRow
                            else ...[
                              _greetingCard(context),
                              SizedBox(height: 14.0),
                              _attentionCard(context),
                              SizedBox(height: 14.0),
                              _queueCard(context),
                            ],
                            SizedBox(height: 14.0),
                            _pipelineCard(context),
                            SizedBox(height: 14.0),
                            TopPerformers(compact: true),
                            SizedBox(height: 14.0),
                            _reportRateCard(context),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
          ),
          // FAB ปักหมุด PM
          Positioned(
            right: 24.0,
            bottom: 24.0,
            child: FloatingActionButton.extended(
              onPressed: () => _openPinSheet(context),
              backgroundColor: _kBlue,
              foregroundColor: Colors.white,
              elevation: 4.0,
              icon: Icon(Icons.push_pin_rounded, size: 20.0),
              label: Text(
                'ปักหมุด PM',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* ---------- ปักหมุด PM ---------- */

  Future<void> _openPinSheet(BuildContext context) {
    var q = '';
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      constraints: BoxConstraints(maxWidth: 460.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) {
          final list = managers
              .where((m) =>
                  q.isEmpty ||
                  ('' + m.name + ' ' + m.position + ' ' + m.department)
                      .toLowerCase()
                      .contains(q.toLowerCase()))
              .toList()
            ..sort((a, b) {
              final pa = pinnedPms.value.contains(a.id) ? 0 : 1;
              final pb = pinnedPms.value.contains(b.id) ? 0 : 1;
              return pa - pb;
            });
          return SafeArea(
            child: Container(
              height: MediaQuery.sizeOf(context).height * 0.7,
              padding: EdgeInsets.fromLTRB(20.0, 14.0, 20.0, 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.0,
                      height: 4.0,
                      decoration: BoxDecoration(
                        color: Color(0xFFE4E5E9),
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.0),
                  Row(
                    children: [
                      Icon(Icons.push_pin_rounded,
                          size: 18.0, color: Color(0xFFEB6834)),
                      SizedBox(width: 6.0),
                      Text(
                        'ปักหมุด PM',
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w700,
                          color: _kInk,
                        ),
                      ),
                      SizedBox(width: 8.0),
                      ValueListenableBuilder<Set<String>>(
                        valueListenable: pinnedPms,
                        builder: (context, pins, _) => Text(
                          'ปักไว้ ${pins.length} คน',
                          style:
                              TextStyle(fontSize: 12.5, color: _kMuted),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  _searchBox(
                    width: double.infinity,
                    hint: 'ค้นหาชื่อ PM...',
                    value: q,
                    onChanged: (v) => setSheet(() => q = v),
                  ),
                  SizedBox(height: 8.0),
                  Expanded(
                    child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final m = list[i];
                        final pinned = pinnedPms.value.contains(m.id);
                        return InkWell(
                          onTap: () {
                            togglePinPm(m.id);
                            setSheet(() {});
                          },
                          borderRadius: BorderRadius.circular(10.0),
                          child: Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                PmAvatar(
                                    name: m.name,
                                    avatarUrl: m.avatarUrl,
                                    size: 34.0),
                                SizedBox(width: 10.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m.name,
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: _kInk,
                                        ),
                                      ),
                                      Text(
                                        m.position,
                                        style: TextStyle(
                                            fontSize: 11.5,
                                            color: _kMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  pinned
                                      ? Icons.push_pin_rounded
                                      : Icons.push_pin_outlined,
                                  size: 20.0,
                                  color: pinned
                                      ? Color(0xFFEB6834)
                                      : Color(0xFFB4B8BF),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileAppBar(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.fromSTEB(
          4.0, MediaQuery.paddingOf(context).top + 10.0, 16.0, 10.0),
      decoration: BoxDecoration(color: theme.primary),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.safePop(),
            icon:
                Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22.0),
          ),
          Expanded(
            child: Text(
              'Executive Dashboard',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.titleSmall.override(
                fontFamily: theme.titleSmallFamily,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.titleSmallIsCustom,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* ---------- shared ---------- */

  BoxDecoration get _card => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_kCardRadius),
      );

  Widget _pill(String label, Color fg, Color bg) => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999.0),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 12.5, fontWeight: FontWeight.w600, color: fg),
        ),
      );

  Widget _avatarStack(List<ManagerInfo> ms, {double size = 34.0}) {
    final show = ms.take(5).toList();
    final extra = ms.length - show.length;
    final n = show.length + (extra > 0 ? 1 : 0);
    if (n == 0) return SizedBox.shrink();
    return SizedBox(
      height: size + 4.0, // เผื่อขอบขาว 2px บน-ล่าง ไม่ให้โดน clip
      width: size + (n - 1) * (size * 0.7) + 4.0,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ...show.asMap().entries.map(
                (e) => Positioned(
                  left: e.key * size * 0.7,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.0),
                    ),
                    child: PmAvatar(
                      name: e.value.name,
                      avatarUrl: e.value.avatarUrl,
                      size: size,
                    ),
                  ),
                ),
              ),
          if (extra > 0)
            Positioned(
              left: show.length * size * 0.7,
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(0xFFE9EBEF),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.0),
                ),
                child: Text(
                  '+$extra',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: _kInk,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /* ---------- card 1: greeting ---------- */

  Widget _greetingCard(BuildContext context) {
    final doneThisWeek =
        works.where((w) => w.status == WorkStatus.done).length;
    return Container(
      decoration: _card,
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, c) => Stack(
        children: [
          // ภาพ hero มุมขวาล่าง — ซ่อนเมื่อการ์ดแคบ (ทับข้อความ)
          if (c.maxWidth >= 460.0)
            Positioned(
              right: 0.0,
              bottom: -26.0, // จมลงใต้ขอบการ์ด ให้โต๊ะโดน crop
              child: Image.asset(
                'assets/images/pm-monitor-hero.png',
                height: 148.0,
                fit: BoxFit.contain,
              ),
            ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'สวัสดี,\nคณิณภณ ภูริชธนันท์',
                  style: TextStyle(
                    fontSize: 21.0,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    color: _kInk,
                  ),
                ),
                Spacer(),
                _pill('+$doneThisWeek เสร็จสัปดาห์นี้', Color(0xFF14804A),
                    Color(0xFFE3F5EB)),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  /* ---------- card 2: need attention ---------- */

  Widget _attentionCard(BuildContext context) {
    final delayedWorks =
        works.where((w) => w.status == WorkStatus.delayed).toList();
    final pms = delayedWorks
        .map((w) => _pmOf(w.manager))
        .whereType<ManagerInfo>()
        .toSet()
        .toList();
    return InkWell(
      onTap: () => _openAttentionSheet(context, pms),
      borderRadius: BorderRadius.circular(_kCardRadius),
      child: Container(
      decoration: _card,
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${pms.length} PM\nต้องติดตาม',
                  style: TextStyle(
                    fontSize: 19.0,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    color: _kInk,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 22.0, color: _kMuted),
            ],
          ),
          Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _pill('งานล่าช้า ${delayedWorks.length} งาน',
                  Color(0xFFD03B3B), Color(0xFFFDEDED)),
              Spacer(),
              _avatarStack(pms),
            ],
          ),
        ],
      ),
      ),
    );
  }

  /// modal เลือก PM ที่มีงานล่าช้า → เข้าหน้า details
  Future<void> _openAttentionSheet(
      BuildContext context, List<ManagerInfo> pms) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      constraints: BoxConstraints(maxWidth: 460.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.7,
          ),
          padding: EdgeInsets.fromLTRB(20.0, 14.0, 20.0, 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: Color(0xFFE4E5E9),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              SizedBox(height: 12.0),
              Row(
                children: [
                  Icon(Icons.notification_important_rounded,
                      size: 18.0, color: Color(0xFFD03B3B)),
                  SizedBox(width: 6.0),
                  Text(
                    'PM ต้องติดตาม',
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w700,
                      color: _kInk,
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    '${pms.length} คน · เลือกเพื่อดูรายละเอียด',
                    style: TextStyle(fontSize: 12.5, color: _kMuted),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: pms.length,
                  itemBuilder: (context, i) {
                    final m = pms[i];
                    final delayed = works
                        .where((w) =>
                            w.manager == m.name &&
                            w.status == WorkStatus.delayed)
                        .length;
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        showManagerDetailSheet(context, m);
                      },
                      borderRadius: BorderRadius.circular(10.0),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            PmAvatar(
                                name: m.name,
                                avatarUrl: m.avatarUrl,
                                size: 34.0),
                            SizedBox(width: 10.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.name,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: _kInk,
                                    ),
                                  ),
                                  Text(
                                    m.position,
                                    style: TextStyle(
                                        fontSize: 11.5, color: _kMuted),
                                  ),
                                ],
                              ),
                            ),
                            _pill('ล่าช้า $delayed งาน',
                                Color(0xFFD03B3B), Color(0xFFFDEDED)),
                            SizedBox(width: 6.0),
                            Icon(Icons.chevron_right_rounded,
                                size: 18.0, color: _kMuted),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* ---------- card 3: report queue ---------- */

  Widget _queueCard(BuildContext context) {
    final pending =
        managers.where((m) => !m.reportSubmitted).toList();
    return Container(
      decoration: _card,
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${pending.length} คนยังไม่ส่ง\nรายงานสัปดาห์',
            style: TextStyle(
              fontSize: 19.0,
              height: 1.25,
              fontWeight: FontWeight.w700,
              color: _kInk,
            ),
          ),
          Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _pill('Due: ศ. 10 ก.ค.', _kBlue, Color(0xFFE8EEFC)),
              Spacer(),
              _avatarStack(pending),
            ],
          ),
        ],
      ),
    );
  }

  /* ---------- pipeline ---------- */

  Widget _pipelineCard(BuildContext context, {bool fill = false}) {
    final stages = _stages;
    final selected = stages[_stage];

    // PM ที่มีงานใน stage ที่เลือก เรียงตามจำนวนงานใน stage
    final pmCount = <String, int>{};
    for (final w in selected.items) {
      pmCount[w.manager] = (pmCount[w.manager] ?? 0) + 1;
    }
    final pins = pinnedPms.value;
    final pmNames = pmCount.keys.toList()
      ..sort((a, b) {
        final pa = pins.contains(_pmOf(a)?.id) ? 0 : 1;
        final pb = pins.contains(_pmOf(b)?.id) ? 0 : 1;
        if (pa != pb) return pa - pb;
        return pmCount[b]!.compareTo(pmCount[a]!);
      });
    final q = _pipelineSearch.trim().toLowerCase();
    final rows = pmNames.where((name) {
      final m = _pmOf(name);
      if (_fDept != 'ทุกแผนก' && m?.department != _fDept) return false;
      if (q.isEmpty) return true;
      final tasks = selected.items
          .where((w) => w.manager == name)
          .map((w) => w.title)
          .join(' ');
      return ('' + name + ' ' + (m?.department ?? '') + ' ' + tasks)
          .toLowerCase()
          .contains(q);
    }).toList();

    return Container(
      decoration: _card,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: LayoutBuilder(
              builder: (context, c) {
                final title = Text(
                  'รายงานประจำสัปดาห์ · สัปดาห์ที่ ${WeekInfo.weekNo}',
                  style: TextStyle(
                    fontSize: 19.0,
                    fontWeight: FontWeight.w700,
                    color: _kInk,
                  ),
                );
                final narrow = c.maxWidth < 560.0;
                final search = _searchBox(
                  width: narrow ? double.infinity : 210.0,
                  hint: 'ค้นหา PM / งาน...',
                  value: _pipelineSearch,
                  onChanged: (v) =>
                      safeSetState(() => _pipelineSearch = v),
                );
                if (narrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [title, SizedBox(height: 10.0), search],
                  );
                }
                return Row(
                  children: [Expanded(child: title), search],
                );
              },
            ),
          ),
          SizedBox(height: 12.0),
          // filter ช่วงเวลา + แผนก (mock — แผนกกรองรายชื่อจริง)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _filterDrop(
                  icon: Icons.calendar_today_rounded,
                  label: 'ปี',
                  value: '$_fYear',
                  options: ['2568', '2569'],
                  onSelect: (v) =>
                      safeSetState(() => _fYear = int.parse(v)),
                ),
                _filterDrop(
                  icon: Icons.calendar_month_rounded,
                  label: 'เดือน',
                  value: _fMonth,
                  options: ['พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.'],
                  onSelect: (v) => safeSetState(() => _fMonth = v),
                ),
                _filterDrop(
                  icon: Icons.view_week_rounded,
                  label: 'สัปดาห์',
                  value: _fWeek,
                  options: [
                    'ทั้งเดือน',
                    'สัปดาห์ที่ 36',
                    'สัปดาห์ที่ 37',
                    'สัปดาห์ที่ 38',
                    'สัปดาห์ที่ 39',
                  ],
                  onSelect: (v) => safeSetState(() => _fWeek = v),
                ),
                _filterDrop(
                  icon: Icons.apartment_rounded,
                  value: _fDept,
                  options: ['ทุกแผนก', ...departments],
                  onSelect: (v) => safeSetState(() => _fDept = v),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.0),
          // stat cards สถานะรายงาน — 4 ใบเต็มความกว้าง
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: LayoutBuilder(
              builder: (context, c) {
                final twoCol = c.maxWidth < 640.0;
                final itemW = (c.maxWidth - 10.0) / 2.0 - 0.5;
                final cards = stages.asMap().entries.map((e) {
                final sel = _stage == e.key;
                final st = e.value;
                final card = InkWell(
                    onTap: () => safeSetState(() => _stage = e.key),
                    borderRadius: BorderRadius.circular(14.0),
                    child: Container(
                      margin: EdgeInsets.only(
                          right: twoCol ||
                                  e.key == stages.length - 1
                              ? 0.0
                              : 10.0),
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        color: sel ? st.bg : Colors.white,
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(
                          color: sel ? st.color : Color(0xFFE4E5E9),
                          width: sel ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38.0,
                            height: 38.0,
                            decoration: BoxDecoration(
                              color: sel ? Colors.white : st.bg,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Icon(st.icon,
                                size: 20.0, color: st.color),
                          ),
                          SizedBox(width: 10.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${st.count}',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    height: 1.1,
                                    fontWeight: FontWeight.w800,
                                    color: st.color,
                                  ),
                                ),
                                Text(
                                  st.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 11.5, color: _kMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                return (key: e.key, widget: card);
              }).toList();
                if (twoCol) {
                  return Wrap(
                    spacing: 10.0,
                    runSpacing: 10.0,
                    children: cards
                        .map((e) =>
                            SizedBox(width: itemW, child: e.widget))
                        .toList(),
                  );
                }
                return Row(
                  children: cards
                      .map((e) => Expanded(child: e.widget))
                      .toList(),
                );
              },
            ),
          ),
          SizedBox(height: 16.0),
          // การ์ด PM เลื่อนแนวนอน — list ชนขอบการ์ด เห็นใบถัดไปโผล่ข้าง
          // (fill = ยืดเต็มความสูงที่เหลือ)
          if (fill)
            Expanded(child: _pipelineList(context, rows, selected))
          else
            SizedBox(
                height: 560.0,
                child: _pipelineList(context, rows, selected)),
        ],
      ),
    );
  }

  Widget _pipelineList(
    BuildContext context,
    List<String> rows,
    ({
      String label,
      int count,
      IconData icon,
      Color color,
      Color bg,
      List<WorkItem> items
    }) selected,
  ) {
    if (rows.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: DashboardEmpty('ไม่พบ PM ในกลุ่ม "${selected.label}"'),
      );
    }
    return Stack(
      children: [
        ListView.builder(
          controller: _pipelineCtrl,
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          scrollDirection: Axis.horizontal,
          itemCount: rows.length,
          itemBuilder: (context, i) {
            final m = _pmOf(rows[i]);
            if (m == null) return SizedBox.shrink();
            return Container(
              width: 340.0,
              margin: EdgeInsets.only(right: 12.0),
              child: _pipelineRow(
                context,
                m,
                selected.items
                    .where((w) => w.manager == rows[i])
                    .toList(),
              ),
            );
          },
        ),
        _scrollArrow(left: true),
        _scrollArrow(left: false),
      ],
    );
  }

  /// ปุ่มลูกศรลอยกลางขอบ list — เลื่อนทีละ 1 การ์ด จางเมื่อสุดฝั่งนั้น
  Widget _scrollArrow({required bool left}) {
    return Positioned(
      left: left ? 8.0 : null,
      right: left ? null : 8.0,
      top: 0.0,
      bottom: 0.0,
      child: Center(
        child: AnimatedBuilder(
          animation: _pipelineCtrl,
          builder: (context, _) {
            // โชว์ปุ่มตลอด — จางลงเมื่อเลื่อนต่อฝั่งนั้นไม่ได้
            var canScroll = true;
            if (_pipelineCtrl.hasClients &&
                _pipelineCtrl.position.hasContentDimensions) {
              final pos = _pipelineCtrl.position;
              canScroll = left
                  ? pos.pixels > 4.0
                  : pos.pixels < pos.maxScrollExtent - 4.0;
            }
            return AnimatedOpacity(
              opacity: canScroll ? 1.0 : 0.35,
              duration: Duration(milliseconds: 150),
              child: IgnorePointer(
                ignoring: !canScroll,
                child: Material(
                  color: Colors.white,
                  shape: CircleBorder(
                      side: BorderSide(color: Color(0xFFE4E5E9))),
                  elevation: 3.0,
                  shadowColor: Colors.black26,
                  child: InkWell(
                    customBorder: CircleBorder(),
                    onTap: () {
                      final pos = _pipelineCtrl.position;
                      final target =
                          (_pipelineCtrl.offset + (left ? -352.0 : 352.0))
                              .clamp(0.0, pos.maxScrollExtent);
                      _pipelineCtrl.animateTo(
                        target,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                      );
                    },
                    child: SizedBox(
                      width: 40.0,
                      height: 40.0,
                      child: Icon(
                        left
                            ? Icons.chevron_left_rounded
                            : Icons.chevron_right_rounded,
                        size: 26.0,
                        color: _kInk,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _filterDrop({
    required IconData icon,
    String? label,
    required String value,
    required List<String> options,
    required ValueChanged<String> onSelect,
  }) {
    const blue = Color(0xFF1D4ED8);
    return PopupMenuButton<String>(
      onSelected: onSelect,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      itemBuilder: (context) => options
          .map(
            (o) => PopupMenuItem<String>(
              value: o,
              height: 38.0,
              child: Text(
                o,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight:
                      o == value ? FontWeight.w700 : FontWeight.w500,
                  color: o == value ? blue : _kInk,
                ),
              ),
            ),
          )
          .toList(),
      child: Container(
        height: 36.0,
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Color(0xFFE4E5E9)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15.0, color: blue),
            if (label != null) ...[
              SizedBox(width: 6.0),
              Text(label,
                  style: TextStyle(fontSize: 12.5, color: _kMuted)),
            ],
            SizedBox(width: 6.0),
            Text(
              value,
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.w700,
                color: blue,
              ),
            ),
            SizedBox(width: 4.0),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 18.0, color: blue),
          ],
        ),
      ),
    );
  }

  Widget _searchBox({
    required double width,
    required String hint,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      width: width,
      height: 36.0,
      decoration: BoxDecoration(
        color: Color(0xFFF2F3F5),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextFormField(
        initialValue: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 12.5, color: _kMuted),
          prefixIcon:
              Icon(Icons.search_rounded, size: 17.0, color: _kMuted),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8.0),
        ),
        style: TextStyle(fontSize: 13.0, color: _kInk),
      ),
    );
  }

  /* ---------- PM card ใน pipeline (ข้อมูลตาม reference) ---------- */

  Widget _pipelineRow(
      BuildContext context, ManagerInfo m, List<WorkItem> items) {
    final ws = works.where((w) => w.manager == m.name).toList();
    final done = ws.where((w) => w.status == WorkStatus.done).length;
    final doing = ws
        .where((w) =>
            w.status == WorkStatus.inProgress ||
            w.status == WorkStatus.review)
        .length;
    final rest = ws.length - done - doing;
    final avg = ws.isEmpty
        ? 0
        : (ws.fold<int>(0, (s, w) => s + w.progress) / ws.length).round();
    final isOpen = !_collapsedPms.contains(m.name);
    final thisWeek = _pmWeekThis[m.name] ?? true;
    final hovered = _hoverPm == m.name;

    return MouseRegion(
      onEnter: (_) => safeSetState(() => _hoverPm = m.name),
      onExit: (_) => safeSetState(() => _hoverPm = null),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
              color: hovered ? _kBlue.withOpacity(0.45) : Color(0xFFE4E5E9)),
        ),
        child: Stack(
          children: [
            Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          InkWell(
            onTap: () => safeSetState(() => isOpen
                ? _collapsedPms.add(m.name)
                : _collapsedPms.remove(m.name)),
            borderRadius: BorderRadius.circular(14.0),
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Row(
                children: [
                  PmAvatar(name: m.name, avatarUrl: m.avatarUrl, size: 36.0),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: _kInk,
                          ),
                        ),
                        Text(
                          m.position,
                          style:
                              TextStyle(fontSize: 12.0, color: _kMuted),
                        ),
                      ],
                    ),
                  ),
                  if (pinnedPms.value.contains(m.id)) ...[
                    Icon(Icons.push_pin_rounded,
                        size: 15.0, color: Color(0xFFEB6834)),
                    SizedBox(width: 4.0),
                  ],
                  _pill(
                    switch (m.reportStatus) {
                      'sent' => 'ส่งแล้ว',
                      'draft' => 'ฉบับร่าง',
                      _ => 'ยังไม่ส่ง',
                    },
                    switch (m.reportStatus) {
                      'sent' => Color(0xFF14804A),
                      'draft' => Color(0xFFE8930C),
                      _ => Color(0xFFD03B3B),
                    },
                    switch (m.reportStatus) {
                      'sent' => Color(0xFFE3F5EB),
                      'draft' => Color(0xFFFDF3E3),
                      _ => Color(0xFFFDEDED),
                    },
                  ),
                  SizedBox(width: 6.0),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0.0,
                    duration: Duration(milliseconds: 180),
                    child: Icon(Icons.keyboard_arrow_up_rounded,
                        size: 20.0, color: _kMuted),
                  ),
                ],
              ),
            ),
          ),
          // stats + ring + stacked bar
          Padding(
            padding: EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _miniStat('$done', 'เสร็จ', Color(0xFF14A44D)),
                    _statDivider(),
                    _miniStat('$doing', 'กำลังทำ', _kBlue),
                    _statDivider(),
                    _miniStat('$rest', 'ยังไม่เริ่ม', Color(0xFFE8930C)),
                    Spacer(),
                    Column(
                      children: [
                        SizedBox(
                          width: 48.0,
                          height: 48.0,
                          child: CustomPaint(
                            painter: _RingPainter(avg / 100.0,
                                color: Color(0xFF14A44D)),
                            child: Center(
                              child: Text(
                                '$avg%',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w800,
                                  color: _kInk,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 2.0),
                        Text('คืบหน้ารวม',
                            style: TextStyle(
                                fontSize: 10.0, color: _kMuted)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 4.0),
                Text(
                  'ทั้งหมด ${ws.length} งานในสัปดาห์นี้',
                  style: TextStyle(fontSize: 11.5, color: _kMuted),
                ),
                SizedBox(height: 6.0),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999.0),
                  child: SizedBox(
                    height: 8.0,
                    child: Row(
                      children: [
                        if (done > 0)
                          Expanded(
                              flex: done,
                              child:
                                  Container(color: Color(0xFF14A44D))),
                        if (doing > 0)
                          Expanded(
                              flex: doing,
                              child: Container(color: _kBlue)),
                        if (rest > 0)
                          Expanded(
                              flex: rest,
                              child:
                                  Container(color: Color(0xFFE9EAEE))),
                        if (ws.isEmpty)
                          Expanded(
                              child:
                                  Container(color: Color(0xFFE9EAEE))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isOpen) ...[
            Divider(height: 1.0, color: Color(0xFFE4E5E9)),
            // tab สัปดาห์ที่แล้ว | สัปดาห์นี้
            _weekTabs(context, m, thisWeek),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 12.0),
                child: thisWeek
                    ? _weekGroups(context, m, thisWeek: true)
                    : _weekGroups(context, m, thisWeek: false),
              ),
            ),
          ] else
            Spacer(),
            ],
            ),
            // ปุ่มดูรายละเอียด โผล่ตอน hover ที่ bottom ของการ์ด
            Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: IgnorePointer(
                ignoring: !hovered,
                child: AnimatedOpacity(
                  opacity: hovered ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 150),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(12.0, 26.0, 12.0, 12.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.92),
                          Colors.white,
                        ],
                      ),
                    ),
                    child: InkWell(
                      onTap: () => showManagerDetailSheet(context, m),
                      borderRadius: BorderRadius.circular(10.0),
                      child: Container(
                        height: 38.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _kBlue,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ดูรายละเอียด',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 4.0),
                            Icon(Icons.arrow_forward_rounded,
                                size: 16.0, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _weekTabs(BuildContext context, ManagerInfo m, bool thisWeek) {
    return Row(
              children: [true, false].map((tw) {
                final labels = tw
                    ? (Icons.calendar_month_rounded, 'สัปดาห์นี้')
                    : (Icons.history_rounded, 'สัปดาห์ที่แล้ว');
                final sel = thisWeek == tw;
                return Expanded(
                  child: InkWell(
                    onTap: () =>
                        safeSetState(() => _pmWeekThis[m.name] = tw),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: sel ? _kBlue : Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(labels.$1,
                              size: 15.0,
                              color: sel ? _kBlue : _kMuted),
                          SizedBox(width: 5.0),
                          Text(
                            labels.$2,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: sel
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: sel ? _kBlue : _kMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList().reversed.toList(),
    );
  }

  Widget _miniStat(String v, String label, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(v,
              style: TextStyle(
                  fontSize: 20.0,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: color)),
          SizedBox(height: 2.0),
          Text(label,
              style: TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500)),
        ],
      );

  Widget _statDivider() => Container(
        width: 1.0,
        height: 30.0,
        margin: EdgeInsets.symmetric(horizontal: 16.0),
        color: Color(0xFFE9EAEE),
      );

  /// กลุ่มสถานะพับ/กางในการ์ด PM — this week ใช้ข้อมูลจริง,
  /// last week ใช้ mock prevWeekTasks
  Widget _weekGroups(BuildContext context, ManagerInfo m,
      {required bool thisWeek}) {
    final prefix = thisWeek ? 'tw' : 'lw';
    List<(String, WorkItem?, bool)> done, doing, todo;
    if (thisWeek) {
      final ws = works.where((w) => w.manager == m.name).toList();
      (String, WorkItem?, bool) e(WorkItem w) => (w.title, w, false);
      done = ws
          .where((w) => w.status == WorkStatus.done)
          .map(e)
          .toList();
      doing = ws
          .where((w) =>
              w.status == WorkStatus.inProgress ||
              w.status == WorkStatus.review)
          .map(e)
          .toList();
      todo = ws
          .where((w) =>
              w.status != WorkStatus.done &&
              w.status != WorkStatus.inProgress &&
              w.status != WorkStatus.review)
          .map(e)
          .toList();
    } else {
      final tasks = prevWeekTasks(m);
      List<(String, WorkItem?, bool)> by(String g) => tasks
          .where((t) => t.group == g)
          .map((t) => (t.title, null as WorkItem?, t.carried))
          .toList();
      done = by('done');
      doing = by('doing');
      todo = by('todo');
    }

    return Column(
      children: [
        _cardGroup(context, m, '$prefix-done', 'เสร็จแล้ว',
            Color(0xFF14A44D), done,
            strike: true),
        _cardGroup(context, m, '$prefix-doing', 'กำลังดำเนินการ', _kBlue,
            doing),
        _cardGroup(context, m, '$prefix-todo', 'ยังไม่ได้ทำ',
            Color(0xFFE8930C), todo),
      ],
    );
  }

  Widget _cardGroup(
    BuildContext context,
    ManagerInfo m,
    String key,
    String title,
    Color color,
    List<(String, WorkItem?, bool)> items, {
    bool strike = false,
  }) {
    final gk = '${m.name}|$key';
    final open = _pmGroupOpen[gk] ?? key.endsWith('-done');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => safeSetState(() => _pmGroupOpen[gk] = !open),
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            margin: EdgeInsets.only(top: 4.0),
            padding:
                EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
            decoration: BoxDecoration(
              color: open ? color.withOpacity(0.06) : Colors.transparent,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: open ? 0.25 : 0.0,
                  duration: Duration(milliseconds: 160),
                  child: Icon(Icons.chevron_right_rounded,
                      size: 19.0, color: color),
                ),
                SizedBox(width: 3.0),
                Container(
                  width: 12.0,
                  height: 12.0,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3.5),
                  ),
                ),
                SizedBox(width: 8.0),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: _kInk,
                  ),
                ),
                SizedBox(width: 7.0),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999.0),
                  ),
                  child: Text('${items.length} งาน',
                      style: TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                          color: color)),
                ),
              ],
            ),
          ),
        ),
        if (open)
          Container(
            margin: EdgeInsets.only(left: 8.0),
            decoration: BoxDecoration(
              border: Border(
                left:
                    BorderSide(color: color.withOpacity(0.35), width: 3.0),
              ),
            ),
            child: items.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text('ไม่มีงานในกลุ่มนี้',
                        style:
                            TextStyle(fontSize: 12.0, color: _kMuted)),
                  )
                : Column(
                    children: items
                        .map((e) => _cardTaskRow(context, e.$1, e.$2, e.$3,
                            strike: strike))
                        .toList(),
                  ),
          ),
      ],
    );
  }

  Widget _cardTaskRow(
      BuildContext context, String title, WorkItem? work, bool carried,
      {bool strike = false}) {
    // งานย่อย (mock deterministic จากชื่อ + progress)
    final subTotal = 1 + title.length % 3;
    final progress = work?.progress ?? (strike ? 100 : 0);
    final subDone = (progress / 100 * subTotal).round().clamp(0, subTotal);
    final carriedWeeks = 2 + title.length % 17;

    return InkWell(
      onTap:
          work == null ? null : () => showWorkDetailSheet(context, work),
      child: Container(
        padding: EdgeInsets.fromLTRB(12.0, 12.0, 6.0, 12.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF0F1F3)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 1.0),
                  child: Icon(
                    strike
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 18.0,
                    color: strike ? Color(0xFF14A44D) : _kBlue,
                  ),
                ),
                SizedBox(width: 9.0),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                      color: strike ? _kMuted : _kInk,
                      decoration:
                          strike ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                if (carried) ...[
                  SizedBox(width: 8.0),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 3.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFFDF3E3),
                      borderRadius: BorderRadius.circular(999.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.link_rounded,
                            size: 12.0, color: Color(0xFFB05E00)),
                        SizedBox(width: 3.0),
                        Text(
                          'ต่อเนื่อง $carriedWeeks สป.',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB05E00),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 7.0),
            Padding(
              padding: EdgeInsets.only(left: 27.0),
              child: Row(
                children: [
                  Text('งานย่อย $subDone/$subTotal',
                      style: TextStyle(
                          fontSize: 11.5, color: Color(0xFF6B7280))),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999.0),
                      child: LinearProgressIndicator(
                        value: subTotal == 0 ? 0 : subDone / subTotal,
                        minHeight: 6.0,
                        backgroundColor: Color(0xFFE9EAEE),
                        valueColor: AlwaysStoppedAnimation(
                            Color(0xFF14A44D)),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    '${subTotal == 0 ? 0 : (subDone / subTotal * 100).round()}%',
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: _kInk),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  /* ---------- อัตราส่งรายงาน ---------- */

  Widget _reportRateCard(BuildContext context) {
    final submitted = managers.where((m) => m.reportSubmitted).length;
    final rate = (submitted / managers.length * 100).round();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.0),
      decoration: _card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'อัตราส่งรายงาน',
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w700,
                    color: _kInk,
                  ),
                ),
              ),
              SizedBox(
                width: 44.0,
                height: 44.0,
                child: CustomPaint(
                  painter: _RingPainter(rate / 100.0),
                  child: Center(
                    child: Text(
                      '$rate%',
                      style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        color: _kInk,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.0),
          // filter สถานะ + search
          Row(
            children: [0, 1, 2].map((f) {
              final labels = ['ทั้งหมด', 'ส่งแล้ว', 'ยังไม่ส่ง'];
              final sel = _rateFilter == f;
              return Padding(
                padding: EdgeInsets.only(right: 6.0),
                child: InkWell(
                  onTap: () => safeSetState(() => _rateFilter = f),
                  borderRadius: BorderRadius.circular(999.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 5.0),
                    decoration: BoxDecoration(
                      color: sel ? _kInk : Color(0xFFF2F3F5),
                      borderRadius: BorderRadius.circular(999.0),
                    ),
                    child: Text(
                      labels[f],
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : _kMuted,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 8.0),
          _searchBox(
            width: double.infinity,
            hint: 'ค้นหาชื่อ PM...',
            value: _rateSearch,
            onChanged: (v) => safeSetState(() => _rateSearch = v),
          ),
          SizedBox(height: 8.0),
          ...(() {
            final q = _rateSearch.trim().toLowerCase();
            final list = List<ManagerInfo>.from(managers)
              ..sort((a, b) => (a.reportSubmitted ? 1 : 0)
                  .compareTo(b.reportSubmitted ? 1 : 0));
            return list.where((m) {
              if (_rateFilter == 1 && !m.reportSubmitted) return false;
              if (_rateFilter == 2 && m.reportSubmitted) return false;
              if (q.isNotEmpty &&
                  !('' + m.name + ' ' + m.department)
                      .toLowerCase()
                      .contains(q)) {
                return false;
              }
              return true;
            }).map((m) => _reportRow(context, m));
          })(),
        ],
      ),
    );
  }

  Widget _reportRow(BuildContext context, ManagerInfo m) {
    final submitted = m.reportSubmitted;
    return InkWell(
      onTap: () => showManagerDetailSheet(context, m),
      borderRadius: BorderRadius.circular(10.0),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          children: [
            PmAvatar(name: m.name, avatarUrl: m.avatarUrl, size: 26.0),
            SizedBox(width: 8.0),
            Expanded(
              child: Text(
                m.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color: submitted ? _kInk : Color(0xFFB3261E),
                ),
              ),
            ),
            SizedBox(width: 8.0),
            Container(
              width: 26.0,
              height: 30.0,
              decoration: BoxDecoration(
                color: submitted ? Color(0xFFE8EEFC) : Color(0xFFF2F3F5),
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(
                  color: submitted ? _kBlue : Color(0xFFD9DBDF),
                ),
              ),
              child: Icon(
                Icons.description_outlined,
                size: 15.0,
                color: submitted ? _kBlue : Color(0xFFB4B8BF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// วงแหวนเปอร์เซ็นต์ (สีส้มตาม reference)
class _RingPainter extends CustomPainter {
  _RingPainter(this.ratio, {this.color = const Color(0xFFE8590C)});

  final double ratio;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3.0;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0
        ..color = Color(0xFFF0F1F3),
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * ratio,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.ratio != ratio;
}
