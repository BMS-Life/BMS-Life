import '/components/sidebar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/executive_dashboard/dashboard_data.dart';
import '/executive_dashboard/components/dashboard_widgets.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'work_detail_page_model.dart';
export 'work_detail_page_model.dart';

/// หน้ารายละเอียดงาน (Work Detail Page) — layout ตาม reference:
/// header + meta + tabs, คอลัมน์หลัก (Insights / Goals / Scope /
/// Outcomes / Timeline) + sidebar ขวา (Time / Details / Quick links)
class WorkDetailPageWidget extends StatefulWidget {
  const WorkDetailPageWidget({super.key, this.workId});

  final String? workId;

  static String routeName = 'work-detail';
  static String routePath = '/workDetail';

  @override
  State<WorkDetailPageWidget> createState() => _WorkDetailPageWidgetState();
}

class _WorkDetailPageWidgetState extends State<WorkDetailPageWidget> {
  late WorkDetailPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const _tabs = ['Overview', 'Tasks', 'Notes', 'Files', 'Comments'];
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WorkDetailPageModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  WorkItem get _work => works.firstWhere(
        (w) => w.id == widget.workId,
        orElse: () => works.first,
      );

  ManagerInfo? get _pm {
    for (final m in managers) {
      if (m.name == _work.manager) return m;
    }
    return null;
  }

  // mock "วันนี้" = วันแรกของรอบรายงาน (6 ก.ค. 2569)
  int get _daysRemaining {
    final due = _work.dueDate.split('-').map(int.parse).toList();
    final dueDate = DateTime(due[0] - 543, due[1], due[2]);
    final today = DateTime(2026, 7, 6);
    return dueDate.difference(today).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final showSidebar = responsiveVisibility(
      context: context,
      phone: false,
      tablet: false,
      tabletLandscape: false,
    );
    return Material(
      color: theme.primaryBackground,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showSidebar)
            wrapWithModel(
              model: _model.sidebarModel,
              updateCallback: () => safeSetState(() {}),
              child: SidebarWidget(),
            ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 980.0;
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            20.0,
                            MediaQuery.paddingOf(context).top + 16.0,
                            20.0,
                            0.0),
                        child: _buildHeader(context),
                      ),
                      SizedBox(height: 14.0),
                      _buildTabBar(context),
                      Divider(height: 1.0, color: theme.alternate),
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: _tab == 0
                            ? (wide
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: _buildMain(context)),
                                      SizedBox(width: 28.0),
                                      SizedBox(
                                        width: 280.0,
                                        child: _buildSide(context),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildMain(context),
                                      SizedBox(height: 24.0),
                                      _buildSide(context),
                                    ],
                                  ))
                            : DashboardEmpty(
                                'ยังไม่มีข้อมูลในแท็บ ${_tabs[_tab]}'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /* ---------- Header ---------- */

  Widget _buildHeader(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final w = _work;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
              onTap: () => context.safePop(),
              borderRadius: BorderRadius.circular(999.0),
              child: Container(
                width: 34.0,
                height: 34.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.alternate),
                ),
                child: Icon(Icons.arrow_back_rounded,
                    size: 18.0, color: theme.primaryText),
              ),
            ),
            SizedBox(width: 12.0),
            Flexible(
              child: Text(
                w.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.headlineSmall.override(
                  fontFamily: theme.headlineSmallFamily,
                  fontSize: 21.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.headlineSmallIsCustom,
                ),
              ),
            ),
            SizedBox(width: 10.0),
            StatusBadge(w.status),
            if (w.decisionRequired) ...[
              SizedBox(width: 6.0),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(999.0),
                ),
                child: Text(
                  '⚑ ต้องตัดสินใจ',
                  style: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    color: Color(0xFF92400E),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  ),
                ),
              ),
            ],
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: theme.alternate),
              ),
              child: Text(
                'Edit',
                style: theme.bodyMedium.override(
                  fontFamily: theme.bodyMediumFamily,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodyMediumIsCustom,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.0),
        Padding(
          padding: EdgeInsets.only(left: 46.0),
          child: Wrap(
            spacing: 18.0,
            runSpacing: 6.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _meta(context, 'ID:', '#${w.id}'),
              _metaIcon(context, Icons.signal_cellular_alt_rounded,
                  'Risk ${w.riskLevel}'),
              _metaIcon(context, Icons.apartment_rounded, w.department),
              _metaIcon(context, Icons.flag_circle_rounded,
                  'สัปดาห์ที่ ${w.weekNo} / ${WeekInfo.year}'),
              _metaIcon(context, Icons.history_rounded,
                  'Last sync ${w.updatedAt}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _meta(BuildContext context, String k, String v) {
    final theme = FlutterFlowTheme.of(context);
    return Text.rich(
      TextSpan(children: [
        TextSpan(
          text: '$k ',
          style: theme.bodySmall.override(
            fontFamily: theme.bodySmallFamily,
            color: theme.secondaryText,
            letterSpacing: 0.0,
            useGoogleFonts: !theme.bodySmallIsCustom,
          ),
        ),
        TextSpan(
          text: v,
          style: theme.bodySmall.override(
            fontFamily: theme.bodySmallFamily,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.0,
            useGoogleFonts: !theme.bodySmallIsCustom,
          ),
        ),
      ]),
    );
  }

  Widget _metaIcon(BuildContext context, IconData icon, String v) {
    final theme = FlutterFlowTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15.0, color: theme.secondaryText),
        SizedBox(width: 4.0),
        Text(
          v,
          style: theme.bodySmall.override(
            fontFamily: theme.bodySmallFamily,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.0,
            useGoogleFonts: !theme.bodySmallIsCustom,
          ),
        ),
      ],
    );
  }

  /* ---------- Tabs ---------- */

  Widget _buildTabBar(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(left: 20.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _tabs.asMap().entries.map((e) {
            final selected = _tab == e.key;
            return InkWell(
              onTap: () => safeSetState(() => _tab = e.key),
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected ? theme.primary : Colors.transparent,
                      width: 2.0,
                    ),
                  ),
                ),
                child: Text(
                  e.value,
                  style: theme.bodyMedium.override(
                    fontFamily: theme.bodyMediumFamily,
                    color:
                        selected ? theme.primaryText : theme.secondaryText,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodyMediumIsCustom,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /* ---------- Main column ---------- */

  String get _group {
    final w = _work;
    if (w.status == WorkStatus.done) return 'done';
    if (w.status == WorkStatus.inProgress ||
        w.status == WorkStatus.review) {
      return 'doing';
    }
    return 'todo';
  }

  List<SubTask> get _subs => subTasksFor(_work.title, _group);

  Widget _buildMain(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final w = _work;
    final subs = _subs;
    final subDone = subs.where((x) => x.status == 'done').length;
    final problems = <String>{
      if (w.problem.isNotEmpty) w.problem,
      ...subs.where((x) => x.problem != null).map((x) => x.problem!),
    }.toList();
    final solutions = <String>{
      if (w.solution.isNotEmpty) w.solution,
      ...subs.where((x) => x.solution != null).map((x) => x.solution!),
    }.toList();
    final summaries = <String>{
      ...subs.where((x) => x.summary != null).map((x) => x.summary!),
    }.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Insights card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: theme.alternate),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding:
                    EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(11.0)),
                ),
                child: Text(
                  'ⓘ Internal information only',
                  style: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    color: Color(0xFF1D4ED8),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Insights',
                      style: theme.bodyLarge.override(
                        fontFamily: theme.bodyLargeFamily,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodyLargeIsCustom,
                      ),
                    ),
                    SizedBox(height: 12.0),
                    Wrap(
                      spacing: 28.0,
                      runSpacing: 12.0,
                      children: [
                        _insight(context, Icons.gavel_rounded, 'Decisions',
                            w.decisionRequired ? '1 key' : '0 keys'),
                        _insight(context, Icons.block_rounded,
                            'Risks & blockers',
                            '${problems.length} blocks'),
                        _insight(context, Icons.account_tree_rounded,
                            'งานย่อย', '$subDone/${subs.length} เสร็จ'),
                        _insight(context, Icons.tips_and_updates_rounded,
                            'Key assumptions', '${w.progress}% progress'),
                        _insight(context, Icons.person_outline_rounded,
                            'Owner', w.owner),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 22.0),
        _sectionTitle(context, 'Goals'),
        SizedBox(height: 8.0),
        Text(
          w.summary.isEmpty
              ? 'ติดตามและส่งมอบงาน ${w.title} ของฝ่าย ${w.department} ให้เป็นไปตามแผนรอบสัปดาห์ที่ ${w.weekNo}'
              : w.summary,
          style: theme.bodyMedium.override(
            fontFamily: theme.bodyMediumFamily,
            letterSpacing: 0.0,
            lineHeight: 1.6,
            useGoogleFonts: !theme.bodyMediumIsCustom,
          ),
        ),
        SizedBox(height: 22.0),
        _sectionTitle(context, 'งานย่อย ($subDone/${subs.length})'),
        SizedBox(height: 10.0),
        ...subs.map((x) => _subTaskRow(context, x)),
        SizedBox(height: 22.0),
        // In scope / Out of scope → ปัญหา / วิธีแก้ไข
        LayoutBuilder(
          builder: (context, c) {
            final two = c.maxWidth >= 560.0;
            final problem = _scopeBlock(
              context,
              'ปัญหาที่พบ',
              problems.isEmpty ? ['ไม่มีปัญหาค้างในรอบนี้'] : problems,
            );
            final solution = _scopeBlock(
              context,
              'วิธีการแก้ไข',
              solutions.isEmpty ? ['ดำเนินการตามแผนปกติ'] : solutions,
            );
            if (!two) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [problem, SizedBox(height: 16.0), solution],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: problem),
                SizedBox(width: 24.0),
                Expanded(child: solution),
              ],
            );
          },
        ),
        SizedBox(height: 22.0),
        _sectionTitle(context, 'Expected Outcomes'),
        SizedBox(height: 8.0),
        _bullet(context, 'Next Action: ${w.nextAction}'),
        if (w.impact.isNotEmpty)
          _bullet(context, 'ผลกระทบหากล่าช้า: ${w.impact}'),
        if (w.escalationNote.isNotEmpty)
          _bullet(context, 'ต้องการผู้บริหารช่วย: ${w.escalationNote}'),
        _bullet(context,
            'ความคืบหน้าปัจจุบัน ${w.progress}% ภายใน Due ${w.dueDate}'),
        ...summaries.map((t) => _bullet(context, 'สรุป: $t')),
        SizedBox(height: 22.0),
        _sectionTitle(context, 'Expected Timeline'),
        SizedBox(height: 10.0),
        _buildTimeline(context),
      ],
    );
  }

  Widget _insight(
      BuildContext context, IconData icon, String label, String value) {
    final theme = FlutterFlowTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34.0,
          height: 34.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: theme.alternate),
          ),
          child: Icon(icon, size: 17.0, color: theme.secondaryText),
        ),
        SizedBox(width: 8.0),
        Column(
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
            Text(
              value,
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodyMediumIsCustom,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _subTaskRow(BuildContext context, SubTask x) {
    final theme = FlutterFlowTheme.of(context);
    final (icon, c, label) = switch (x.status) {
      'done' => (
          Icons.check_circle_rounded,
          Color(0xFF1FA34C),
          'ดำเนินการแล้วเสร็จ'
        ),
      'doing' => (
          Icons.play_circle_outline_rounded,
          Color(0xFF1E88E5),
          'กำลังดำเนินการ'
        ),
      _ => (
          Icons.radio_button_unchecked_rounded,
          Color(0xFFE8930C),
          'ยังไม่ได้ดำเนินการ'
        ),
    };
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17.0, color: c),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              x.title,
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                fontWeight: FontWeight.w600,
                lineHeight: 1.4,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodyMediumIsCustom,
              ),
            ),
          ),
          SizedBox(width: 8.0),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: c.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Text(
              label,
              style: theme.bodySmall.override(
                fontFamily: theme.bodySmallFamily,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: c,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodySmallIsCustom,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String t) {
    final theme = FlutterFlowTheme.of(context);
    return Text(
      t,
      style: theme.titleMedium.override(
        fontFamily: theme.titleMediumFamily,
        fontSize: 16.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.0,
        useGoogleFonts: !theme.titleMediumIsCustom,
      ),
    );
  }

  Widget _scopeBlock(BuildContext context, String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, title),
        SizedBox(height: 8.0),
        ...items.map((t) => _bullet(context, t)),
      ],
    );
  }

  Widget _bullet(BuildContext context, String t) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('-  ',
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodyMediumIsCustom,
              )),
          Expanded(
            child: Text(
              t,
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                letterSpacing: 0.0,
                lineHeight: 1.5,
                useGoogleFonts: !theme.bodyMediumIsCustom,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* ---------- Timeline (สัปดาห์รายงาน) ---------- */

  Widget _buildTimeline(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final w = _work;
    const days = ['จ. 6', 'อ. 7', 'พ. 8', 'พฤ. 9', 'ศ. 10', 'ส. 11', 'อา. 12'];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        children: [
          // header วัน
          Container(
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(9.0)),
            ),
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 130.0,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'ก.ค. 2569',
                      style: theme.bodySmall.override(
                        fontFamily: theme.bodySmallFamily,
                        color: theme.secondaryText,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodySmallIsCustom,
                      ),
                    ),
                  ),
                ),
                ...days.map(
                  (d) => Expanded(
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: theme.bodySmall.override(
                        fontFamily: theme.bodySmallFamily,
                        color: theme.secondaryText,
                        fontSize: 11.0,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodySmallIsCustom,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ..._subs.take(4).toList().asMap().entries.map((e) {
            final x = e.value;
            final color = switch (x.status) {
              'done' => Color(0xFF1FA34C),
              'doing' => Color(0xFF1E88E5),
              _ => Color(0xFF94A3B8),
            };
            final start = e.key.clamp(0, 4);
            return _ganttRow(context, x.title, start, 3, color);
          }),
          _ganttRow(context, w.nextAction, 4, 3, Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  Widget _ganttRow(BuildContext context, String label, int startDay,
      int spanDays, Color color) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.alternate)),
      ),
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 130.0,
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.bodySmall.override(
                  fontFamily: theme.bodySmallFamily,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodySmallIsCustom,
                ),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                final dayW = c.maxWidth / 7.0;
                return SizedBox(
                  height: 22.0,
                  child: Stack(
                    children: [
                      Positioned(
                        left: dayW * startDay,
                        width: dayW * spanDays,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(6.0),
                            border: Border.all(color: color),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /* ---------- Right sidebar ---------- */

  Widget _buildSide(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final w = _work;
    final pm = _pm;
    final remaining = _daysRemaining;
    final total = 30;
    final elapsedRatio =
        ((total - remaining).clamp(0, total)) / total.toDouble();

    Widget kv(String k, Widget v, {IconData? icon}) => Padding(
          padding: EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16.0, color: theme.secondaryText),
                SizedBox(width: 8.0),
              ],
              Expanded(
                child: Text(
                  k,
                  style: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  ),
                ),
              ),
              v,
            ],
          ),
        );

    Widget kvText(String k, String v, {IconData? icon}) => kv(
          k,
          Text(
            v,
            style: theme.bodyMedium.override(
              fontFamily: theme.bodyMediumFamily,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodyMediumIsCustom,
            ),
          ),
          icon: icon,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, 'Time'),
        SizedBox(height: 4.0),
        kvText('Estimate', '1 สัปดาห์', icon: Icons.timer_outlined),
        kvText('Due Date', w.dueDate, icon: Icons.event_rounded),
        SizedBox(height: 6.0),
        Row(
          children: [
            Expanded(
              child: Text(
                'Days remaining',
                style: theme.bodySmall.override(
                  fontFamily: theme.bodySmallFamily,
                  color: theme.secondaryText,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodySmallIsCustom,
                ),
              ),
            ),
            Text(
              remaining >= 0 ? '$remaining Days to go' : 'เกินกำหนดแล้ว',
              style: theme.bodySmall.override(
                fontFamily: theme.bodySmallFamily,
                color: remaining >= 0
                    ? theme.primaryText
                    : Color(0xFFB91C1C),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodySmallIsCustom,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.0),
        ClipRRect(
          borderRadius: BorderRadius.circular(999.0),
          child: LinearProgressIndicator(
            value: elapsedRatio,
            minHeight: 6.0,
            backgroundColor: theme.alternate,
            valueColor: AlwaysStoppedAnimation(theme.primary),
          ),
        ),
        Divider(height: 32.0, color: theme.alternate),
        _sectionTitle(context, 'Details'),
        SizedBox(height: 4.0),
        kv('Status', StatusBadge(w.status), icon: Icons.sync_rounded),
        kvText('Group', w.project, icon: Icons.folder_open_rounded),
        kv('Priority', RiskBadge(w.riskLevel),
            icon: Icons.signal_cellular_alt_rounded),
        kvText('Label', w.decisionRequired ? 'ต้องตัดสินใจ' : 'None',
            icon: Icons.sell_outlined),
        kv(
          'PIC',
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (pm != null) ...[
                PmAvatar(
                    name: pm.name, avatarUrl: pm.avatarUrl, size: 20.0),
                SizedBox(width: 6.0),
              ],
              Text(
                w.manager,
                style: theme.bodyMedium.override(
                  fontFamily: theme.bodyMediumFamily,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodyMediumIsCustom,
                ),
              ),
            ],
          ),
          icon: Icons.person_outline_rounded,
        ),
        kvText('Support', w.owner, icon: Icons.group_outlined),
        Divider(height: 32.0, color: theme.alternate),
        _sectionTitle(context, 'Quick links'),
        SizedBox(height: 8.0),
        _quickLink(context, Icons.picture_as_pdf_rounded, Color(0xFFD03B3B),
            'รายงานสัปดาห์ ${w.weekNo}.pdf', '1.2 MB'),
        _quickLink(context, Icons.grid_on_rounded, Color(0xFF1FA34C),
            'แผนงาน ${w.title}.xlsx', '860 KB'),
        _quickLink(context, Icons.design_services_rounded, Color(0xFF8B5CF6),
            'เอกสารออกแบบ.fig', '13.0 MB'),
      ],
    );
  }

  Widget _quickLink(BuildContext context, IconData icon, Color color,
      String name, String size) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Container(
            width: 38.0,
            height: 38.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9.0),
              border: Border.all(color: theme.alternate),
            ),
            child: Icon(icon, size: 19.0, color: color),
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodyMedium.override(
                    fontFamily: theme.bodyMediumFamily,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodyMediumIsCustom,
                  ),
                ),
                Text(
                  size,
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
              size: 18.0, color: theme.secondaryText),
        ],
      ),
    );
  }
}
