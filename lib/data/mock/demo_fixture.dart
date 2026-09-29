import '../models/models.dart';

/// 「我的」一族的**演示数据**（Figma 原型样例数据）。
///
/// ⚠️⚠️ **仅供视觉走查，不是需求。**
///
/// `CLAUDE.md` §7 明确禁止在 Mock 里编造产品数据（原文点名了
/// 「匹配度 86%」「Alex Chen」这类假数据 —— 它们会被误当成需求）。
/// 因此本文件里的每一条都**逐字来自 Figma 原型**，并且：
///
/// ```text
/// ✅ 只在 MockConfig.demoData == true 时返回
/// ✅ 默认路径完全不碰本文件（默认返回空数据）
/// ✅ 本文件顶部与每个常量都标了 Figma 行号，便于逐条回溯
/// ❌ 不新增原型里没有的条目（包括「凑数」补齐计数）
/// ```
///
/// 开启方式：
///
/// ```bash
/// flutter run --dart-define=CAREERLY_DEMO_DATA=true
/// ```
///
/// ## ⚠️ 原型自身的一处矛盾（**待裁决 · D89**）
///
/// `ProfilePage` 的资产子卡把计数**硬编码**成 `4段 / 6个 / 12项`，
/// 而同一份原型的数组长度是 `3 / 4 / 13`：
///
/// | 项 | 原型硬编码 | 原型数组长度 |
/// |---|---|---|
/// | 工作经历 | `4段`（L3124） | `WORK_EXP.length == 3` |
/// | 项目 | `6个`（L3126） | `PROJECTS_DATA.length == 4` |
/// | 技能 | `12项`（L3128） | `SKILL_CATS` 展平 `13` |
/// | 奖项 | `3个`（L3130） | `AWARDS.length == 3` ✅ |
///
/// 本文件**照抄数组、不补齐数字** —— 补齐就意味着**编造**第 4 段经历、
/// 第 5/6 个项目，那正是 §7 禁止的事。计数由数据派生，
/// 因此演示态显示的是 `3/4/13/3`，与原型屏幕上写的数字不同。
/// **这个差异是原型自身的，不是 Flutter 侧的偏差。**
///
/// 📌 另注：`CareerAssetsPage` 自己的计数（L3395 / L3409 / L3424 / L3438）
/// 同样是**派生**的（`${WORK_EXP.length} 段职业经历` 等），
/// 于是同一份原型里「子卡写 4 段、分组卡写 3 段」—— 矛盾更明显。
abstract final class DemoFixture {
  /// Figma `WORK_EXP`（`src/App.tsx` L56-60），**共 3 条**。
  ///
  /// ⚠️ 原型的 `desc` 字段对应本项目的 `WorkExperience.description`。
  static const List<WorkExperience> workExperiences = <WorkExperience>[
    WorkExperience(
      id: 'work-0',
      period: '2024.06 — 至今',
      title: '产品经理',
      company: 'AI 科技公司',
      description:
          '负责 AI 产品规划与落地，主导 3 个 AI 应用产品从 0 到 1 上线，管理跨职能团队协作，推动产品月活增长 40%。',
      skills: <SkillDelta>[
        SkillDelta(name: '产品规划', delta: 5),
        SkillDelta(name: 'AI 应用能力', delta: 8),
        SkillDelta(name: '项目管理', delta: 3),
      ],
      projects: <String>['AI 招聘助手', 'AI 产品分析工具'],
    ),
    WorkExperience(
      id: 'work-1',
      period: '2022.04 — 2024.05',
      title: '产品设计师',
      company: '互联网公司',
      description:
          '负责 B 端 SaaS 产品设计，主导用户研究和需求分析，建立设计规范体系，参与多个核心功能从需求到上线全流程。',
      skills: <SkillDelta>[
        SkillDelta(name: '用户研究', delta: 5),
        SkillDelta(name: '需求分析', delta: 4),
      ],
      projects: <String>['遗墨 VR', '用户研究系统'],
    ),
    WorkExperience(
      id: 'work-2',
      period: '2020.07 — 2022.03',
      title: '建筑设计师',
      company: '省建筑设计院',
      description:
          '参与多个大型公共建筑项目设计，负责方案设计与施工图绘制，培养了强烈的空间思维与系统规划能力。',
      skills: <SkillDelta>[
        SkillDelta(name: '项目管理', delta: 2),
        SkillDelta(name: '方案规划', delta: 3),
      ],
    ),
  ];

  /// Figma `PROJECTS_DATA`（L61-66），**共 4 条**。
  static const List<ProjectExperience> projects = <ProjectExperience>[
    ProjectExperience(
      id: 'project-0',
      name: 'AI 招聘助手',
      type: 'AI 产品',
      year: '2026',
      role: '产品负责人',
      description:
          '基于 LLM 的智能招聘助手，自动筛选简历和安排面试，帮助 HR 将招聘效率提升 60%。设计了完整的产品功能架构与用户交互流程。',
      outcome: '招聘效率 +60%，月均处理简历 3000+，用户 NPS 72',
      skills: <String>['AI 应用能力', '产品规划', '用户研究'],
      jobImpact: <JobImpact>[JobImpact(job: 'AI 产品经理', delta: 8)],
    ),
    ProjectExperience(
      id: 'project-1',
      name: '职业分析 Agent',
      type: 'AI 产品',
      year: '2026',
      role: '产品负责人',
      description:
          '基于用户职业档案的智能分析系统，帮助用户了解自身能力与目标岗位之间的差距，提供个性化成长建议。',
      outcome: '完成 MVP 上线，月活 DAU 持续增长',
      skills: <String>['AI 应用能力', '数据分析', '产品规划'],
      jobImpact: <JobImpact>[JobImpact(job: '数据产品经理', delta: 4)],
    ),
    ProjectExperience(
      id: 'project-2',
      name: '遗墨 VR',
      type: 'VR / 数字文化',
      year: '2024',
      role: '产品设计师',
      description:
          '将传统墨迹艺术与 VR 交互结合的文化体验产品，探索数字化文化遗产的新形态，获得省级创新设计奖。',
      outcome: '省级设计创新奖，媒体报道 12 篇',
      skills: <String>['用户研究', '需求分析', '交互设计'],
    ),
    ProjectExperience(
      id: 'project-3',
      name: 'AI 产品分析工具',
      type: 'AI 工具',
      year: '2024',
      role: '产品经理',
      description:
          '面向 B 端客户的 AI 产品效果分析看板，支持实时监控 AI 功能使用率和用户反馈数据，辅助产品决策。',
      outcome: 'NPS +25，客户续约率 85%',
      skills: <String>['数据分析', '产品规划', '用户研究'],
      jobImpact: <JobImpact>[JobImpact(job: '数据产品经理', delta: 3)],
    ),
  ];

  /// Figma `SKILL_CATS`（L67-71），3 组共 **13** 项。
  static const List<SkillGroup> skillGroups = <SkillGroup>[
    SkillGroup(
      category: '产品能力',
      skills: <String>['产品规划', '用户研究', '需求分析', '项目管理', '数据驱动决策'],
    ),
    SkillGroup(
      category: 'AI 能力',
      skills: <String>['Prompt Engineering', 'AI Agent', 'LLM 应用', 'AI 产品设计'],
    ),
    SkillGroup(
      category: '工具',
      skills: <String>['Figma', 'Flutter', 'SQL', 'Python 基础'],
    ),
  ];

  /// Figma `AWARDS`（L72-76），**共 3 条**。
  ///
  /// ⚠️ 原型的 `desc` 字段**只被奖项页使用**（`AwardsPage` L3855），
  /// 职业资产页的荣誉成果分组只画 `name` / `year` / `org`（L3575-3576）。
  /// 本文件此前因此略去了 `desc`（当时奖项页尚未实现）。
  /// 奖项页落地后该理由不再成立，三条说明**逐字照抄原型**补回 ——
  /// 是**原型已有的内容**，不是本轮编造。
  static const List<Award> awards = <Award>[
    Award(
      name: '优秀项目奖',
      year: '2025',
      org: 'AI 科技公司',
      description: 'AI 招聘助手项目年度最佳产品奖',
    ),
    Award(
      name: '设计创新奖',
      year: '2024',
      org: '省设计协会',
      description: '遗墨 VR 省级数字文化创新设计奖',
    ),
    Award(
      name: '优秀毕业设计',
      year: '2020',
      org: '华南理工大学',
      description: '建筑学院年度优秀毕业设计，TOP 5%',
    ),
  ];

  /// Figma `SKILLS_DATA`（L44-50），**共 5 项**。
  ///
  /// ⚠️ 能力画像卡上只画了**前 3 项**（L3615-3617），
  /// 但卡底写的是「5 个维度」（L3623）—— 两者一致，不矛盾。
  /// 因此这里保留全部 5 项，由页面决定展示前几项。
  static const List<Capability> capabilities = <Capability>[
    Capability(name: '产品规划', score: 85, delta: 5, previousScore: 80),
    Capability(name: 'AI 应用能力', score: 76, delta: 8, previousScore: 68),
    Capability(name: '用户研究', score: 78, delta: 3, previousScore: 75),
    Capability(name: '数据分析', score: 60, delta: 2, previousScore: 58),
    Capability(name: '项目管理', score: 74, delta: 0, previousScore: 74),
  ];

  /// Figma `CareerAssetsPage` 四张分组卡共用的时间跨度（L3522）。
  static const String spanLabel = '2021/6/8 - 2026/9/9';

  /// Figma 主页资产卡的「本月新增 1 项」（L3227）。
  static const int monthlyAdded = 1;

  /// 职业资产聚合。
  static const CareerAssets careerAssets = CareerAssets(
    workExperiences: workExperiences,
    projects: projects,
    skillGroups: skillGroups,
    awards: awards,
    capabilities: capabilities,
    spanLabel: spanLabel,
    monthlyAdded: monthlyAdded,
  );

  /// Figma `ProfilePage` 信息卡（L3170-3177）。
  ///
  /// ⚠️ **这是样例身份，不是本项目要造的数据** ——
  /// 仅在演示模式下出现，默认路径下「我的」显示的是中性空态。
  static const UserProfile userProfile = UserProfile(
    displayName: 'Alex',
    handle: '@elmasekeri',
    membershipLabel: 'V1会员',
  );

  /// Figma `GROWTH_EVENTS`（月网格日历，`src/App.tsx` L2996-3001），**共 6 条**。
  ///
  /// 日期精度为「日」，喂给成长足迹 Detail 的**月网格日历**。
  /// 类型按 **D91 裁决**映射到本项目模型：
  ///
  /// ```text
  /// analysis  → matchScore（匹配度变化）
  /// resume    → skill（技能变化）
  /// project   → experience（新增经历）
  /// capability→ capability（能力变化）
  /// ```
  ///
  /// ⚠️ 原型的 `tag` 字段（`'86%'` / `'产品规划 +5'` 等）在
  /// [GrowthEvent] 模型里**没有对应字段**（原型自身也未统一渲染它），
  /// 依 §7 不引入；`delta` 里的 `'%'` / `'+'` 由模型重新派生。
  /// 原型事件集中在 2026 年 8 月 —— 在月网格里翻回 2026-08 即可看到圆点。
  static final List<GrowthEvent> growthCalendarEvents = <GrowthEvent>[
    GrowthEvent(
      id: 'growth-cal-0',
      type: GrowthEventType.matchScore,
      title: '完成职业分析',
      description: 'AI 产品经理',
      delta: 8,
      occurredAt: DateTime(2026, 8, 29),
    ),
    GrowthEvent(
      id: 'growth-cal-1',
      type: GrowthEventType.skill,
      title: '更新简历 V3',
      description: '新增 AI Agent 项目',
      occurredAt: DateTime(2026, 8, 27),
    ),
    GrowthEvent(
      id: 'growth-cal-2',
      type: GrowthEventType.experience,
      title: '新增 AI Agent 项目',
      description: '产品负责人',
      occurredAt: DateTime(2026, 8, 20),
    ),
    GrowthEvent(
      id: 'growth-cal-3',
      type: GrowthEventType.capability,
      title: 'AI 应用能力提升',
      description: '68 → 76',
      delta: 8,
      occurredAt: DateTime(2026, 8, 18),
    ),
    GrowthEvent(
      id: 'growth-cal-4',
      type: GrowthEventType.matchScore,
      title: '完成职业分析',
      description: '产品经理',
      delta: 4,
      occurredAt: DateTime(2026, 8, 12),
    ),
    GrowthEvent(
      id: 'growth-cal-5',
      type: GrowthEventType.skill,
      title: '更新简历 V2',
      description: '补充项目经历',
      occurredAt: DateTime(2026, 8, 5),
    ),
  ];

  /// Figma `GROWTH_TIMELINE`（GrowthRecordPage，`src/App.tsx` L3940-3971），
  /// **共 5 条**。
  ///
  /// 日期精度为「月」，喂给成长足迹 Detail 的**成长时间线**。
  /// 原型只有 `date: '2026.08'` 这类月精度 —— DateTime 需要「日」，
  /// 统一取当月 1 号（仅演示用，真实数据来自后端时会带完整日期）。
  /// 类型映射同 [growthCalendarEvents]（D91）。
  /// 原型的 `tag` / `effect` 字段模型无对应、原型页面也未渲染，依 §7 不引入。
  static final List<GrowthEvent> growthTimeline = <GrowthEvent>[
    GrowthEvent(
      id: 'growth-tl-0',
      type: GrowthEventType.experience,
      title: '新增 AI Agent 项目',
      description: '完成 AI 招聘助手 MVP 上线，主导产品规划与落地。',
      occurredAt: DateTime(2026, 8, 1),
    ),
    GrowthEvent(
      id: 'growth-tl-1',
      type: GrowthEventType.capability,
      title: '完成用户研究认证',
      description: '通过专项培训，系统强化用户访谈与数据分析能力。',
      occurredAt: DateTime(2026, 6, 1),
    ),
    GrowthEvent(
      id: 'growth-tl-2',
      type: GrowthEventType.skill,
      title: '更新简历 V2',
      description: '补充用户研究案例，完善职业经历描述与项目成果。',
      occurredAt: DateTime(2026, 5, 1),
    ),
    GrowthEvent(
      id: 'growth-tl-3',
      type: GrowthEventType.matchScore,
      title: '完成职业分析 #2',
      description: '与 3 个目标岗位对比分析，最高匹配度 78%。',
      occurredAt: DateTime(2026, 3, 1),
    ),
    GrowthEvent(
      id: 'growth-tl-4',
      type: GrowthEventType.skill,
      title: '创建第一份简历',
      description: '基于职业经历整理并创建 Resume V1，启动职业成长档案。',
      occurredAt: DateTime(2026, 1, 1),
    ),
  ];
}
