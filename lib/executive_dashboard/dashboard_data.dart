import 'package:flutter/foundation.dart';

// Mock data ตาม Top Level Specification ของ BMS Executive Project Monitoring
// Dashboard (สัปดาห์ที่ 37 / 2569) — KPI / สรุปรายฝ่าย / รายผู้จัดการ
// คำนวณจากข้อมูลชุดนี้ ไม่ hardcode พร้อมสลับเป็น API จริงภายหลัง

class WeekInfo {
  static const int weekNo = 37;
  static const int year = 2569;
  static const String dateRange = '6 - 10 ก.ค. 2569';
}

class WorkStatus {
  static const String notStarted = 'ยังไม่ได้ทำ';
  static const String inProgress = 'กำลังดำเนินการ';
  static const String review = 'รอตรวจสอบ';
  static const String waitInfo = 'รอข้อมูล';
  static const String waitDecision = 'รอผู้บริหารตัดสินใจ';
  static const String done = 'เสร็จแล้ว';
  static const String delayed = 'ล่าช้า';
  static const String cancelled = 'ยกเลิก';

  static const List<String> all = [
    notStarted,
    inProgress,
    review,
    waitInfo,
    waitDecision,
    done,
    delayed,
    cancelled,
  ];
}

class RiskLevel {
  static const String low = 'ต่ำ';
  static const String medium = 'กลาง';
  static const String high = 'สูง';
  static const String critical = 'วิกฤต';
}

class WorkItem {
  const WorkItem({
    required this.id,
    required this.title,
    required this.department,
    required this.project,
    required this.owner,
    required this.manager,
    required this.status,
    required this.progress,
    this.problem = '',
    this.solution = '',
    this.summary = '',
    required this.nextAction,
    this.startDate,
    required this.dueDate,
    required this.riskLevel,
    this.impact = '',
    this.decisionRequired = false,
    this.escalationNote = '',
    this.weekNo = WeekInfo.weekNo,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String department;
  final String project;
  final String owner;
  final String manager;
  final String status;
  final int progress;
  final String problem;
  final String solution;
  final String summary;
  final String nextAction;
  final String? startDate;
  final String dueDate;
  final String riskLevel;
  final String impact;
  final bool decisionRequired;
  final String escalationNote;
  final int weekNo;
  final String updatedAt;

  bool get isHighRisk =>
      riskLevel == RiskLevel.high || riskLevel == RiskLevel.critical;

  // งานที่ MD / CEO ต้องสนใจ (สเปกข้อ 7.4)
  bool get needsAttention =>
      isHighRisk ||
      decisionRequired ||
      status == WorkStatus.notStarted ||
      status == WorkStatus.delayed;
}

class ManagerInfo {
  const ManagerInfo({
    required this.id,
    required this.name,
    required this.department,
    required this.reportSubmitted,
    required this.score,
    required this.avatarUrl,
  });

  final String id;
  final String name;
  final String department;
  final bool reportSubmitted;
  final int score;
  final String avatarUrl;
}

/// ตำแหน่งงาน (mock) — deterministic จาก index ของ PM
const List<String> _positionPool = [
  'ผู้จัดการโครงการพัฒนาระบบ',
  'ผู้จัดการโครงการวิเคราะห์ข้อมูล',
  'ผู้จัดการโครงการ Implement',
  'ผู้จัดการโครงการเชื่อมต่อระบบ',
  'ผู้จัดการโครงการนวัตกรรม',
  'ผู้จัดการโครงการระบบสุขภาพ',
];

extension ManagerPositionX on ManagerInfo {
  String get position {
    final idx = managers.indexWhere((x) => x.id == id).clamp(0, 99);
    return _positionPool[idx % _positionPool.length];
  }
}

const List<String> departments = [
  'Health Flow',
  'BMS Development',
  'Smart Innovation',
  'งานอื่น ๆ',
];

const List<ManagerInfo> managers = [
  ManagerInfo(
      id: 'M1',
      name: 'สมชาย วัฒนกุล',
      department: 'BMS Development',
      reportSubmitted: true,
      score: 65,
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=faces'),
  ManagerInfo(
      id: 'M2',
      name: 'นุชนารถ ศรีสุวรรณ',
      department: 'Health Flow',
      reportSubmitted: true,
      score: 78,
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&h=150&fit=crop&crop=faces'),
  ManagerInfo(
      id: 'M3',
      name: 'มงคล ธาราทรัพย์',
      department: 'Smart Innovation',
      reportSubmitted: true,
      score: 92,
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=faces'),
  ManagerInfo(
      id: 'M4',
      name: 'อรรถพล บุญประเสริฐ',
      department: 'งานอื่น ๆ',
      reportSubmitted: true,
      score: 80,
      avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150&h=150&fit=crop&crop=faces'),
  ManagerInfo(
      id: 'M5',
      name: 'กิตติพงศ์ ศรีวิไล',
      department: 'BMS Development',
      reportSubmitted: true,
      score: 74,
      avatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150&h=150&fit=crop&crop=faces'),
  ManagerInfo(
      id: 'M6',
      name: 'วิภาดา จันทร์เพ็ญ',
      department: 'Health Flow',
      reportSubmitted: true,
      score: 88,
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&h=150&fit=crop&crop=faces'),
  ManagerInfo(
      id: 'M7',
      name: 'ธนวัฒน์ พงษ์พานิช',
      department: 'Smart Innovation',
      reportSubmitted: true,
      score: 69,
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=faces'),
  ManagerInfo(
      id: 'M8',
      name: 'ศิริพร แก้วกาญจน์',
      department: 'BMS Development',
      reportSubmitted: true,
      score: 91,
      avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&h=150&fit=crop&crop=faces'),
  ManagerInfo(
      id: 'M9',
      name: 'ปรีชา สุขสวัสดิ์',
      department: 'งานอื่น ๆ',
      reportSubmitted: false,
      score: 58,
      avatarUrl: 'https://images.unsplash.com/photo-1552058544-f2b08422138a?w=150&h=150&fit=crop&crop=faces'),
  ManagerInfo(
      id: 'M10',
      name: 'อัญชลี วงศ์วานิช',
      department: 'Health Flow',
      reportSubmitted: true,
      score: 83,
      avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=faces'),
  ManagerInfo(
      id: 'M11',
      name: 'ณัฐพล ตั้งตระกูล',
      department: 'BMS Development',
      reportSubmitted: true,
      score: 77,
      avatarUrl: 'https://images.unsplash.com/photo-1566492031773-4f4e44671857?w=150&h=150&fit=crop&crop=faces'),
  ManagerInfo(
      id: 'M12',
      name: 'พิมพ์ชนก อินทรวงศ์',
      department: 'Smart Innovation',
      reportSubmitted: true,
      score: 95,
      avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&h=150&fit=crop&crop=faces'),
  ManagerInfo(
      id: 'M13',
      name: 'วีระชัย มั่นคงดี',
      department: 'งานอื่น ๆ',
      reportSubmitted: true,
      score: 62,
      avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150&h=150&fit=crop&crop=faces'),
  ManagerInfo(
      id: 'M14',
      name: 'สุภาวดี ชัยมงคล',
      department: 'Health Flow',
      reportSubmitted: false,
      score: 86,
      avatarUrl: 'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=150&h=150&fit=crop&crop=faces'),
  ManagerInfo(
      id: 'M15',
      name: 'ชัยวัฒน์ ประดิษฐ์ผล',
      department: 'BMS Development',
      reportSubmitted: true,
      score: 71,
      avatarUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150&h=150&fit=crop&crop=faces'),
  ManagerInfo(
      id: 'M16',
      name: 'กมลชนก บุตรดี',
      department: 'Smart Innovation',
      reportSubmitted: true,
      score: 90,
      avatarUrl: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150&h=150&fit=crop&crop=faces'),
  ManagerInfo(
      id: 'M17',
      name: 'ภาณุพงศ์ เรืองศรี',
      department: 'งานอื่น ๆ',
      reportSubmitted: false,
      score: 55,
      avatarUrl: 'https://images.unsplash.com/photo-1500259571355-332da5cb07aa?w=150&h=150&fit=crop&crop=faces'),
  ManagerInfo(
      id: 'M18',
      name: 'ดวงกมล สายสุวรรณ',
      department: 'Health Flow',
      reportSubmitted: true,
      score: 82,
      avatarUrl: 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=150&h=150&fit=crop&crop=faces'),
  ManagerInfo(
      id: 'M19',
      name: 'สิทธิชัย โชติช่วง',
      department: 'BMS Development',
      reportSubmitted: true,
      score: 68,
      avatarUrl: 'https://images.unsplash.com/photo-1463453091185-61582044d556?w=150&h=150&fit=crop&crop=faces'),
  ManagerInfo(
      id: 'M20',
      name: 'จารุวรรณ ทองใบ',
      department: 'งานอื่น ๆ',
      reportSubmitted: true,
      score: 79,
      avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&h=150&fit=crop&crop=faces'),
];

const List<WorkItem> _curatedWorks = [
  WorkItem(
    id: 'W-3701',
    title: 'Marketplace',
    department: 'BMS Development',
    project: 'BMS Marketplace',
    owner: 'ผู้จัดการโครงการ',
    manager: 'สมชาย วัฒนกุล',
    status: WorkStatus.notStarted,
    progress: 0,
    problem: 'ยังไม่มี Owner และยังไม่กำหนดวันเริ่มดำเนินการ',
    solution: 'เสนอรายชื่อ Owner ให้ผู้บริหารพิจารณา',
    summary: 'งานยังไม่เริ่ม กระทบแผนพัฒนาระบบ Marketplace ของบริษัท',
    nextAction: 'กำหนด Owner และวันเริ่มงาน',
    dueDate: '2569-07-31',
    riskLevel: RiskLevel.high,
    impact: 'กระทบแผนพัฒนาระบบ Marketplace ของบริษัท',
    decisionRequired: true,
    escalationNote: 'เร่งรัดการกำหนดทิศทางและแผนงาน',
    updatedAt: '2569-07-06',
  ),
  WorkItem(
    id: 'W-3702',
    title: 'ERP Office',
    department: 'BMS Development',
    project: 'ERP ภายในองค์กร',
    owner: 'ผู้จัดการโครงการ',
    manager: 'สมชาย วัฒนกุล',
    status: WorkStatus.notStarted,
    progress: 0,
    problem: 'ยังไม่มีแผนเริ่มดำเนินการ',
    solution: 'จัดทำแผนงานเบื้องต้นเสนอในสัปดาห์หน้า',
    summary: 'งานยังไม่เริ่ม ต้องขอแผนการดำเนินงานจากทีม',
    nextAction: 'ขอแผนเริ่มดำเนินการ',
    dueDate: '2569-08-15',
    riskLevel: RiskLevel.high,
    impact: 'กระทบแผนปรับปรุงระบบงานสำนักงาน',
    decisionRequired: true,
    escalationNote: 'ต้องการให้ผู้บริหารอนุมัติแผนและทรัพยากร',
    updatedAt: '2569-07-06',
  ),
  WorkItem(
    id: 'W-3703',
    title: 'API บริจาคดวงตา',
    department: 'BMS Development',
    project: 'เชื่อมต่อโรงพยาบาลราชวิถี',
    owner: 'ทีมพัฒนา',
    manager: 'สมชาย วัฒนกุล',
    status: WorkStatus.inProgress,
    progress: 60,
    problem: 'การเชื่อมต่อและการ Sync ข้อมูลไปยังโรงพยาบาลราชวิถียังไม่เสถียร',
    solution: 'ทดสอบ API ร่วมกับทีมโรงพยาบาลและปรับ Retry Logic',
    summary: 'พัฒนาแล้ว 60% อยู่ระหว่างทดสอบการ Sync ข้อมูล',
    nextAction: 'ติดตาม API และการ Sync',
    startDate: '2569-06-15',
    dueDate: '2569-07-20',
    riskLevel: RiskLevel.high,
    impact: 'กระทบการเชื่อมต่อข้อมูลกับโรงพยาบาล',
    updatedAt: '2569-07-06',
  ),
  WorkItem(
    id: 'W-3704',
    title: 'ระบบหลังปรับ Server',
    department: 'งานอื่น ๆ',
    project: 'Infra / Support',
    owner: 'ทีม Support',
    manager: 'อรรถพล บุญประเสริฐ',
    status: WorkStatus.inProgress,
    progress: 80,
    problem: 'ต้องเฝ้าระวังประสิทธิภาพระบบหลังการปรับ Server',
    solution: 'ตั้ง Monitoring และ Alert เพิ่มเติม',
    summary: 'ระบบทำงานปกติ อยู่ระหว่างเฝ้าระวังต่อเนื่อง',
    nextAction: 'Monitor การใช้งาน',
    startDate: '2569-06-30',
    dueDate: '2569-07-14',
    riskLevel: RiskLevel.medium,
    impact: 'กระทบระบบหลักของบริษัทหากไม่เสถียร',
    updatedAt: '2569-07-06',
  ),
  WorkItem(
    id: 'W-3705',
    title: 'Health Flow Application',
    department: 'Health Flow',
    project: 'Health Flow',
    owner: 'ทีม Health Flow',
    manager: 'นุชนารถ ศรีสุวรรณ',
    status: WorkStatus.inProgress,
    progress: 55,
    problem: 'ฟีเจอร์หลักยังพัฒนาไม่ครบตามแผน',
    solution: 'เพิ่มรอบทดสอบและจัดลำดับฟีเจอร์ใหม่',
    summary: 'อยู่ระหว่างพัฒนา ต้องติดตามต่อเนื่อง',
    nextAction: 'ทดสอบฟีเจอร์หลักและสรุปแผนส่งมอบ',
    startDate: '2569-06-01',
    dueDate: '2569-07-25',
    riskLevel: RiskLevel.high,
    impact: 'กระทบแผนส่งมอบให้ลูกค้า',
    updatedAt: '2569-07-06',
  ),
  WorkItem(
    id: 'W-3706',
    title: 'Health Flow Dashboard',
    department: 'Health Flow',
    project: 'Health Flow',
    owner: 'ทีม Health Flow',
    manager: 'นุชนารถ ศรีสุวรรณ',
    status: WorkStatus.inProgress,
    progress: 45,
    problem: 'รอข้อมูลตัวชี้วัดเพิ่มเติมจากลูกค้า',
    solution: 'นัดประชุมสรุปตัวชี้วัดกับลูกค้าในสัปดาห์นี้',
    summary: 'Dashboard โครงหลักเสร็จแล้ว รอสรุปตัวชี้วัด',
    nextAction: 'สรุปตัวชี้วัดและออกแบบหน้าจอเพิ่ม',
    startDate: '2569-06-10',
    dueDate: '2569-07-30',
    riskLevel: RiskLevel.medium,
    impact: 'กระทบกำหนดส่งมอบ Dashboard',
    updatedAt: '2569-07-06',
  ),
  WorkItem(
    id: 'W-3707',
    title: 'App เชื่อมอุปกรณ์',
    department: 'Health Flow',
    project: 'Health Flow',
    owner: 'ทีม Health Flow',
    manager: 'นุชนารถ ศรีสุวรรณ',
    status: WorkStatus.delayed,
    progress: 30,
    problem: 'การเชื่อมต่ออุปกรณ์บางรุ่นไม่เสถียร ทำให้งานช้ากว่าแผน',
    solution: 'ประสานผู้ผลิตอุปกรณ์และปรับ Firmware',
    summary: 'ล่าช้ากว่าแผน 1 สัปดาห์ จากปัญหาการเชื่อมต่ออุปกรณ์',
    nextAction: 'ทดสอบอุปกรณ์รุ่นใหม่และอัปเดตแผน',
    startDate: '2569-05-20',
    dueDate: '2569-07-05',
    riskLevel: RiskLevel.high,
    impact: 'กระทบการใช้งานร่วมกับอุปกรณ์ของลูกค้า',
    updatedAt: '2569-07-06',
  ),
  WorkItem(
    id: 'W-3708',
    title: 'KIOSK Sales Plan',
    department: 'Smart Innovation',
    project: 'Smart Innovation',
    owner: 'ทีม Smart Innovation',
    manager: 'มงคล ธาราทรัพย์',
    status: WorkStatus.inProgress,
    progress: 70,
    summary: 'ยอดขายเป็นไปตามแผน อยู่ระหว่างขยายจุดติดตั้ง',
    nextAction: 'สรุปยอดขายรายสัปดาห์และแผนขยายจุดติดตั้ง',
    startDate: '2569-06-01',
    dueDate: '2569-08-31',
    riskLevel: RiskLevel.low,
    updatedAt: '2569-07-06',
  ),
  WorkItem(
    id: 'W-3709',
    title: 'KIOSK / Telemedicine Promotion',
    department: 'Smart Innovation',
    project: 'Smart Innovation',
    owner: 'ทีม Smart Innovation',
    manager: 'มงคล ธาราทรัพย์',
    status: WorkStatus.inProgress,
    progress: 65,
    summary: 'แคมเปญเป็นไปตามแผน ติดตามผลตอบรับต่อเนื่อง',
    nextAction: 'ติดตามผลแคมเปญและยอดใช้งาน Telemedicine',
    startDate: '2569-06-15',
    dueDate: '2569-08-15',
    riskLevel: RiskLevel.low,
    updatedAt: '2569-07-06',
  ),
];

class DepartmentStats {
  const DepartmentStats({
    required this.name,
    required this.total,
    required this.inProgress,
    required this.notStarted,
    required this.delayed,
    required this.highRisk,
  });

  final String name;
  final int total;
  final int inProgress;
  final int notStarted;
  final int delayed;
  final int highRisk;

  // สถานะรวมของฝ่าย ตามตัวอย่างในสเปกข้อ 7.5
  String get status {
    if (notStarted >= 2 || (highRisk >= 2 && notStarted > 0)) {
      return 'ต้องเร่งรัด';
    }
    if (highRisk >= 2) return 'ต้องติดตาม';
    if (highRisk >= 1 || delayed >= 1) return 'เฝ้าระวัง';
    return 'ปกติ';
  }
}

class ManagerStats {
  const ManagerStats({
    required this.info,
    required this.total,
    required this.highRisk,
    required this.notStarted,
    required this.delayed,
  });

  final ManagerInfo info;
  final int total;
  final int highRisk;
  final int notStarted;
  final int delayed;
}

class DashboardFilter {
  const DashboardFilter({
    this.department,
    this.manager,
    this.status,
    this.highRiskOnly = false,
    this.decisionOnly = false,
    this.search = '',
  });

  final String? department;
  final String? manager;
  final String? status;
  final bool highRiskOnly;
  final bool decisionOnly;
  final String search;

  bool get isActive =>
      department != null ||
      manager != null ||
      status != null ||
      highRiskOnly ||
      decisionOnly ||
      search.trim().isNotEmpty;

  DashboardFilter copyWith({
    Object? department = _sentinel,
    Object? manager = _sentinel,
    Object? status = _sentinel,
    bool? highRiskOnly,
    bool? decisionOnly,
    String? search,
  }) =>
      DashboardFilter(
        department: department == _sentinel
            ? this.department
            : department as String?,
        manager: manager == _sentinel ? this.manager : manager as String?,
        status: status == _sentinel ? this.status : status as String?,
        highRiskOnly: highRiskOnly ?? this.highRiskOnly,
        decisionOnly: decisionOnly ?? this.decisionOnly,
        search: search ?? this.search,
      );

  static const Object _sentinel = Object();

  List<WorkItem> apply(List<WorkItem> items) {
    final q = search.trim().toLowerCase();
    return items.where((w) {
      if (department != null && w.department != department) return false;
      if (manager != null && w.manager != manager) return false;
      if (status != null && w.status != status) return false;
      if (highRiskOnly && !w.isHighRisk) return false;
      if (decisionOnly && !w.decisionRequired) return false;
      if (q.isNotEmpty) {
        final hay =
            '${w.title} ${w.project} ${w.manager} ${w.department} ${w.problem} ${w.nextAction}'
                .toLowerCase();
        if (!hay.contains(q)) return false;
      }
      return true;
    }).toList();
  }
}

List<DepartmentStats> departmentStats(List<WorkItem> items) => departments
    .map((d) {
      final ws = items.where((w) => w.department == d).toList();
      return DepartmentStats(
        name: d,
        total: ws.length,
        inProgress:
            ws.where((w) => w.status == WorkStatus.inProgress).length,
        notStarted:
            ws.where((w) => w.status == WorkStatus.notStarted).length,
        delayed: ws.where((w) => w.status == WorkStatus.delayed).length,
        highRisk: ws.where((w) => w.isHighRisk).length,
      );
    })
    .where((d) => d.total > 0)
    .toList();

List<ManagerStats> managerStats(List<WorkItem> items) => managers
    .map((m) {
      final ws = items.where((w) => w.manager == m.name).toList();
      return ManagerStats(
        info: m,
        total: ws.length,
        highRisk: ws.where((w) => w.isHighRisk).length,
        notStarted:
            ws.where((w) => w.status == WorkStatus.notStarted).length,
        delayed: ws.where((w) => w.status == WorkStatus.delayed).length,
      );
    })
    .where((m) => m.total > 0)
    .toList();

/// งานทั้งหมด = งานตัวอย่างตามสเปก (PM1-PM4) + งาน mock ของ PM5-PM20
final List<WorkItem> works = [..._curatedWorks, ..._buildGeneratedWorks()];

const List<String> _taskTitles = [
  'ระบบ HR Portal', 'Mobile App ลูกค้า', 'ระบบคลังยา', 'LINE OA Integration',
  'ระบบแจ้งซ่อม', 'Data Warehouse', 'ระบบ E-Document', 'Chatbot บริการลูกค้า',
  'ระบบนัดหมายแพทย์', 'IoT Sensor Platform', 'ระบบสมาชิก', 'Payment Gateway',
  'ระบบรายงานผู้บริหาร', 'Website องค์กร', 'ระบบประเมินพนักงาน', 'API Gateway',
  'ระบบจัดซื้อ', 'Telemedicine Phase 2', 'ระบบ Inventory', 'Security Audit',
  'ระบบ Training Online', 'Kiosk รุ่นใหม่', 'ระบบคิวอัจฉริยะ', 'Backup & DR',
  'CRM Integration', 'ระบบบัญชี', 'Dashboard ฝ่ายขาย', 'ระบบลางาน',
  'OCR เอกสาร', 'ระบบขนส่ง', 'แอปสุขภาพพนักงาน', 'ระบบสต๊อกยา',
  'ระบบ Feedback ลูกค้า', 'Migration ระบบเก่า', 'ระบบ Audit Log',
  'แอปนัดรับยา', 'ระบบบริหารเตียง', 'Portal คู่ค้า', 'ระบบแต้มสะสม',
  'อัปเกรด Database',
];

List<WorkItem> _buildGeneratedWorks() {
  final items = <WorkItem>[];
  var wid = 3710;
  var titleIdx = 0;
  // PM1-PM4 เพิ่มงานเสริมจากงานตามสเปก, PM5-PM20 คนละ 3-5 งาน
  for (var i = 0; i < managers.length; i++) {
    final m = managers[i];
    final taskCount = i < 4 ? 2 : 3 + i % 3;
    for (var t = 0; t < taskCount; t++) {
      final pattern = (i + t) % 5;
      final status = switch (pattern) {
        0 => WorkStatus.done,
        1 => WorkStatus.inProgress,
        2 => WorkStatus.inProgress,
        3 => WorkStatus.delayed,
        _ => WorkStatus.notStarted,
      };
      final progress = switch (status) {
        WorkStatus.done => 100,
        WorkStatus.inProgress => 30 + (i * 7 + t * 13) % 55,
        WorkStatus.delayed => 15 + (i * 5) % 40,
        _ => 0,
      };
      final risk = switch (status) {
        WorkStatus.delayed => RiskLevel.high,
        WorkStatus.notStarted => (i % 2 == 0) ? RiskLevel.high : RiskLevel.medium,
        WorkStatus.done => RiskLevel.low,
        _ => (i + t) % 4 == 0 ? RiskLevel.medium : RiskLevel.low,
      };
      final title = _taskTitles[titleIdx % _taskTitles.length];
      titleIdx++;
      items.add(WorkItem(
        id: 'W-$wid',
        title: title,
        department: m.department,
        project: m.department,
        owner: 'ทีม ${m.department}',
        manager: m.name,
        status: status,
        progress: progress,
        problem: status == WorkStatus.delayed
            ? 'งานล่าช้ากว่าแผนจากข้อจำกัดด้านทรัพยากร'
            : (status == WorkStatus.notStarted ? 'ยังไม่ได้เริ่มดำเนินการ' : ''),
        solution: status == WorkStatus.delayed
            ? 'ปรับแผนและเพิ่มกำลังคนชั่วคราว'
            : '',
        summary: status == WorkStatus.done
            ? 'ส่งมอบเรียบร้อยตามแผน'
            : 'อยู่ระหว่างดำเนินการตามแผนสัปดาห์นี้',
        nextAction: status == WorkStatus.done
            ? 'ปิดงานและสรุปบทเรียน'
            : 'อัปเดตความคืบหน้าในรายงานสัปดาห์ถัดไป',
        startDate: status == WorkStatus.notStarted ? null : '2569-06-${10 + (i % 15)}',
        dueDate: '2569-0${7 + (t % 2)}-${10 + (i % 18)}',
        riskLevel: risk,
        impact: risk == RiskLevel.high ? 'กระทบแผนงานของฝ่าย ${m.department}' : '',
        decisionRequired: status == WorkStatus.notStarted && i % 8 == 4,
        escalationNote:
            status == WorkStatus.notStarted && i % 8 == 4 ? 'ขอผู้บริหารอนุมัติทรัพยากรเริ่มงาน' : '',
        updatedAt: '2569-07-06',
      ));
      wid++;
    }
  }
  return items;
}

/// งานย่อย (mock) — สถานะ + บันทึกปัญหา/แก้ไข/สรุป สำหรับ drawer
class SubTask {
  const SubTask(this.title, this.status,
      {this.problem, this.solution, this.summary});

  final String title;
  final String status; // 'done' | 'doing' | 'todo'
  final String? problem;
  final String? solution;
  final String? summary;
}

const List<String> _subTaskTitlePool = [
  'ติดตั้งงานเชื่อมเครื่องวัดความดัน 21 ไซต์',
  'ติดตั้งระบบเชื่อมต่อ EKG 10 ไซต์',
  'กำกับงานพัฒนาเชื่อมต่อระบบ EKG 1 บริษัท',
  'ประชุมงานพัฒนาเชื่อมต่อระบบสายพานยา 1 บริษัท',
  'ติดตามการ Support แก้ไขปัญหาไซต์ รพ.นราธิวาส',
  'ติดตามการ Support แก้ไขปัญหาไซต์ รพ.วังทอง',
  'จัดทำระบบ Center สำหรับการบริหารจัดการงานเชื่อมต่อ',
  'ตรวจสอบข้อมูล visit และตั้งค่าระบบก่อนใช้งานจริง',
  'ทดสอบการส่งข้อมูลเข้าระบบ HOSxP',
  'อัปเดตเอกสารคู่มือการใช้งานให้ทีม Support',
];

const List<String> _problemPool = [
  'พบว่ามีข้อมูลน้ำหนัก ส่วนสูง ที่ HOSxP ไม่ตรงกับที่ชั่งมา ซึ่งระบบมีการนำข้อมูล visit ก่อนหน้ามาตั้งต้นไว้',
  'ลูกค้า (บริษัท) ที่เพิ่งเริ่มเชื่อมต่อยังขาดการประสานกับ รพ. ทำให้มีการเลื่อนออกไปไม่ยืนยันวันที่แน่นอน',
  'เจ้าหน้าที่หน้างานเปิดหน้าจอค้างไว้ ทำให้ข้อมูลที่วัดใหม่ไม่ถูกบันทึกทับค่าเดิม',
  'เครือข่ายภายใน รพ. ไม่เสถียรช่วงเช้า ทำให้การส่งข้อมูลบางรายการล้มเหลว',
];

const List<String> _solutionPool = [
  'แจ้งขั้นตอนการใช้งานให้ถูกต้อง / เคสที่ต้องการให้คนไข้ทำการชั่งน้ำหนัก วัดส่วนสูงใหม่ ต้องปิดหน้าจอที่ค้างอยู่ก่อน',
  'ปรับให้ทางทีมมีการประสานกับทั้ง 2 ฝ่าย (บริษัทเครื่อง และ รพ.) ก่อน 1 รอบในวันพุธ และเก็บตกอีกครั้งในวันศุกร์',
  'ประสานทีม Network ของ รพ. ตรวจสอบและเพิ่มความเสถียรของสัญญาณในจุดติดตั้ง',
  'จัดทำ checklist ก่อนเริ่มงานทุกไซต์ เพื่อลดความผิดพลาดซ้ำ',
];

const List<String> _summaryPool = [
  'แจ้งขั้นตอนการใช้งานให้ทีมหน้างานรับทราบครบทุกไซต์แล้ว',
  'ปรับรูปแบบการประสานงานก่อนเข้าหน้างาน ลดการเลื่อนนัดได้',
  'เสร็จสิ้นโครงการ',
  'ส่งมอบงานและเอกสารให้ทีม Support ดูแลต่อเรียบร้อย',
];

/// งานย่อยของ task — deterministic จากชื่องาน + กลุ่มสถานะของงานแม่
List<SubTask> subTasksFor(String title, String group) {
  final seed = title.length + title.codeUnitAt(0);
  final n = 2 + seed % 3; // 2-4 งานย่อย
  final items = <SubTask>[];
  for (var i = 0; i < n; i++) {
    final st = _subTaskTitlePool[(seed + i) % _subTaskTitlePool.length];
    final String status;
    if (group == 'done') {
      status = 'done';
    } else if (group == 'doing') {
      status = i < (n / 2).ceil() ? 'done' : 'doing';
    } else {
      status = 'todo';
    }
    items.add(SubTask(
      st,
      status,
      problem:
          status == 'done' ? _problemPool[(seed + i) % _problemPool.length] : null,
      solution: status == 'done'
          ? _solutionPool[(seed + i) % _solutionPool.length]
          : null,
      summary:
          status == 'done' ? _summaryPool[(seed + i) % _summaryPool.length] : null,
    ));
  }
  return items;
}

/// งานประจำหรือไม่ (mock) — deterministic จากชื่องาน
bool isRoutineTask(String title) => title.length % 3 == 0;

/// เวลาส่งรายงาน (mock) — null ถ้ายังไม่ส่ง
String? submittedAt(ManagerInfo m) {
  if (!m.reportSubmitted) return null;
  final idx = managers.indexWhere((x) => x.id == m.id).clamp(0, 99);
  final day = 3 + idx % 2;
  final hh = (idx * 7) % 24;
  final mm = (idx * 13) % 60;
  return 'ส่ง $day ก.ค. 2569 '
      '${hh.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}';
}

/// งานสัปดาห์ก่อนหน้า (mock) — โครงสร้างสำหรับ drawer และการ์ด PM
class PrevWeekTask {
  const PrevWeekTask(this.title, this.group, this.carried);

  final String title;
  final String group; // 'done' | 'doing' | 'todo'
  final bool carried; // ต่อเนื่องมาถึงสัปดาห์นี้
}

const List<String> _prevWeekTitlePool = [
  'อัพเดตไฟล์แผนการดำเนินงาน และยอดขายปี 2569',
  'ประชุมนำเสนอเป้าปี 2569 วันอังคารที่ 30 มิถุนายน',
  'เข้าร่วมประชุมคุยรายละเอียดเตรียมความพร้อมทำ Tool Migration กับ รพ.พระพุทธบาท จ.สระบุรี',
  'สรุปผลทดสอบระบบรอบ UAT พร้อมรายการแก้ไข',
  'จัดทำเอกสาร Requirement ให้ทีมพัฒนา',
  'ติดตามผล Feedback จากลูกค้าหลังอัปเดตเวอร์ชันใหม่',
  'ประชุมติดตามความคืบหน้ากับทีม Vendor ประจำสัปดาห์',
  'ตรวจสอบและปิด Issue ค้างใน Backlog',
  'เตรียม Demo ระบบสำหรับผู้บริหารรอบเดือน ก.ค.',
  'อบรมการใช้งานระบบให้ผู้ใช้งานหน่วยงานนำร่อง',
  'วางแผนกำลังคนและมอบหมายงานสัปดาห์ถัดไป',
  'ทบทวนความเสี่ยงโครงการและแผนสำรอง',
  'ประสานงานฝ่ายจัดซื้อเรื่องต่อสัญญา License',
  'จัดทำรายงานสรุปผลประจำเดือนส่งผู้บริหาร',
  'ทดสอบ Performance ระบบหลังปรับ Infrastructure',
  'Review Design หน้าจอชุดใหม่ร่วมกับทีม UX',
];

/// รายการงานสัปดาห์ที่แล้วของ PM — deterministic จาก index ของ PM
List<PrevWeekTask> prevWeekTasks(ManagerInfo m) {
  final idx = managers.indexWhere((x) => x.id == m.id).clamp(0, 99);
  final doneCount = 2 + idx % 3; // 2-4 งานเสร็จ
  final doingCount = 1 + idx % 2; // 1-2 งานต่อเนื่อง
  final todoCount = idx % 2; // 0-1 งานยังไม่ได้ทำ
  final items = <PrevWeekTask>[];
  var t = idx * 3;
  String pick() =>
      _prevWeekTitlePool[(t++) % _prevWeekTitlePool.length];
  for (var i = 0; i < doneCount; i++) {
    items.add(PrevWeekTask(pick(), 'done', false));
  }
  for (var i = 0; i < doingCount; i++) {
    items.add(PrevWeekTask(pick(), 'doing', true));
  }
  for (var i = 0; i < todoCount; i++) {
    items.add(PrevWeekTask(pick(), 'todo', true));
  }
  return items;
}

/// PM ที่ถูกปักหมุด (จำเฉพาะ session) — ทุกหน้าฟังผ่าน ValueNotifier
final ValueNotifier<Set<String>> pinnedPms = ValueNotifier<Set<String>>({});

void togglePinPm(String id) {
  final next = Set<String>.from(pinnedPms.value);
  next.contains(id) ? next.remove(id) : next.add(id);
  pinnedPms.value = next;
}
