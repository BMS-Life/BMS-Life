import '/components/sidebar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/executive_dashboard/dashboard_data.dart';
import '/executive_dashboard/components/dashboard_widgets.dart';
import '/executive_dashboard/components/work_detail_sheet.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'pm_detail_page_model.dart';
export 'pm_detail_page_model.dart';

const _kGreen = Color(0xFF21C45D);
const _kBlue = Color(0xFF0485F7);
const _kOrange = Color(0xFFE8930C);
const _kGray = Color(0xFFD9D9D9);
const _kInk = Color(0xFF17181C);
const _kMuted = Color(0xFF8A8F98);

/// หน้ารายละเอียด PM — ยกเนื้อหาจาก drawer เดิมมาเป็นหน้าเต็ม:
/// header (avatar + ตำแหน่ง + สถานะส่ง) + แถบสรุป progress +
/// สองคอลัมน์ ผลงานสัปดาห์ที่ผ่านมา | แผนงานสัปดาห์นี้
/// (งานย่อย + chip สถานะ + ปัญหา/แก้ไข/สรุป)
class PmDetailPageWidget extends StatefulWidget {
  const PmDetailPageWidget({super.key, this.managerId});

  final String? managerId;

  static String routeName = 'pm-detail';
  static String routePath = '/pmDetail';

  @override
  State<PmDetailPageWidget> createState() => _PmDetailPageWidgetState();
}

class _WeekStat {
  const _WeekStat(this.week, this.done, this.doing, this.delayed);
  final int week;
  final int done;
  final int doing;
  final int delayed;
}

class _StatusStat {
  const _StatusStat(this.label, this.value, this.color);
  final String label;
  final int value;
  final Color color;
}

class _TaskEntry {
  const _TaskEntry(this.title, this.carried, {this.work});
  final String title;
  final bool carried; // งานต่อเนื่องข้ามสัปดาห์
  final WorkItem? work;
}

class _PmDetailPageWidgetState extends State<PmDetailPageWidget> {
  late PmDetailPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final Set<String> _expanded = {'tw-done', 'tw-doing', 'lw-done', 'lw-doing'};
  String _taskSearch = '';
  int _taskFilter = 0; // 0 ทั้งหมด 1 มีปัญหา 2 งานต่อเนื่อง 3 งานประจำ
  int _weekOffset = 0; // เลื่อนหน้าต่างกราฟย้อนหลัง (0 = ล่าสุด)
  static const int _histWeeks = 16; // ประวัติทั้งหมด
  static const int _windowWeeks = 6; // แสดงครั้งละกี่สัปดาห์

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PmDetailPageModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  ManagerInfo get _manager => managers.firstWhere(
        (m) => m.id == widget.managerId,
        orElse: () => managers.first,
      );

  List<WorkItem> get _ws =>
      works.where((w) => w.manager == _manager.name).toList();

  BoxDecoration get _card => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Color(0xFFE4E5E9)),
      );

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
                if (wide) {
                  // scroll ทั้งหน้า — สองคอลัมน์สัปดาห์วางคู่กัน
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                        20.0,
                        MediaQuery.paddingOf(context).top + 16.0,
                        20.0,
                        24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        SizedBox(height: 14.0),
                        SizedBox(
                          height: 224.0,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                width: 320.0,
                                child: Container(
                                  decoration: _card,
                                  padding: EdgeInsets.all(16.0),
                                  child: _buildSummaryBar(context),
                                ),
                              ),
                              SizedBox(width: 14.0),
                              Expanded(child: _performanceCard(context)),
                            ],
                          ),
                        ),
                        SizedBox(height: 14.0),
                        _filterBar(context),
                        SizedBox(height: 14.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _weekCard(
                                context,
                                icon: Icons.task_alt_rounded,
                                title:
                                    'ผลงานสัปดาห์ที่ผ่านมา · ${_weekLabel(WeekInfo.weekNo - 1)}',
                                child: _buildLastWeek(context),
                              ),
                            ),
                            SizedBox(width: 14.0),
                            Expanded(
                              child: _weekCard(
                                context,
                                icon: Icons.trending_up_rounded,
                                title:
                                    'แผนงานสัปดาห์นี้ · ${_weekLabel(WeekInfo.weekNo)}',
                                child: _buildThisWeek(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                      20.0,
                      MediaQuery.paddingOf(context).top + 16.0,
                      20.0,
                      24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      SizedBox(height: 14.0),
                      Container(
                        width: double.infinity,
                        height: 240.0,
                        decoration: _card,
                        padding: EdgeInsets.all(16.0),
                        child: _buildSummaryBar(context),
                      ),
                      SizedBox(height: 14.0),
                      _performanceCard(context),
                      SizedBox(height: 14.0),
                      _filterBar(context),
                      SizedBox(height: 14.0),
                      _weekCard(
                        context,
                        icon: Icons.task_alt_rounded,
                        title:
                            'ผลงานสัปดาห์ที่ผ่านมา · ${_weekLabel(WeekInfo.weekNo - 1)}',
                        child: _buildLastWeek(context),
                      ),
                      SizedBox(height: 14.0),
                      _weekCard(
                        context,
                        icon: Icons.trending_up_rounded,
                        title: 'แผนงานสัปดาห์นี้ · ${_weekLabel(WeekInfo.weekNo)}',
                        child: _buildThisWeek(context),
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

  /* ---------- header ---------- */

  Widget _buildHeader(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final m = _manager;
    final sentAt = submittedAt(m);
    return Row(
      children: [
        InkWell(
          onTap: () => context.safePop(),
          borderRadius: BorderRadius.circular(999.0),
          child: Container(
            width: 36.0,
            height: 36.0,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Color(0xFFE4E5E9)),
            ),
            child: Icon(Icons.arrow_back_rounded, size: 18.0, color: _kInk),
          ),
        ),
        SizedBox(width: 14.0),
        PmAvatar(name: m.name, avatarUrl: m.avatarUrl, size: 52.0),
        SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                m.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.headlineSmall.override(
                  fontFamily: theme.headlineSmallFamily,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                  color: _kInk,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.headlineSmallIsCustom,
                ),
              ),
              Text(
                m.position,
                style: theme.bodySmall.override(
                  fontFamily: theme.bodySmallFamily,
                  fontSize: 13.0,
                  color: _kMuted,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodySmallIsCustom,
                ),
              ),
            ],
          ),
        ),
        if (sentAt != null) ...[
          Text(
            sentAt,
            style: theme.bodySmall.override(
              fontFamily: theme.bodySmallFamily,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF14804A),
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodySmallIsCustom,
            ),
          ),
          SizedBox(width: 10.0),
        ],
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          decoration: BoxDecoration(
            color:
                m.reportSubmitted ? Color(0xFFE3F5EB) : Color(0xFFFDECEC),
            borderRadius: BorderRadius.circular(999.0),
          ),
          child: Text(
            m.reportSubmitted ? 'ส่งแล้ว' : 'ยังไม่ส่ง',
            style: theme.bodySmall.override(
              fontFamily: theme.bodySmallFamily,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: m.reportSubmitted
                  ? Color(0xFF14804A)
                  : Color(0xFFC0392B),
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodySmallIsCustom,
            ),
          ),
        ),
        SizedBox(width: 8.0),
        // ปักหมุด PM จากหน้า details
        ValueListenableBuilder<Set<String>>(
          valueListenable: pinnedPms,
          builder: (context, pins, _) {
            final pinned = pins.contains(m.id);
            return InkWell(
              onTap: () => togglePinPm(m.id),
              borderRadius: BorderRadius.circular(999.0),
              child: Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color:
                      pinned ? Color(0xFFFDEFE7) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: pinned
                        ? Color(0xFFEB6834)
                        : Color(0xFFE4E5E9),
                  ),
                ),
                child: Icon(
                  pinned
                      ? Icons.push_pin_rounded
                      : Icons.push_pin_outlined,
                  size: 18.0,
                  color:
                      pinned ? Color(0xFFEB6834) : _kMuted,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /* ---------- แถบสรุปรวม + legend ---------- */

  Widget _buildSummaryBar(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final ws = _ws;
    final done = ws.where((w) => w.status == WorkStatus.done).length;
    final doing = ws
        .where((w) =>
            w.status == WorkStatus.inProgress ||
            w.status == WorkStatus.review)
        .length;
    final rest = ws.length - done - doing;
    final total = ws.length;
    final data = [
      _StatusStat('เสร็จ', done, _kGreen),
      _StatusStat('กำลังทำ', doing, _kBlue),
      _StatusStat('ยังไม่เริ่ม', rest, _kGray),
    ];
    final chartData =
        data.where((e) => e.value > 0).toList().isEmpty
            ? [_StatusStat('ไม่มีงาน', 1, _kGray)]
            : data.where((e) => e.value > 0).toList();

    Widget legend(_StatusStat e) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8.0,
              height: 8.0,
              decoration:
                  BoxDecoration(color: e.color, shape: BoxShape.circle),
            ),
            SizedBox(width: 4.0),
            Text(
              '${e.label} ${e.value}',
              style: theme.bodySmall.override(
                fontFamily: theme.bodySmallFamily,
                color: theme.secondaryText,
                fontSize: 11.5,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodySmallIsCustom,
              ),
            ),
          ],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_month_rounded,
                size: 14.0, color: theme.secondaryText),
            SizedBox(width: 5.0),
            Expanded(
              child: Text(
                'สัปดาห์ ${WeekInfo.dateRange}',
                style: theme.bodySmall.override(
                  fontFamily: theme.bodySmallFamily,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: theme.secondaryText,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodySmallIsCustom,
                ),
              ),
            ),
          ],
        ),
        // donut สถานะงาน เต็มพื้นที่การ์ด
        Expanded(
          child: SfCircularChart(
            margin: EdgeInsets.symmetric(vertical: 4.0),
            annotations: [
              CircularChartAnnotation(
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$total',
                      style: TextStyle(
                        fontSize: 24.0,
                        height: 1.0,
                        fontWeight: FontWeight.w800,
                        color: _kInk,
                      ),
                    ),
                    Text(
                      'งานสัปดาห์นี้',
                      style:
                          TextStyle(fontSize: 10.0, color: _kMuted),
                    ),
                  ],
                ),
              ),
            ],
            tooltipBehavior: TooltipBehavior(
              enable: true,
              header: '',
              format: 'point.x: point.y งาน',
            ),
            series: <CircularSeries<_StatusStat, String>>[
              DoughnutSeries<_StatusStat, String>(
                dataSource: chartData,
                xValueMapper: (e, _) => e.label,
                yValueMapper: (e, _) => e.value,
                pointColorMapper: (e, _) => e.color,
                innerRadius: '70%',
                radius: '98%',
                strokeWidth: 2.0,
                strokeColor: Colors.white,
              ),
            ],
          ),
        ),
        SizedBox(height: 4.0),
        Center(
          child: Wrap(
            spacing: 12.0,
            runSpacing: 4.0,
            children: data.map(legend).toList(),
          ),
        ),
      ],
    );
  }

  /* ---------- การ์ดรายสัปดาห์ ---------- */

  Widget _weekCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
    bool scroll = false,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      decoration: _card,
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: scroll ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 18.0, color: theme.primary),
              SizedBox(width: 7.0),
              Expanded(
                child: Text(
                  title,
                  style: theme.bodyLarge.override(
                    fontFamily: theme.bodyLargeFamily,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    color: theme.primary,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodyLargeIsCustom,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.0),
          if (scroll)
            Expanded(child: SingleChildScrollView(child: child))
          else
            child,
        ],
      ),
    );
  }

  /* ---------- performance stat card ---------- */

  /// ช่วงวันที่ จ.-ศ. ของสัปดาห์ (อิง W37 = 6-10 ก.ค. 2569/2026)
  String _weekLabel(int week) {
    final monday = DateTime(2026, 7, 6)
        .subtract(Duration(days: (WeekInfo.weekNo - week) * 7));
    final friday = monday.add(Duration(days: 4));
    const months = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
    ];
    if (monday.month == friday.month) {
      return '${monday.day}-${friday.day} ${months[monday.month - 1]}';
    }
    return '${monday.day} ${months[monday.month - 1]} - '
        '${friday.day} ${months[friday.month - 1]}';
  }

  Widget _performanceCard(BuildContext context) {
    final m = _manager;
    final ws = _ws;
    final doneNow = ws.where((w) => w.status == WorkStatus.done).length;
    final doingNow = ws
        .where((w) =>
            w.status == WorkStatus.inProgress ||
            w.status == WorkStatus.review)
        .length;
    final delayedNow =
        ws.where((w) => w.status == WorkStatus.delayed).length;
    final idx = managers.indexWhere((x) => x.id == m.id).clamp(0, 99);

    // ประวัติ 16 สัปดาห์ (mock deterministic, สัปดาห์ล่าสุด = ข้อมูลจริง)
    final history = List.generate(_histWeeks, (i) {
      final w = WeekInfo.weekNo - (_histWeeks - 1) + i;
      if (w == WeekInfo.weekNo) {
        return _WeekStat(w, doneNow, doingNow, delayedNow);
      }
      final done = 1 + (idx + i * 3) % 4;
      final doing = 1 + (idx * 2 + i) % 3;
      final delayed = (idx + i) % 3 == 0 ? 1 + i % 2 : 0;
      return _WeekStat(w, done, doing, delayed);
    });
    final maxOffset = _histWeeks - _windowWeeks;
    final start = (maxOffset - _weekOffset).clamp(0, maxOffset);
    final weeks = history.sublist(start, start + _windowWeeks);
    final prevDone = history[_histWeeks - 2].done;
    final diff = doneNow - prevDone;

    Widget legend(String label, Color c) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8.0,
              height: 8.0,
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            SizedBox(width: 4.0),
            Text(label,
                style: TextStyle(fontSize: 11.0, color: _kMuted)),
          ],
        );

    Widget navBtn(IconData ic, bool enabled, VoidCallback onTap) =>
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(999.0),
          child: Container(
            width: 28.0,
            height: 28.0,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Color(0xFFE4E5E9)),
            ),
            child: Icon(
              ic,
              size: 18.0,
              color: enabled ? _kInk : Color(0xFFC9CCD1),
            ),
          ),
        );

    final chart = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: 4.0),
            Text(
              'แนวโน้มรายสัปดาห์ · ${_weekLabel(weeks.first.week)} → ${_weekLabel(weeks.last.week)}',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: _kMuted,
              ),
            ),
            Spacer(),
            navBtn(Icons.chevron_left_rounded, _weekOffset < maxOffset,
                () => safeSetState(() => _weekOffset += 1)),
            SizedBox(width: 6.0),
            navBtn(Icons.chevron_right_rounded, _weekOffset > 0,
                () => safeSetState(() => _weekOffset -= 1)),
          ],
        ),
        SizedBox(height: 6.0),
        SizedBox(
          height: 150.0,
          child: SfCartesianChart(
            margin: EdgeInsets.zero,
            plotAreaBorderWidth: 0.0,
            primaryXAxis: CategoryAxis(
              axisLine: AxisLine(width: 1.0, color: Color(0xFFD9DBE0)),
              majorGridLines: MajorGridLines(width: 0.0),
              majorTickLines:
                  MajorTickLines(size: 4.0, color: Color(0xFFD9DBE0)),
              labelStyle: TextStyle(
                fontSize: 9.5,
                color: _kMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            primaryYAxis: NumericAxis(
              axisLine: AxisLine(width: 1.0, color: Color(0xFFD9DBE0)),
              majorTickLines:
                  MajorTickLines(size: 4.0, color: Color(0xFFD9DBE0)),
              majorGridLines: MajorGridLines(
                width: 1.0,
                color: Color(0xFFEDEEF1),
              ),
              interval: 2.0,
              labelStyle: TextStyle(fontSize: 9.5, color: _kMuted),
              title: AxisTitle(
                text: 'จำนวนงาน',
                textStyle: TextStyle(fontSize: 10.0, color: _kMuted),
              ),
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              header: '',
              format: 'point.x · series.name point.y งาน',
            ),
            series: <CartesianSeries<_WeekStat, String>>[
              StackedColumnSeries<_WeekStat, String>(
                dataSource: weeks,
                xValueMapper: (e, _) => _weekLabel(e.week),
                yValueMapper: (e, _) => e.done,
                name: 'เสร็จ',
                color: _kGreen,
                width: 0.5,
              ),
              StackedColumnSeries<_WeekStat, String>(
                dataSource: weeks,
                xValueMapper: (e, _) => _weekLabel(e.week),
                yValueMapper: (e, _) => e.doing,
                name: 'กำลังทำ',
                color: _kBlue,
                width: 0.5,
              ),
              StackedColumnSeries<_WeekStat, String>(
                dataSource: weeks,
                xValueMapper: (e, _) => _weekLabel(e.week),
                yValueMapper: (e, _) => e.delayed,
                name: 'ล่าช้า',
                color: Color(0xFFE5484D),
                width: 0.5,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(4.0)),
              ),
            ],
          ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      decoration: _card,
      padding: EdgeInsets.all(16.0),
      child: LayoutBuilder(
        builder: (context, c) {
          final stats = SizedBox(
            width: 210.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Performance',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700,
                    color: _kInk,
                  ),
                ),
                SizedBox(height: 10.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${m.score}',
                      style: TextStyle(
                        fontSize: 30.0,
                        height: 1.0,
                        fontWeight: FontWeight.w800,
                        color: _kInk,
                      ),
                    ),
                    SizedBox(width: 4.0),
                    Padding(
                      padding: EdgeInsets.only(bottom: 3.0),
                      child: Text('/100 คะแนน',
                          style: TextStyle(
                              fontSize: 12.0, color: _kMuted)),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    Icon(
                      diff >= 0
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 15.0,
                      color: diff >= 0
                          ? Color(0xFF14804A)
                          : Color(0xFFD03B3B),
                    ),
                    SizedBox(width: 4.0),
                    Text(
                      diff >= 0
                          ? 'เสร็จเพิ่ม +$diff จากสัปดาห์ก่อน'
                          : 'เสร็จลดลง $diff จากสัปดาห์ก่อน',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: diff >= 0
                            ? Color(0xFF14804A)
                            : Color(0xFFD03B3B),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Wrap(
                  spacing: 10.0,
                  runSpacing: 6.0,
                  children: [
                    legend('เสร็จ', _kGreen),
                    legend('กำลังทำ', _kBlue),
                    legend('ล่าช้า', Color(0xFFE5484D)),
                  ],
                ),
              ],
            ),
          );
          if (c.maxWidth < 560.0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [stats, SizedBox(height: 14.0), chart],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              stats,
              Container(
                width: 1.0,
                height: 170.0,
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                color: Color(0xFFEDEEF1),
              ),
              Expanded(child: chart),
            ],
          );
        },
      ),
    );
  }

  /* ---------- filter สำหรับผู้บริหาร ---------- */

  Widget _filterBar(BuildContext context) {
    const chips = ['ทั้งหมด', 'มีปัญหา', 'งานต่อเนื่อง', 'งานประจำ'];
    return Container(
      width: double.infinity,
      decoration: _card,
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      child: Row(
        children: [
          Icon(Icons.filter_list_rounded, size: 17.0, color: _kMuted),
          SizedBox(width: 8.0),
          ...chips.asMap().entries.map((e) {
            final sel = _taskFilter == e.key;
            return Padding(
              padding: EdgeInsets.only(right: 6.0),
              child: InkWell(
                onTap: () => safeSetState(() => _taskFilter = e.key),
                borderRadius: BorderRadius.circular(999.0),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: sel ? _kInk : Color(0xFFF2F3F5),
                    borderRadius: BorderRadius.circular(999.0),
                  ),
                  child: Text(
                    e.value,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : Color(0xFF5B6069),
                    ),
                  ),
                ),
              ),
            );
          }),
          Spacer(),
          Container(
            width: 240.0,
            height: 36.0,
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              color: Color(0xFFF2F3F5),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, size: 17.0, color: _kMuted),
                SizedBox(width: 6.0),
                Expanded(
                  child: TextFormField(
                    initialValue: _taskSearch,
                    onChanged: (v) =>
                        safeSetState(() => _taskSearch = v),
                    style: TextStyle(fontSize: 13.0, color: _kInk),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'ค้นหางาน...',
                      hintStyle:
                          TextStyle(fontSize: 13.0, color: _kMuted),
                      border: InputBorder.none,
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

  List<_TaskEntry> _applyFilter(List<_TaskEntry> items, String group) {
    final q = _taskSearch.trim().toLowerCase();
    return items.where((e) {
      if (q.isNotEmpty && !e.title.toLowerCase().contains(q)) {
        return false;
      }
      return switch (_taskFilter) {
        1 => subTasksFor(e.title, group).any((x) => x.problem != null),
        2 => e.carried,
        3 => isRoutineTask(e.title),
        _ => true,
      };
    }).toList();
  }

  /* ---------- เนื้อหา: สัปดาห์นี้ (ข้อมูลจริง) ---------- */

  Widget _buildThisWeek(BuildContext context) {
    final ws = _ws;
    final done = ws
        .where((w) => w.status == WorkStatus.done)
        .map((w) => _TaskEntry(w.title, false, work: w))
        .toList();
    final doing = ws
        .where((w) =>
            w.status == WorkStatus.inProgress ||
            w.status == WorkStatus.review)
        .map((w) => _TaskEntry(w.title, false, work: w))
        .toList();
    final todo = ws
        .where((w) =>
            w.status != WorkStatus.done &&
            w.status != WorkStatus.inProgress &&
            w.status != WorkStatus.review)
        .map((w) => _TaskEntry(w.title, false, work: w))
        .toList();

    return Column(
      children: [
        _statusGroup(context, 'tw-done', 'เสร็จแล้ว', _kGreen,
            _applyFilter(done, 'done'),
            strike: true),
        _statusGroup(context, 'tw-doing', 'กำลังดำเนินการ', _kBlue,
            _applyFilter(doing, 'doing')),
        _statusGroup(context, 'tw-todo', 'ยังไม่ได้ทำ', _kOrange,
            _applyFilter(todo, 'todo')),
      ],
    );
  }

  /* ---------- เนื้อหา: สัปดาห์ที่แล้ว (mock prevWeekTasks) ---------- */

  Widget _buildLastWeek(BuildContext context) {
    final tasks = prevWeekTasks(_manager);
    List<_TaskEntry> byGroup(String g) => tasks
        .where((t) => t.group == g)
        .map((t) => _TaskEntry(t.title, t.carried))
        .toList();

    return Column(
      children: [
        _statusGroup(context, 'lw-done', 'เสร็จแล้ว', _kGreen,
            _applyFilter(byGroup('done'), 'done'),
            strike: true),
        _statusGroup(context, 'lw-doing', 'กำลังดำเนินการ', _kBlue,
            _applyFilter(byGroup('doing'), 'doing')),
        _statusGroup(context, 'lw-todo', 'ยังไม่ได้ทำ', _kOrange,
            _applyFilter(byGroup('todo'), 'todo')),
      ],
    );
  }

  /* ---------- กลุ่มสถานะแบบพับ/กาง ---------- */

  Widget _statusGroup(
    BuildContext context,
    String key,
    String title,
    Color color,
    List<_TaskEntry> items, {
    bool strike = false,
  }) {
    final theme = FlutterFlowTheme.of(context);
    final expanded = _expanded.contains(key);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() =>
              expanded ? _expanded.remove(key) : _expanded.add(key)),
          borderRadius: BorderRadius.circular(8.0),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: expanded ? 0.25 : 0.0,
                  duration: Duration(milliseconds: 180),
                  child: Icon(Icons.chevron_right_rounded,
                      size: 22.0, color: color),
                ),
                SizedBox(width: 4.0),
                Container(
                  width: 14.0,
                  height: 14.0,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                SizedBox(width: 8.0),
                Text(
                  title,
                  style: theme.bodyLarge.override(
                    fontFamily: theme.bodyLargeFamily,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodyLargeIsCustom,
                  ),
                ),
                SizedBox(width: 6.0),
                Text(
                  '(${items.length})',
                  style: theme.bodyMedium.override(
                    fontFamily: theme.bodyMediumFamily,
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodyMediumIsCustom,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          Container(
            margin: EdgeInsets.only(left: 8.0),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: color.withOpacity(0.35), width: 3.0),
              ),
            ),
            child: Column(
              children: items.isEmpty
                  ? [
                      Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          'ไม่มีงานในกลุ่มนี้',
                          style: theme.bodySmall.override(
                            fontFamily: theme.bodySmallFamily,
                            color: theme.secondaryText,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodySmallIsCustom,
                          ),
                        ),
                      ),
                    ]
                  : items
                      .map((e) => _taskRow(context, e, color,
                          strike: strike,
                          group: key.split('-').last,
                          showNotes: key.startsWith('lw-')))
                      .toList(),
            ),
          ),
      ],
    );
  }

  Widget _taskRow(BuildContext context, _TaskEntry e, Color color,
      {bool strike = false, required String group, bool showNotes = false}) {
    final theme = FlutterFlowTheme.of(context);
    final subs = subTasksFor(e.title, group);
    final subDone = subs.where((s) => s.status == 'done').length;

    return InkWell(
      onTap: e.work == null
          ? null
          : () => showWorkDetailSheet(context, e.work!),
      child: Container(
        padding: EdgeInsets.fromLTRB(14.0, 12.0, 8.0, 12.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.alternate.withOpacity(0.7)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  strike
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 20.0,
                  color: strike ? _kGreen : color,
                ),
                SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    e.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.bodyMedium.override(
                      fontFamily: theme.bodyMediumFamily,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: strike
                          ? theme.secondaryText
                          : theme.primaryText,
                      decoration:
                          strike ? TextDecoration.lineThrough : null,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.bodyMediumIsCustom,
                    ),
                  ),
                ),
                if (e.carried) ...[
                  SizedBox(width: 8.0),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.link_rounded,
                          size: 15.0, color: _kOrange),
                      SizedBox(width: 3.0),
                      Text(
                        'ต่อเนื่อง 2 สป.',
                        style: theme.bodySmall.override(
                          fontFamily: theme.bodySmallFamily,
                          color: _kOrange,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            // chip งานประจำ + งานย่อย x/y ตาม reference
            Padding(
              padding: EdgeInsets.only(left: 30.0, top: 6.0),
              child: Wrap(
                spacing: 6.0,
                runSpacing: 6.0,
                children: [
                  if (isRoutineTask(e.title))
                    _miniChip(context, 'งานประจำ', Color(0xFF7C3AED),
                        Color(0xFFF3EDFD)),
                  _miniChip(context, 'งานย่อย $subDone/${subs.length}',
                      Color(0xFF2158E5), Color(0xFFEAF0FE)),
                ],
              ),
            ),
            // กล่องงานย่อย
            Container(
              margin: EdgeInsets.only(left: 30.0, top: 8.0),
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_tree_rounded,
                          size: 13.0, color: theme.secondaryText),
                      SizedBox(width: 5.0),
                      Text(
                        'งานย่อย',
                        style: theme.bodySmall.override(
                          fontFamily: theme.bodySmallFamily,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: theme.secondaryText,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.0),
                  ...subs.map((s) => _subTaskRow(context, s, showNotes)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniChip(
      BuildContext context, String label, Color fg, Color bg) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Text(
        label,
        style: theme.bodySmall.override(
          fontFamily: theme.bodySmallFamily,
          fontSize: 11.0,
          fontWeight: FontWeight.w600,
          color: fg,
          letterSpacing: 0.0,
          useGoogleFonts: !theme.bodySmallIsCustom,
        ),
      ),
    );
  }

  Widget _subTaskRow(BuildContext context, SubTask s, bool showNotes) {
    final theme = FlutterFlowTheme.of(context);
    final (icon, c, statusLabel) = switch (s.status) {
      'done' => (
          Icons.check_circle_rounded,
          _kGreen,
          'ดำเนินการแล้วเสร็จ'
        ),
      'doing' => (
          Icons.play_circle_outline_rounded,
          _kBlue,
          'กำลังดำเนินการ'
        ),
      _ => (
          Icons.radio_button_unchecked_rounded,
          _kOrange,
          'ยังไม่ได้ดำเนินการ'
        ),
    };

    Widget note(String label, String text) => Padding(
          padding: EdgeInsets.only(left: 21.0, top: 4.0),
          child: RichText(
            text: TextSpan(
              style: theme.bodySmall.override(
                fontFamily: theme.bodySmallFamily,
                fontSize: 12.0,
                lineHeight: 1.45,
                color: theme.secondaryText,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodySmallIsCustom,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: theme.primaryText,
                  ),
                ),
                TextSpan(text: text),
              ],
            ),
          ),
        );

    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 15.0, color: c),
              SizedBox(width: 6.0),
              Expanded(
                child: Text(
                  s.title,
                  style: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    fontSize: 12.5,
                    lineHeight: 1.4,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryText,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  ),
                ),
              ),
              SizedBox(width: 6.0),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: c.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  statusLabel,
                  style: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: c,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  ),
                ),
              ),
            ],
          ),
          if (showNotes && s.status == 'done') ...[
            if (s.problem != null) note('ปัญหา', s.problem!),
            if (s.solution != null) note('แก้ไข', s.solution!),
            if (s.summary != null) note('สรุป', s.summary!),
          ],
        ],
      ),
    );
  }
}
