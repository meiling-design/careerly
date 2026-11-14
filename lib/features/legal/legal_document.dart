/// App 内的协议文档清单。
///
/// 依据 `TODO.md` §1.0f ③ · E2 / E3：注册页的同意文案是
/// 「我已阅读并同意《用户协议》与《隐私政策》」——**只点名两份**。
/// 但 E1 要求三份齐备，因此第三个文件 `AI_DATA_PROCESSING.md`
/// 也在 App 内可达 —— 见下方「第三份文档的入口」。
///
/// ## 第三份文档的入口（2026-10-07 产品侧裁决 · D123 = A）
///
/// Session 023 时这里**只有两个值**，`AI_DATA_PROCESSING.md` 只进资产与镜像，
/// 于是它处于「上架材料里有、用户在 App 里看不到」的状态，
/// 登记为待裁决 **D123**（分类：**IA 冲突**）。
///
/// 产品侧 2026-10-07 选定**方案 A**：在设置页「隐私与数据」下**平铺三个入口**。
/// 因此本枚举补上第三个值，页面类 `LegalDocumentPage` **一个字都不用改**
/// —— 这正是把「两份协议共用一个页面类」做成参数化的收益（`CLAUDE.md` §8.4）。
///
/// ⚠️ 方案 A **不改动任何法律正文**：三份文档仍是三份独立文件，
/// 同意文案也仍是「《用户协议》与《隐私政策》」两份（那是注册门禁，与此无关）。
/// 另两条候选（B 并进隐私政策 / C 不给入口）**未采纳**。
///
/// ## 为什么是一个枚举 + 一个页面，而不是两个页面类
///
/// 依据 `CLAUDE.md` §8.4：「变体用参数，不用新组件」——
/// 只有当两个形态的**行为**真的不同时才拆。两份协议的行为完全相同
/// （同样的读取、同样的四态、同样的返回），差别只有标题与正文来源。
/// 拆成两个类会让它们日后再无理由地各自演化。
///
/// ## 正文的真值源
///
/// 正文在 `assets/legal/*.md`，路径由 [assetPath] 给出。
/// 那是 App 内的**唯一来源**；`work_agent/docs/09_Release/` 下的同名文件
/// 是它的镜像，由 `scripts/sync_legal_docs.ps1` 生成。
/// **改正文只改 .md，不改代码。**
///
/// ⚠️ 这个「源 → 镜像」方向是 **Flutter 侧提的方案**，用于调和 `TODO.md`
/// 里 E1 与 E3 两处原话的冲突，**未经产品侧确认**
/// —— 登记为 **待裁决 · D122**（§3.1）。裁决若反过来，只需反转同步脚本。
enum LegalDocument {
  /// 用户协议。
  termsOfService(
    title: '用户协议',
    assetPath: 'assets/legal/TERMS_OF_SERVICE.md',
  ),

  /// 隐私政策。
  privacyPolicy(
    title: '隐私政策',
    assetPath: 'assets/legal/PRIVACY_POLICY.md',
  ),

  /// AI 数据使用说明。
  ///
  /// ⚠️ 标题取**文档自己的 H1**（`# Careerly AI 数据使用说明`）去掉产品名前缀，
  /// 而不是 `TODO.md` 里简称的「AI 数据处理说明」—— 导航里的名字应当与
  /// 用户打开后看到的那份文件同名。正文标题那一行仍由 `assetPath` 提供。
  aiDataProcessing(
    title: 'AI 数据使用说明',
    assetPath: 'assets/legal/AI_DATA_PROCESSING.md',
  );

  const LegalDocument({required this.title, required this.assetPath});

  /// 页面标题（同时用作 AppBar 标题）。
  final String title;

  /// bundle 内的资产路径。与 `pubspec.yaml` 的 `assets: - assets/legal/` 对应。
  final String assetPath;
}
