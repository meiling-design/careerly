import '../models/analysis_project.dart';
import '../models/analysis_result.dart';
import '../models/job.dart';

/// 「分析」模块的演示数据（Figma 原型样例）。
///
/// 与 `demo_fixture.dart`（「我的」一族）同一套约定：
///
/// ```text
/// ⚠️⚠️ 仅供视觉走查，不是需求。
/// ✅ 逐字来自 Figma 原型（src/App.tsx 的 JOBS 等），每条标注行号
/// ✅ 只在 MockConfig.demoData == true 时返回
/// ✅ 默认路径完全不碰本文件（MockAnalysisRepository 默认返回空数据）
/// ❌ 不新增原型里没有的条目
/// ```
///
/// ## ⚠️ CLAUDE.md §7 的边界
///
/// §7 明确禁止把「匹配度 86%」这类假数据当需求。本文件的 `86 / 82 / 74 / 68`
/// 是 Figma 原型 `JOBS`（L38-43）里的样例，**只为视觉逐位比对**——
/// 真实能力模型接入后，这些数字必须由匹配计算产出，不得回落到这里。
///
/// ## ⚠️ Figma 原型自身的一处矛盾（岗位详情页 vs Gap 页）
///
/// 岗位详情页（L2358-2359）的「成长空间」是 **3 项、只有等级**
/// （AI 技术深度理解 / 商业化经验 / 数据分析能力，各带「关键 Gap / 一般 Gap」）；
/// Gap 页（L2446-2449）的 Gap 卡片是 **2 项、带数值与行动建议**
/// （AI Agent 产品落地 / 商业化经验，带 yours/target/why/actions）。
///
/// 两处列表**对不上**。本文件取 **Gap 页那份（更丰富）** 作为唯一数据源：
/// 岗位详情页的「成长空间」渲染它的 name + level，
/// Gap 页渲染它的完整三格 + why + actions。
/// 不补齐第 3 项 —— 补齐就意味着编造第 3 项的数值。
abstract final class DemoAnalysisFixture {
  /// 目标岗位（Figma `JOBS`，`src/App.tsx` L38-43）。
  ///
  /// ⚠️ `rawJd` 用的是原型的 `matchSource`（「3段工作经历、2个AI项目…」），
  /// 因为 `Job` 模型**没有** `matchSource` 字段，而 `rawJd`（JD 原文）
  /// 在演示态也没有真实来源 —— 两处都是「岗位相关描述」，
  /// 岗位详情页 Hero 的「来自 …」行按此渲染。**这是演示态的权宜，
  /// 不是 `rawJd` 的语义扩展。**
  static final List<Job> jobs = <Job>[
    Job(
      id: 'demo-job-1',
      title: 'AI 产品经理',
      rawJd: '3段工作经历、2个AI项目、4项技能',
      source: 'demo',
    ),
    Job(
      id: 'demo-job-2',
      title: '产品经理',
      rawJd: '3段工作经历、用户研究',
      source: 'demo',
    ),
    Job(
      id: 'demo-job-3',
      title: '数据产品经理',
      rawJd: '2段工作经历、数据分析经验',
      source: 'demo',
    ),
    Job(
      id: 'demo-job-4',
      title: '用户增长产品',
      rawJd: '运营经验、用户研究',
      source: 'demo',
    ),
  ];

  /// 优势能力（带分数）—— 岗位详情页「能力优势」（L2358）。
  static const List<StrengthScore> strengthScores = <StrengthScore>[
    StrengthScore(name: '产品规划能力', score: 85),
    StrengthScore(name: 'AI 应用能力', score: 76),
    StrengthScore(name: '用户研究', score: 78),
    StrengthScore(name: '项目管理', score: 74),
  ];

  /// 匹配原因 —— 岗位详情页「为什么匹配」（L2391）。
  static const List<String> matchReasons = <String>[
    '产品规划',
    '用户研究',
    'AI 项目经验',
  ];

  /// 能力 Gap 详情 —— 取 Gap 页那份（L2446-2449，最丰富）。
  ///
  /// 与岗位详情页（L2359）的矛盾见类顶说明。
  static const List<GapDetail> gapDetails = <GapDetail>[
    GapDetail(
      name: 'AI Agent 产品落地',
      yours: 68,
      target: 82,
      level: '关键 Gap',
      why: '当前简历中缺少完整 AI Agent 项目的落地结果和产品指标数据。',
      actions: <String>[
        '完成一个可实际运行的 AI Agent 项目',
        '补充需求分析与产品设计文档',
        '了解 LLM API 基础调用与 Prompt Engineering',
        '将项目成果沉淀为可展示的项目经历',
      ],
    ),
    GapDetail(
      name: '商业化经验',
      yours: 64,
      target: 78,
      level: '关键 Gap',
      why: '缺少产品商业模式设计和 GMV / 营收相关数字。',
      actions: <String>[
        '在简历中补充业务目标与商业结果',
        '了解 SaaS 定价和增长模型',
      ],
    ),
  ];

  /// 当前匹配分 / 上次匹配分（`JOBS.match` / `JOBS.prev`，L38-43）。
  ///
  /// 用两份分值构造 **version 1（上次）→ version 2（当前）** 两个结果，
  /// 这样「较上次 ↑+N%」与「历史版本」都有真实来源，而非硬编码 delta。
  static const List<int> matchScores = <int>[86, 82, 74, 68];
  static const List<int> prevScores = <int>[78, 79, 74, 65];

  /// 行动建议（PRD §9.4「AI 提升点 / 行动建议」）。
  ///
  /// 归纳自 Gap 页 `why` / `actions` 的语义（演示值，非产品真值）。
  static const String suggestion =
      '优先补齐 AI Agent 项目落地经验，沉淀可量化的产品指标与业务结果。';

  /// 组装一个**完整演示项目**（4 岗位 × 2 个分析版本）。
  ///
  /// - version 1 = 上次分析（`prevScores`）
  /// - version 2 = 当前分析（`matchScores`，即 [jobs] 的最新匹配）
  static AnalysisProject get demoProject {
    final DateTime v1At = DateTime(2026, 9, 1);
    final DateTime v2At = DateTime(2026, 9, 7);

    AnalysisResult buildResult(int version, List<int> scores, DateTime at) {
      return AnalysisResult(
        id: 'demo-result-$version',
        projectId: 'demo-project',
        version: version,
        matches: <JobMatch>[
          for (int i = 0; i < jobs.length; i++)
            JobMatch(
              jobId: jobs[i].id,
              score: scores[i],
              rank: i + 1,
              strengths: strengthScores
                  .map((StrengthScore s) => s.name)
                  .toList(growable: false),
              gaps: gapDetails
                  .map((GapDetail g) => g.name)
                  .toList(growable: false),
              reasons: matchReasons,
              suggestion: suggestion,
              strengthScores: strengthScores,
              gapDetails: gapDetails,
            ),
        ],
        createdAt: at,
      );
    }

    return AnalysisProject(
      id: 'demo-project',
      name: jobs.first.title,
      jobs: jobs,
      results: <AnalysisResult>[
        buildResult(1, prevScores, v1At),
        buildResult(2, matchScores, v2At),
      ],
      createdAt: v1At,
      updatedAt: v2At,
    );
  }
}
