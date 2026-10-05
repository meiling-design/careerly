# Careerly — Changelog

> **「为什么做这些产品 / 技术决策」**
>
> **按会话追加，不覆盖历史。** 最新的在最上面。
>
> 每条记录：日期 · 本次完成内容 · 重要决策 · 修改文件 · 测试结果 · 新发现 · 未解决问题 · 下一步
>
> 现状 → `CURRENT_STATUS.md` ｜ 计划 → `TODO.md` ｜ 流程 → `DEVELOPMENT_WORKFLOW.md` ｜ 规则 → `CLAUDE.md`
> 本文件只记录**过程与决策**。
>
> 规则：
> - ✅ 已锁定的产品决策 → 记为「决策」，并在 `docs/07_...Baseline` 中落规则
> - ⚠️ 尚未由产品侧确认的问题 → 记为「**待确认**」，**不得**写成正式产品规则
> - 📄 文档改动 / 💻 代码改动 / 🐞 问题与修复 分列
>
> ℹ️ 本文件原名 `docs/DEV_LOG.md`，2026-09-18 迁入 `docs/05_progress/` 并改名。
> 历史 Session 001–004 内容原样保留，正文中的 `DEV_LOG.md` 自指均指本文件。

---

## Session 021 — 接通 work_agent：真机联调用例首次跑通 + §9-4 首页筛选行溢出修复

**日期**：2026-10-04
**阶段**：Integration Audit 之后的第 0–3 步（第 2 步「真机产品路径验收」未执行：需要设备）
**结论**：✅ 步骤 1 / 3 已完成并**经验证** · ⛔ 步骤 4 到停止点，等产品侧裁决

> ⚠️ **本轮收尾时工作区正被并行编辑**（15:35–15:40 有人改动
> `app_routes` / `app_router` / `auth_repository` / `api_auth_repository` /
> `onboarding_provider` / `api_client` / 各 Token）。
> 因此**全量 `flutter analyze` / `flutter test` 当轮无法执行**
> —— 工作区当时不编译。下面所有「已验证」都注明用的是**哪种**验证方式。
> `auth.login` 新增了必填 `password`，`test/real_backend_integration_test.dart:61,64`
> 因此有待重构方补齐的编译错误（**不是本轮改动造成的**）。

---

### 1. 步骤 1（★ 打开开关、跑通既有联调用例）

**结论**：`real_backend_integration_test.dart` **全绿**
（`04:40 +1: All tests passed!`，退出码 0，真实 LLM 全链路）。

真实后端（`uvicorn app.api.server:app`，127.0.0.1:8000）上确认走通：
register 201 → login 200 → `POST /resume` 200（提交即解析，`structured=True`）
→ `GET /quota` 200 → `POST /analysis` **201**（8 个图节点全 `completed`，
`score=77`，能力快照 5 维）→ 项目列表 / 详情 / `proj_missing`→404 / 岗位库
→ 额度 1/3 → 两类错误路径（无 token 401、`.doc` 422）。

#### 🐞 修掉一个**用例自身**的缺陷（不是产品缺陷）

首跑报 `real_backend_integration_test.dart:117` 失败：
`POST /resume` 无 token 期望 `AuthError`，实际抛
`NetworkError: Connection closed before full header was received`。

定位过程（三步排除）：

| 实验 | 结果 |
|---|---|
| `curl` 匿名 multipart POST（同样带 body） | 干净 **401** → 后端无责 |
| 探针逐个 `await` 同样的三个请求 | 全部 `AuthError` → 客户端无责 |
| 探针**不 await + 立即 `dispose()`** | 两个 multipart 复现出**逐字相同**的 `NetworkError` |

**根因**：第 112–143 行把 `Future` 直接交给 `expect(...)` 而**不 await**。
`expect` 拿到 Future 只登记异步断言就返回，body 继续往下跑到第 145–146 行
`dispose()`（= `ApiClient._http.close()`，`api_client.dart:558`），
把还在飞的多笔请求掐断 —— 后到的响应丢失，`AuthError` / `ParseError`
因此退化成 `NetworkError`。

**修法**：三处 `expect(...)` → `await expectLater(...)`（串行化，也就
不再与 `dispose()` 竞态）。修后第一跑即全绿，且后端日志显示匿名两笔请求
复用**同一条连接**（`:51988`），可佐证串行化生效。

> ℹ️ 第 61 / 64 行的 `auth.register` / `auth.login` 是**另一处**、由并行重构
> 引入的签名变化，与本修无关。

---

### 2. 步骤 3（§9-4 首页「筛选行」溢出）

**修**：`_FilterTabs` 外包 `FittedBox(fit: BoxFit.scaleDown,
alignment: Alignment.centerLeft)` + `Row(mainAxisSize: min)`。

**修复前实测**（真机宽度下 pump 整页，读 `RenderFlex overflowed`）：

| 可用宽 | 对应屏宽 | 溢出 |
|---|---|---|
| 280 | 320dp | **52 px** |
| 320 | 360dp | **12 px** |
| ≥353 | ≥393dp | 无 |

固有宽合计 **332**（`20+4×14+20` ×2 + `16+4×14+16` + `gap 8×2`）。

**为什么 `_Tab` 里已有的 `maxLines/ellipsis` 没救它**：`Row` 给非 flex
子项的是**无界**主轴约束，文本按固有宽度排版，没有可省略的余地 ——
只会整行溢出。

**为什么此前 237 个用例全绿**：`flutter_test` 默认画布 **800×600**，
宽得足以容纳三个标签。窄屏条件从未进入回归面。

**修后实测**：320dp / 360dp **横向溢出归零**，三颗胶囊都在（缩小而非隐藏）。

**新增回归用例**：`test/phase5_home_test.dart` 新增
`§9-4 · 筛选行窄屏不溢出`（280 / 320 / 800 三档）——
其中 800 那档钉住「未缩放时仍贴左对齐」（偏移 = 胶囊 `padding 0 20`），
防止把「缩放」修成「整组居中」。
⚠️ 该组**已通过**，但用的是等价探针（绕开当时不编译的 `app.dart`）；
文件整体待工作区恢复后随全量用例复核。

---

### 3. 本轮新发现（**均未修改，待裁决**）

#### ① 🐞 首页 STIL 卡在 ≤360dp 纵向溢出 7px（倾向判定为**测试夹具假象**）

`home_stil_cards.dart:105` 的 `Column`：卡高 `180 − 18×2 = 144`，
320dp 下两张卡各溢出 **7px**、360dp 下一张、≥393dp 干净。

**单卡定性实验**（同样约束下逐卡渲染）：只有**含拉丁字母 `AI`** 的那张
溢出（5px），三张**纯中文**卡全部干净。

原因：`flutter_test` 的默认测试字体**每个字形都按 1em 方块**度量，
`AI` 被算成 2em（真实比例字体约 1em）、空格 1em（真实约 0.25em）。
因此**倾向判定为夹具假象，真机大概率不复现**。

⚠️ **未改** `Figma` 定高 `180` —— 改卡高属**视觉变更**，须先真机确认。
**待确认项：请在 360dp 真机上核对「问问 AI」卡的描述行是否被裁切。**

#### ② 🐞 work_agent：GBK 控制台把报告导出误报为失败（Windows 特有）

`app/core/orchestrator.py:730` 的 `print(report.summary())`，而
`MatchReport.summary()`（`app/models/match.py:92`）返回值**第 0 个字符就是 `📊`**
→ 写进 GBK 控制台抛 `UnicodeEncodeError: 'gbk' codec can't encode
character '\U0001f4ca' in position 0`（与后端日志逐字吻合）。

被第 736 行的宽 `except Exception` 捕获后**误标**为
「Report export failed, building in-memory report」—— 实际导出早已成功
（`RankingAgent._export_formats` 逐格式各自 try/except，且都写了
`encoding="utf-8"`），`report` 对象也在第 716 行就建好了，`if not report`
分支根本不成立。

**真实后果**：第 734 行 `self.store.update_session_status(session_id,
"completed")` **被跳过** —— 会话状态没有落库为 completed。

附带噪声：`_emit()`（`orchestrator.py:951`）里每个 emoji 都会让 logging
吐一段 `--- Logging error ---` traceback（非致命，但刷屏）。

**未改**（属 work_agent 侧，且本轮范围是打通链路）。

---

### 4. 修改文件（careerly）

| 文件 | 改动 |
|---|---|
| `lib/features/home/presentation/widgets/home_analysis_section.dart` | `_FilterTabs` 加 `FittedBox(scaleDown, centerLeft)` |
| `test/real_backend_integration_test.dart` | 3 处 `expect` → `await expectLater`（修用例自身的竞态） |
| `test/phase5_home_test.dart` | 新增 `§9-4 · 筛选行窄屏不溢出`（3 档宽度） |
| `docs/05_progress/CURRENT_STATUS.md` · `TODO.md` | 步骤 0 文档收口（§3.3 / §3.5 / 检查清单） |

### 5. 未解决 / 挡路

1. **工作区不编译** —— 并行重构进行中，全量 `analyze` / `test` 无法执行。
2. `real_backend_integration_test.dart:61,64` 需补 `password:`（重构方负责）。
3. STIL 卡纵向溢出待真机确认（见 §3 ①）。
4. **步骤 4 的三项产品侧裁决仍未做**：Ranking 退化（1 个岗位）、分析异步化、简历版本。

### 6. 下一步

**停止**，等 §5 第 4 条的三项裁决 + 真机验收（步骤 2）。

---

## Session 020 — 接通 work_agent 已有能力（③ 岗位 URL：抓取回填 JD 文本框 · **后端 + Flutter 双端**）

**日期**：2026-10-02
**阶段**：P4-③（「接通真实功能」工作流的第 4 项）
**结论**：✅ **双端已交付 · ⚠️ 未验收**（真实端到端未跑：无设备 + 未接真实后端）

> ⚠️ 本条与**产品侧 2026-10-02 的两条裁决**绑定：
> 落点 =「抓取回填 JD 文本框」；范围 =「后端 + Flutter 一并做完」。
> **落点不是**「让 `/analysis` 直接收 URL」——理由见 §1。

---

### 0. 开工前的报告（Session 019 §11 的停止点）

Session 019 §11 明确写着：

> **③ 岗位 URL 开工前必须先报告** —— 它是**新能力接线**（Job Agent 爬虫 → 分析入口），
> 落在「分析」的哪个交互上尚未确认，**不自行决定**。

本轮先出报告，产品侧裁决两项：

```text
① 落点 = 抓取回填 JD 文本框        （复用现有「粘贴岗位链接」表单，
                                   抓到的 title 进岗位名、description 进 JD 框，
                                   用户看得到、改得动，再走原有「开始分析」）
② 范围 = 后端 + Flutter 一并做完
```

---

### 1. 一个必须先说的**发现**：这条路径改前是坏的

`analysis_page.dart` 的 `onConfirmUrl` 原来的实现是：

```text
校验 http/https → 岗位名 = 「岗位（域名）」→ _jdController.text = 那条 URL
```

也就是说，**JD 文本框里放的是链接本身**，点「开始分析」后
`POST /api/v1/analysis` 收到的是 `rawJd: "https://www.zhipin.com/job/..."`。

用户视角完全看不出异常：岗位胶囊出现了、「开始分析」可点、
分析也真的会返回一个结果 —— 只是那个结果是拿一条网址解析出来的。

**为什么不让 `/analysis` 直接收 URL**（三条，任一都够）：

```text
① 用户看不到抓到的 JD —— 抓错了无法校正，只会拿到一个莫名其妙的结果；
② 爬取 30s+（SPA 站还要起 Playwright），叠加在本已 ~210s 的同步分析上；
③ 契约 §2.1 明文：「后端必须走 GraphState.manual_job_texts 分支构造 JobPosting，
   不得要求 URL」。
```

因此 URL 只影响「JD 文本从哪来」，**不改变分析链路**：
`engine.run_analysis` 的 `job_urls=[]` 保持不动。

---

### 2. 后端（`work_agent` · 分支 `careerly-backend`）

| 文件 | 改动 |
|---|---|
| `app/careerly/job_import.py` | **新增** —— `fetch_job_from_url()`：URL → `CrawlAgent` → `ParsedJob` |
| `app/careerly/router.py` | 新增 `POST /api/v1/analysis/jobs/parse-url` |
| `app/careerly/schemas.py` | `ParseJobUrlRequest` / `ParsedJob`（**工作区既有 WIP，本轮直接采用**，见 §6） |
| `tests/test_p4_job_url.py` | **新增** 8 条 |

**复用而非重写**：抓取能力全部来自既有的 `app/agents/adapters/*` + `CrawlAgent`，
`job_import.py` 只做两件事 —— 把 URL 交进去、把 `JobPosting` 压成回填所需的三个字段。

**唯一一处「CrawlAgent 返回空 = 失败」**：`CrawlAgent.run` 会吞掉每个适配器的异常
并 `continue`（返回空 `JobList`）。对批量爬取那是合理容错；但对
「用户贴了一条链接、在等一个结果」的场景，静默返回空就是 **D108 点名的「失败无痕」**。
故此处把「一个岗位都没抓到」与「只抓到标题没有正文」**都升格为 502**。

**不扣额度、不建任务**（`CLAUDE.md` §5.2）—— 测试里有一条专门钉这个。

---

### 3. Flutter 侧

| 文件 | 改动 |
|---|---|
| `lib/data/models/parsed_job.dart` | **新增** `ParsedJob`（url / title / company / description） |
| `lib/data/models/models.dart` | barrel 导出 |
| `lib/data/repositories/analysis_repository.dart` | 接口新增 `parseJobUrl(String)` |
| `lib/data/api/api_analysis_repository.dart` | 实现：`POST /api/v1/analysis/jobs/parse-url` |
| `lib/data/api/api_client.dart` | 新增 `jobUrlParseTimeout`（90s） |
| `lib/data/mock/mock_analysis_repository.dart` | 实现：**显式抛错**（D114） |
| `lib/features/analysis/state/analysis_provider.dart` | `jobUrlState` + `parseJobUrl()` + `clearJobUrlState()` |
| `lib/features/analysis/presentation/analysis_page.dart` | `onConfirmUrl` 改为抓取回填；URL 表单接四态 |

设计上刻意保留的两点：

```text
① 抓取状态与 analysisState **分开** —— 混进去会让「分析中」的进度页
   在用户还没开始分析时就弹出来；
② parseJobUrl() **有返回值**（与 startAnalysis 不同）—— 回填要写两个
   TextEditingController，而控制器归页面所有；调用方 await 拿到结果再落笔，
   比监听状态变化少一个「状态已变、控制器还没填」的中间态。
```

**输入框四态**（`CLAUDE.md` §5.5）：

```text
Loading   输入框禁用 + 「正在抓取岗位信息…」转圈行 + 确认钮「抓取中…」不可点
Error     输入框下方红字（CareerlyInput.errorText）+ 确认钮变「重试」
Disabled  链接为空 / 抓取中 → 确认钮不可点（沿用 Figma disabled 灰）
Empty     表单本身即空态（hint 可见），不另造空态 UI
```

**取消竞态**：抓取途中用户可能取消 / 切到历史分析，故 `await` 之后**双重确认**
（`mounted` + `_addingUrl`）才落笔 —— 迟到的结果不得偷写进已关闭的表单。

**顺手去掉的一处静默失败**：旧代码在不以 `http` 开头时**直接 `return`**（没有反馈）。
现在本地不再预判链接合法性 —— 后端能补协议头（`zhipin.com/job/x` → `https://…`），
也能给出可执行的中文提示，判断交给它一处做。

---

### 4. 测试结果（**当次真实输出**，2026-10-02）

```text
Flutter  flutter analyze                     → No issues found!
         flutter test                        → 230 passed / 1 skipped(需真实后端，既有) / 0 failed
         其中新增：
           test/phase6_job_url_test.dart              10 条
           test/data/api_analysis_repository_test.dart 5 条

后端     pytest tests/test_p4_job_url.py      → 8 passed
         pytest（全量，上一次会话实测）        → 116 passed / 1 failed
           ⚠️ 那 1 条是 tests/test_matching.py::TestSkillOverlap::test_skill_synonyms
              （`assert ('Kubernetes' in [] or False)`），落在
              app/agents/matching_agent.py 的同义词 / 嵌入路径上，
              与本轮改动的文件**无交集**，判定为**既有失败**，本轮未动。
```

**新增测试钉的是什么**（不是「返回 200」）：

```text
✅ JD 框 = 抓回来的正文          —— 直接把旧行为（JD 框 = 链接）钉死
✅ 副本 title 进岗位名，不再用域名凑
✅ 抓到的岗位走原始分析链路（rawJd = 正文 / title = 岗位名）
✅ 抓取不扣额度、不建任务
✅ 抓取中：转圈可见 / 输入框禁用 / 确认钮不可点
✅ 失败：显示后端原文 + 「重试」；**不产生**一个 JD 为空的岗位
✅ 取消后迟到结果作废
✅ 打开表单时清掉上一次的失败红字
✅ 契约层：body 是 {url}（不是 {title, rawJd}）+ 502/422 的文案原样上到 UI
```

---

### 5. 修改文件

```text
Flutter（careerly）
  M lib/data/api/api_analysis_repository.dart
  M lib/data/api/api_client.dart
  M lib/data/mock/mock_analysis_repository.dart
  M lib/data/models/models.dart
  M lib/data/repositories/analysis_repository.dart
  M lib/features/analysis/presentation/analysis_page.dart
  M lib/features/analysis/state/analysis_provider.dart
  M test/phase6_analysis_progress_test.dart   （桩补 parseJobUrl）
  M test/phase6_analysis_test.dart            （桩补 parseJobUrl）
  ?? lib/data/models/parsed_job.dart
  ?? test/data/api_analysis_repository_test.dart
  ?? test/phase6_job_url_test.dart

后端（work_agent）
  M app/careerly/router.py
  M app/careerly/schemas.py                   （采用工作区既有 WIP）
  ?? app/careerly/job_import.py
  ?? tests/test_p4_job_url.py
```

---

### 6. 工作区里的既有 WIP（**未覆盖，如实记录**）

开工时两个仓库的工作区都**不是干净的**，本轮的处理：

```text
work_agent/app/careerly/schemas.py
  ParseJobUrlRequest / ParsedJob —— 上次会话为 ③ 起的头，没有路由、没有调用方。
  本轮**直接采用**（字段设计与产品侧裁决的落点一致）：后端提交时一并带上，
  否则 job_import.py 的 import 不成立。

work_agent/docs/careerly/BACKEND_API_CONTRACT.md
  P3-5a 的回写（§0.5.x 重编 + 3 个端点移入「已落地」）—— **与本轮无关**。
  ⚠️ **未改动、未提交，原样留在工作区**（D109 的规矩）。
  抓取端点因此**没有进契约文档** → 登记为 **D115**。
```

---

### 7. 新发现 / 待裁决（本轮新增 D114–D116）

| 编号 | 分类 | 问题 |
|---|---|---|
| **D114** | 【技术实现差异】 | Mock 下「岗位链接抓取」**必然报错**（不返回假 JD）—— 用户可见的能力缺口 |
| **D115** | 【技术实现差异】 | 抓取端点**未写进** `BACKEND_API_CONTRACT.md`（该文件有未提交改动，不覆盖） |
| **D116** | 【技术实现差异】 | 抓取失败被 `_mapError` 归成 `AIError`（用户文案正确，仅类型名语义不符） |

详见 `TODO.md` §3.1。

---

### 8. 明确未做（**不是遗漏**）

```text
真实端到端联调（真机 + 真实后端 + 真实爬虫）  → 无设备；本轮只到契约层 + 桩
ParsedJob.company 的展示                      → Figma 的岗位卡没有公司位；
                                                字段留着是为了与后端契约对齐
回填后自动聚焦 JD 框 / 自动展开 JD 表单        → Figma 无此交互，不自行发明
抓取端点的限流 / 缓存                          → work_agent 既有限流策略即可，
                                                本轮不为「以后可能用到」新加机制
```

---

### 9. 下一步

```text
① 退出登录   ✅ 已提交（9d879c0）
② 简历资产   ✅ 后端（S018）+ Flutter（S019）· ⚠️ 未验收
④ 截图 OCR   ✅ 同 ② 一条链路 · ⚠️ 未验收
③ 岗位 URL   ✅ 后端 + Flutter（S020）· ⚠️ 未验收
   ↓
「接通真实功能」清单上的 4 项**全部走完**。剩余：P3 Mock → 真实 API 的收尾、
AI Chat（P3-4 已裁决本阶段不做）、以及**真实端到端联调**（四项共同的验收前提）
```

**停止点**：⛔ **不进入下一个单元**。等产品侧对 D114 / D115 裁决，
以及 ①–④ 的合并验收（含真实端到端）。

---

## Session 019 — 接通 work_agent 已有能力（② 简历资产入口 + ④ 截图 OCR · **Flutter 侧**）

**日期**：2026-10-02
**阶段**：P4-②/④ 的 **Flutter 侧**（承接 Session 018 的后端交付）
**结论**：✅ **Flutter 侧已交付 · ⚠️ 未验收**（后端在 Session 018 已交付）

> ⚠️ 本条与 Session 018 合起来才是「②/④ 完成」。
> **「已交付」≠「已验收」**：真实端到端（真机 + 真实后端）**本轮未跑**。

---

### 0. 本轮范围

Session 018 的 §2.4 列了 5 项 Flutter 侧待办（F1–F5），本轮**全部做完**：

```text
F1  ApiClient.postMultipart()            ✅ 新增
F2  submitResumeText / submitResumeFile
      → POST /api/v1/resume              ✅
F3  fetchProfile 字段映射修复             ✅（本轮最有价值的一条）
F4  ResumeFileData.allowedExtensions 对齐后端   ✅
F5  on-resume 上传卡文案含图片            ✅（产品侧当场拍板，见 D107）
```

---

### 1. F1 — `ApiClient.postMultipart()`

`_rawSend` 此前**只有 JSON 分支**（全部 `jsonEncode`），无法发 multipart。

| 改动 | 说明 |
|---|---|
| `postMultipart(path, fields:, files:)` | 新增公开方法；`_send` / `_rawSend` 增加 multipart 通道 |
| `HttpMultipartFile`（新类） | 只持有**原始字节**，不持有 `http.MultipartFile` |

**两个坑，都是踩过才写的**：

```text
① 不能手写 Content-Type —— boundary 由 http.MultipartRequest 生成。
   手写成 application/json 会让后端解析不出任何字段。
   故 multipart 分支刻意**不加** JSON 头（只带 Accept / Authorization）。
② MultipartFile.finalize() **只能调用一次** —— 而本类在 401 后会重试一次原请求。
   直接传 http.MultipartFile 会在第二次发送时抛 StateError。
   → 传原始字节，每次发送重建。已用单测钉住（见 §4）。
```

**超时**：新增 `ApiClient.resumeParseTimeout = 120s`。
该端点在后端**同一请求内同步**跑 ResumeAgent（LLM + 可能的 OCR），
30s 默认值会误报超时。这是 Flutter 侧实现取值，**不是产品规则**
（与既有 `analysisTimeout = 300s` 同型）。

---

### 2. F2 — 提交改走 `POST /api/v1/resume`

```text
改前：submitResumeText → PUT  /api/v1/resume     （只存文本，不解析 → profile 恒空）
      submitResumeFile → 直接抛「未接入」        （死路）
改后：两者 → POST /api/v1/resume（multipart）
      文本走 fields{'text'}，文件走 files[{'file'}]，图片由后端 OCR
```

后端该端点在同一请求内跑完 ResumeAgent 并把 `profile` 落库 ——
**提交即解析**。因此 `buildBaseline()` 保持 `= fetchProfile()`（GET 读回），
不再有第二次 LLM 解析。

⚠️ **两屏的时序影响**：解析发生在「提交简历」页（按钮禁用期间），
「建立职业基线」页只做读回。该页的 8.9s 时间线本就长于读回耗时，
`_maybeAdvance()` 要求两条时钟都到点，故**视觉无回归**。

---

### 3. F3 — `fetchProfile` 字段映射修复（**本轮修的真实 Bug**）

改造前按 `workExperiences` / `projectExperiences` / `awards` 去读，
但后端存的是引擎 `ResumeProfile.model_dump()`：

```text
name / email / phone / skills / experience_years /
roles / projects / education / certifications / raw_text
```

**只有 `skills` 命中**。而 `roles` / `projects` 才是真名：

| Flutter 字段 | 改前读 | 改后读（对齐后端） |
|---|---|---|
| `workExperiences` | `profile['workExperiences']` → **恒 0** | `profile['roles']`（字符串数组） |
| `projectExperiences` | `profile['projectExperiences']` → **恒 0** | `profile['projects'][].name`（对象数组取 name） |
| `skills` | `profile['skills']` ✅ | 不变 |
| `awards` | `profile['awards']` → 恒 0 | **仍为空** —— 后端 `assets.py` 明确 awards「not parsed」（**D110 未决**） |
| `capabilities` | `profile['capabilities']` → 恒空 | 仍为空 —— 画像里没有能力分值 |

**这一条同时修好了两个页面**（都用 `ResumeProfile`）：

```text
onboarding_confirm_page.dart  「确认职业信息」汇总卡四行
analysis_page.dart            「当前简历」卡的 3 个统计（N项核心能力 / N段经历 / N个项目）
```

> 修前：走完 Onboarding、还没做过分析的新用户，四行里三行恒为 0
> —— 这正是 Session 018 §2.1 记的「职业资产永远为空」。
> 修的是**读取端**；写入端（`POST /resume` 落 profile）由 Session 018 完成。

另：`_stringList` 现在会丢弃空白项（LLM 可能抽出空 role / 空 skill，
保留会让确认页的条数把空条目也算进去）。

---

### 4. F4 — 文件白名单与后端逐项对齐

```text
Flutter 改前：pdf / doc / docx
Flutter 改后：pdf / docx / txt / png / jpg / jpeg / webp / bmp
后端         ：.pdf .docx .txt .png .jpg .jpeg .webp .bmp   ← 逐项一致
```

- ➕ **加图片**：产品侧指令「截图 OCR 属于本轮」（Session 018 §0）。
- ➕ **加 txt**：后端本就支持，Flutter 漏了。
- ➖ **去掉 `.doc`**：旧二进制格式，python-docx 读不了，**后端必拒**
  —— 放行等于「可选但必然失败」。**这是一处用户可见的能力收窄**，
  已登记 **D112**。

---

### 5. F5 — 上传卡文案（**D107 已裁决**）

产品侧 2026-10-02 当场拍板，两处文案含图片：

```text
标题（对应 App.tsx L761）
  支持 PDF、Word 格式，…       → 支持 PDF、Word、图片格式，…
卡内（对应 App.tsx L768）
  PDF / Word · 最大 10MB       → PDF / Word / 图片截图 · 最大 10MB
```

「AI 将自动提取」清单**不动** —— 它本就列了「技能与证书 / 获奖与荣誉」两项。

---

### 6. 实测结果（**当次真实输出**，2026-10-02）

```bash
cd /g/ai_agent/careerly
flutter analyze  →  No issues found!          (8.0s / 复核 119.1s)
flutter test     →  All tests passed!（215 / 215 + 1 skipped）
```

**用例数 216 已独立复算**（`grep -c "testWidgets(\|test(" test/*.dart test/*/*.dart` = 216，
减 1 条 `real_backend_integration_test` 默认 skip → 215 passed）。

**新增用例**：`test/data/api_resume_repository_test.dart`（**7 例**）

```text
✅ submitResumeText 走 multipart 的 text 字段（不是 JSON body）
✅ submitResumeFile 走 multipart 的 file 字段并带原始字节
✅ Content-Type 由 http 生成（含 boundary），不被手写覆盖   ← 钉住坑 ①
✅ roles / projects[].name / skills 映射正确                ← 钉住 F3
✅ 后端 null → ResumeProfile.empty
✅ 有画像但文本为空 → 仍视为无基线
✅ allowedExtensions 与后端逐项一致，且不含 .doc
```

> ⚠️ **真实端到端未跑**（无 Android 设备 + 未启动后端）。
> 本轮证明的是**契约层**：端点、传输形态、字段映射、错误归一化
> —— 全部在 Fake backend 上钉死，**未证明**在真实后端上跑得通。

---

### 7. 修改文件（Flutter 侧）

```text
 M lib/data/api/api_client.dart              postMultipart + HttpMultipartFile + resumeParseTimeout
 M lib/data/api/api_resume_repository.dart   提交改走 POST；fetchProfile 映射修复
 M lib/data/models/resume_file.dart          白名单对齐后端 + 注释更新
 M lib/core/services/resume_file_picker.dart 注释更新（白名单范围）
 M lib/features/onboarding/presentation/onboarding_resume_page.dart   文案（D107）
 M test/phase4_batch2_test.dart              断言跟随文案改
 M test/real_backend_integration_test.dart   两处过期断言修正（见 §8）
 + test/data/api_resume_repository_test.dart 7 例（新建）
```

---

### 8. 顺带修正的一处**过期断言**（不是本轮功能）

`real_backend_integration_test.dart` §7 原断言：

```text
submitResumeFile(匿名) → 期望「不可重试」的 AppError
reason: '文件上传未实现应给出不可重试的明确提示'
```

F2 之后「未实现」不再是事实。已改为两条与新现实一致的断言：

```text
① 匿名提交简历 → AuthError（简历资产提交同样要鉴权）
② 已登录提交 .doc → ParseError（后端回 UNSUPPORTED_FORMAT 422）
```

> ⚠️ 该文件**默认 skip**，不影响 `flutter test` 全量；但它是一份会被人
> 照着跑的联调清单，**留着过期断言比没有更糟**。

---

### 9. 待裁决（本轮新增）

| 编号 | 分类 | 问题 |
|---|---|---|
| **D112** | 【技术实现差异】 | Flutter 白名单**去掉 `.doc`**（用户可见的能力收窄）。理由：后端必拒。待确认是否接受 |
| **D113** | 【视觉/交互差异】 | `onboarding_confirm_page` 的 Empty 文案写着「**Mock 数据源**默认返回空档案…」，真实 API 下该措辞不再成立 |

**本轮已当场裁决、无需再议**（记录备查）：

```text
✅ D107 上传卡文案含图片 —— 采用 AI 侧草稿（产品侧 2026-10-02 选「用草稿改掉」）
```

**仍未决**：D110（获奖经历数据源）—— 本轮**未自行 invent**，`awards` 保持空。

---

### 10. 明确未做（**不是遗漏**）

```text
真实端到端联调（真机 + 真实后端）   → 无设备；本轮只到契约层
③ 岗位 URL 接线                     → 未开工（见下）
D110 获奖经历映射                   → 无数据源，不自行 invent
能力画像 capabilities 的填充        → 画像里没有分值来源
```

---

### 11. 下一步

```text
① ✅ 已提交（9d879c0）· ②④ ✅ Flutter 侧本轮交付 · ③ ⛔ 未开工
```

**③ 岗位 URL 开工前必须先报告** —— 它是**新能力接线**（Job Agent 爬虫 → 分析入口），
落在「分析」的哪个交互上尚未确认，**不自行决定**（Session 018 §8 的停止点仍然有效）。

同时：后端 `work_agent` 那 6 个文件（Session 018 §6）**仍未提交**。

---

## Session 018 — 接通 work_agent 已有能力（① 退出登录 · ② 统一简历资产入口 + ④ 截图 OCR）

**日期**：2026-10-02
**阶段**：P4-①/②（**不是**新 Phase —— 见「本轮任务的定性」）
**结论**：⏸ **进行中 · 暂停**（后端①②④ 已交付并自测通过；**Flutter 侧未开工**）

> ⚠️ 本条是**中途记录**，不是一个交付收口。恢复时**不要**把它当作
> 「②已验收」——它只到「后端改完 + 后端测试绿」。

---

### 0. 本轮任务的定性（用户原话，2026-10-02）

```text
「请逐步将 G:\ai_agent\work_agent 里的已经存在的能力全部接出来。
  你现在截图中的简历上传、截图 OCR、岗位输入、退出登录，
  都属于这条『接通真实功能』的工作，而不是重新搭建 Agent。」
```

**因此本轮的边界是「接线」，不是「造能力」。** work_agent 里已经跑得通的
`ResumeAgent` / DecisionGraph / 爬虫 / 额度 / 认证一律**复用**，
Careerly 只负责把它们接到 App 的界面上。

用户指定的顺序：

```text
① Logout 改动 → commit，建立干净 Git 安全点
② 简历上传 → 建立统一「简历输入 → 解析 → ResumeProfile → 职业资产」链路
④ 截图 OCR → 接入同一套简历解析链路，不再单独造一套 Profile
③ 岗位 URL → 把已有 Job Agent 爬虫能力接到 Careerly 的分析入口
然后 → P3 Mock → 真实 API → AI Chat → 完整功能闭环
```

附加的硬约束（用户原话）：

> 「不允许文件上传、文本粘贴、OCR 各自维护一套 Profile 写入逻辑。」
> 「请不要为了兼容当前 POST /analysis 而把文件上传逻辑硬塞进 /analysis。」

---

### 1. ① 退出登录 —— ✅ 已交付 · 已提交

**提交**：`9d879c0 feat(auth): 退出登录接通真实功能`（8 文件，+399 / −1）

#### 背景

`settings_page.dart` 的「退出登录」是 `onPressed: () {}` —— **死按钮**。

#### 关键事实：后端**没有 logout 端点**

`app/core/security.py` 明确记录了这个缺口：令牌是无状态 JWT，
服务端**没有吊销表**。因此「退出」只能表达为**客户端丢弃凭据**
（内存令牌 + 安全存储），而不是「让服务端的某个令牌失效」。

这一点写进了 `AuthRepository.logout()` 的文档注释，避免下一个会话
误以为「漏调了一个端点」。

#### 改动

| 层 | 文件 | 改动 |
|---|---|---|
| 契约 | `lib/data/repositories/auth_repository.dart` | `+ Future<void> logout()` |
| Mock | `lib/data/mock/mock_auth_repository.dart` | `+ logout()`（只模拟延迟） |
| API | `lib/data/api/api_auth_repository.dart` | `+ logout() => _client.clearSession()` |
| 状态 | `lib/features/onboarding/state/auth_provider.dart` | **新建**（见下） |
| 装配 | `lib/app/providers.dart` | 注册 `AuthProvider` |
| UI | `lib/features/profile/presentation/settings_page.dart` | 按钮接线 + 确认弹层 + 失败 Toast + 禁用态 |
| 测试 | `test/auth_logout_test.dart` | **新建**，7 例 |

#### 为什么现在才建 `AuthProvider`（`CLAUDE.md` §6.3）

`providers.dart` 里原有一句注释：

> 「等到真的需要『当前用户是谁』时再建 AuthProvider，届时它才是死代码的反面。」

在退出登录出现之前，Flutter 侧**没有任何**结束会话的入口 —— 建了就是空 Provider，
而 §6.3 明令禁止预建占位 Provider。退出登录是第一个真实用例。

⚠️ 它**只**承载「这次退出操作的状态」，**不持有登录态** ——
令牌的持有者是 `ApiClient`，不制造第二个会话真相源。

#### ⚠️ Flutter 侧补齐、**未经产品侧确认**的交互

Figma **只有按钮，没有退出确认层**。补它的理由与既有 `CareerlyBackGuard`
同型：退出会丢弃本机身份（需重新登录），属不可逆操作。
文案与交互 → 登记 **D106**。

---

### 2. ② 统一简历资产入口 —— 后端 ✅ 已交付 / Flutter ⛔ 未开工

#### 2.1 盘点结果：简历**有三条互不相通的写入路径**

这是本轮最重要的发现。改造前：

```text
POST /api/v1/resume/upload   (app/api/router_app.py:153)
      → 写 data/resumes/{resume_id}.json        ❌ 不进 careerly_resumes，不建立基线
PUT  /api/v1/resume          (app/careerly/router.py:200)
      → 只写 careerly_resumes.text              ❌ 明令不碰 profile
POST /api/v1/analysis        (app/careerly/router.py:124)
      → 写 careerly_resumes.profile             ⚠️ 必须跑一次完整分析
```

**后果**：一个走完 Onboarding、还没做过分析的**新用户**，
`careerly_resumes.profile` 恒为 `{}` →「我的 → 职业资产」永远是空的。

而这恰恰与 `CLAUDE.md` §5.1 冲突：

> 首次 Onboarding 的目的不是完成一次分析，而是**建立用户的职业基线**。

「建立基线」和「必须跑一次分析才有资产」这两件事**不能同时成立**。

#### 2.2 用户裁决（2026-10-02）

| 问题 | 裁决 |
|---|---|
| 新入口解析出的 profile 要不要直接落库？ | ✅ **上传即落 profile** |
| 图片 OCR 依赖怎么办？ | ✅ **现在装依赖，图片一次做完** |

第 1 条意味着**改写** `careerly/router.py` 原有的
「`POST /analysis` 是唯一解析方」注记（profile 写入者 1 → 2）——
已在源码里注明修订日期与理由。

#### 2.3 落地方案（后端 —— 已完成）

新增 **`POST /api/v1/resume`** = 简历资产**唯一推荐入口**，
三种输入方式在此汇合：

```text
Resume Input (text | pdf/docx/txt | image)
   → ResumeAgent            ← 复用既有解析器，一行没重写
   → ResumeProfile
   → careerly_resumes (text + profile)   ← 唯一的职业资产存储
```

| 文件 | 改动 |
|---|---|
| `app/agents/resume_agent.py` | ① 加图片分支 `_extract_image`；② OCR 配置统一到 `_configure_tesseract` / `_apply_tessdata` / `_ocr_language`；③ 新增 `ResumeExtractionError`；④ 新增 `self.raw_text`（完整文本，profile.raw_text 是截断版） |
| `app/careerly/router.py` | 新增 `POST /resume`（multipart: `file` 或 `text`）；修订 `PUT /resume` 的 single-writer 注记；模块头端点表 |
| `requirements.txt` | `+ pytesseract` `+ pdf2image` `+ Pillow` `+ python-multipart` |
| `.gitignore` | 忽略 `app/data/tessdata/*.traineddata` |
| `app/data/tessdata/README.md` | **新建** —— 语言包怎么装 / 为什么 / 降级行为 |
| `tests/test_p4_resume_asset.py` | **新建**，13 例 |

**端点分工（落进源码注释）**：

```text
POST /api/v1/resume   提交一份简历资产（文件 / 图片 / 文本） → 立即解析 → 写 text + profile
PUT  /api/v1/resume   仅更新基线文本（P3 preview，无解析）   → 只写 text
```

两者**都不扣分析额度**（`CLAUDE.md` §5.2）、**都不建分析任务**（它不是分析）。

**降级纪律**（沿用 `POST /analysis` 的既有做法）：解析偶尔会降级成
「只有 raw_text 的空壳」，此时**保留旧 profile**、只更新文本 ——
否则用户上传一次解析失败的简历，「职业资产」会突然清零。

#### 2.4 ⛔ Flutter 侧：**完全未开工**

已确认要改但**一行都没改**：

| # | 文件 | 要改什么 |
|---|---|---|
| F1 | `lib/data/api/api_client.dart` | 新增 `postMultipart()`。**实测现在只有 JSON**（`_rawSend` 全部 `jsonEncode`） |
| F2 | `lib/data/api/api_resume_repository.dart` | `submitResumeFile` / `submitResumeText` 改走 `POST /api/v1/resume` |
| F3 | `lib/data/api/api_resume_repository.dart` | 修 `fetchProfile` 的字段映射（见「新发现 ②」） |
| F4 | `lib/data/models/resume_file.dart` | `allowedExtensions` 扩展（图片 + txt，去掉 `.doc`） |
| F5 | `lib/features/onboarding/presentation/onboarding_resume_page.dart` | 上传卡文案「PDF / Word · 最大 10MB」需含图片（见 **D107**） |

⚠️ F1 有一个已知坑：**multipart 不能手动设 `Content-Type`**
（boundary 由 http 包生成），否则后端解析失败。

---

### 3. ④ 截图 OCR —— 后端 ✅ 已交付（与 ② 同一次改动）/ Flutter ⛔ 未开工

「截图 OCR」在实现上**不是新功能**，而是 ② 的**第三种输入方式**：
图片 → OCR → 文本 → **同一个** `ResumeAgent` → **同一个** `save_resume`。
不存在第二套 Profile 逻辑 —— 这正是用户要求的。

#### 环境（已在本机装好，实测通过）

| 项 | 状态 |
|---|---|
| `pytesseract` / `pdf2image` / `Pillow` | ✅ 已装进 `work_agent/venv` |
| Tesseract 二进制 | ✅ **本机原本就装了** `5.4.0.20240606`（`C:\Program Files\Tesseract-OCR\`），只是不在 `PATH` |
| `chi_sim` 语言包 | ⚠️ **官方安装包没有** → 已下载 `tessdata_fast` 版到 `app/data/tessdata/`（~2.5MB，**不进 git**） |

**踩到的两个坑**（写进 `resume_agent.py` 注释，避免复踩）：

```text
1. `--tessdata-dir "<path>"` 不可用 —— pytesseract 按空白切分 config，
   引号不会被剥掉 → 报 `Error opening data file "...tessdata"/chi_sim.traineddata`
   ✅ 改用 TESSDATA_PREFIX 环境变量
2. TESSDATA_PREFIX 必须指向 **tessdata 目录本身**，不是它的父目录
   （指父目录会去找 <prefix>/chi_sim.traineddata 而失败）
3. `chi_sim` 模型本身能识别拉丁字符 → 不要拼 `chi_sim+eng`
   （拼了反而要求两个语言包在同一个 tessdata 目录下）
```

#### 降级行为

- 没有 `chi_sim.traineddata` → 回落 `eng`（中文丢，英文技术词仍在），**不整体失败**
- 没有 tesseract 二进制 / Pillow → 抛 `OCR_UNAVAILABLE`，**明确报错**
- 图里一个字都读不出 → 抛 `EMPTY_EXTRACTION`，**不再静默返回空基线**

最后一条是一处**有意的行为变更**：旧 `_ocr_extract` 在依赖缺失时返回 `""`，
用户会拿到一份空基线却看不到任何错误（典型的「失败无痕」）。
现改为显式错误 —— 该改动**同样影响** `POST /api/v1/resume/upload`
（扫描件 PDF 无 OCR 时 200+空 → 500 PARSE_ERROR）。登记 **D108**。

---

### 4. 新发现（本轮才暴露，与既有文档不符）

| # | 发现 | 影响 |
|---|---|---|
| ① | 简历有**三条互不相通的写入路径**（§2.1） | 这就是「职业资产永远为空」的根因 |
| ② | **`ApiResumeRepository.fetchProfile` 读错了字段键** | 见下，**既有 Bug，非本轮引入** |
| ③ | `.doc` / `.txt` 白名单**两边不一致** | Flutter 放行 `.doc`，后端必拒 |
| ④ | `BACKEND_API_CONTRACT.md` §0.5.2 记「文件上传 Flutter 明确不接」 | 与用户本轮指令冲突 → **D109** |
| ⑤ | OCR 依赖此前**一项都没装**，`requirements.txt` 也未列 | 已修 |
| ⑥ | `test_skill_synonyms` **预存在失败** | 非本轮引入（已用 `git stash` 验证，见 §5） |

#### 关于新发现 ②（**这条最值得下一个会话先看**）

```dart
// lib/data/api/api_resume_repository.dart:76-85 （改造前）
workExperiences:   _stringList(profile['workExperiences']),
projectExperiences:_stringList(profile['projectExperiences']),
skills:            _stringList(profile['skills']),
awards:            _stringList(profile['awards']),
capabilities: ...  profile['capabilities'],
```

但后端存进 `careerly_resumes.profile` 的是 `ResumeProfile.model_dump()`：

```text
name / email / phone / skills / experience_years /
roles / projects / education / certifications / raw_text
```

**只有 `skills` 对得上。** 而 `onboarding_confirm_page.dart` 的汇总卡
**正是**由这四个字段驱动的：

```text
工作经历   ← workExperiences.length   → 恒为 0
项目经历   ← projectExperiences.length → 恒为 0
能力与技能 ← skills.length             → 唯一对的一个
获奖经历   ← awards.length             → 恒为 0
```

**即：即便 profile 已经落库，Onboarding 的「确认职业信息」屏
四行里仍有三行恒为 0。** 这是「接通真实功能」的直接缺口。
修法 → F3，其中「获奖经历」的映射**没有**明显正确的来源
（后端 `assets.py` 明确写着 awards「not parsed」）→ 登记 **D110**。

---

### 5. 测试结果（**真实输出**）

#### 后端 · 新增用例

```bash
cd /g/ai_agent/work_agent
./venv/Scripts/python.exe -m pytest tests/test_p4_resume_asset.py -q
```

```text
.............                                                            [100%]
13 passed, 1 warning in 36.09s
```

覆盖：文本路径建基线 / 文本 trim / TXT 文件进同一张表 / **图片 OCR 进同一链路** /
不扣额度 / 不建分析任务 / 降级不覆盖画像 / 无载荷 422 / 空白文本 422 /
`.doc` → `UNSUPPORTED_FORMAT` / 空文件 422 / 超 10MB → 413 / 用户隔离。

#### 后端 · 全量

```bash
./venv/Scripts/python.exe -m pytest tests/ -q
```

```text
1 failed, 108 passed, 487 warnings in 204.98s (0:03:24)

FAILED tests/test_matching.py::TestSkillOverlap::test_skill_synonyms
```

⚠️ **该失败与本轮改动无关，已验证是预存在的** —— 把我改的四个文件
`git stash` 掉之后单跑该用例，**同样失败**：

```text
FAILED tests/test_matching.py::TestSkillOverlap::test_skill_synonyms - Assert...
1 failed in 5.13s
```

（断言是技能同义词表把 `K8s` 归一到 `Kubernetes`，`result["matched"]` 为空。
不经过本轮改动的任何代码路径。）

#### 后端 · OCR 实拍

```text
输入：脚本生成的 PNG，三行中文（李四 高级产品经理 8年经验 / 技能：Python、SQL… / 项目：…）
OCR 输出：
    李四 高级产品经理 8年经
    技能: Python、SQL、用户增长、数据分析
    项目: 推荐系统改版，DAU 提升 30%
（末字被合成图宽裁掉，非识别问题）

空白图 → ResumeExtractionError(EMPTY_EXTRACTION)   ✅ 未静默返回空 profile
```

#### Flutter 侧

```text
未运行 —— 本轮未改任何 Flutter 代码。
```

#### ① 退出登录（上一提交，记录在此备查）

```bash
cd /g/ai_agent/careerly
flutter analyze   →  No issues found!
flutter test test/auth_logout_test.dart   →  7 passed
```

---

### 6. 修改文件

#### 💻 代码 —— `work_agent`（后端，**未提交**）

```text
 M app/agents/resume_agent.py         图片 OCR 分支 + ResumeExtractionError + raw_text
 M app/careerly/router.py             新增 POST /resume；修订 PUT /resume 注记
 M requirements.txt                   + pytesseract / pdf2image / Pillow / python-multipart
 M .gitignore                         忽略 app/data/tessdata/*.traineddata
?? app/data/tessdata/README.md         语言包说明（**新建**）
?? app/data/tessdata/chi_sim.traineddata   （二进制，已 gitignore）
?? tests/test_p4_resume_asset.py       13 例（**新建**）
```

⚠️ 工作区里还有一笔**不属于本轮**的未提交改动：
` M docs/careerly/BACKEND_API_CONTRACT.md` —— **不要覆盖它**。

#### 💻 代码 —— `careerly`（Flutter）

```text
9d879c0  feat(auth): 退出登录接通真实功能   （8 文件，+399 / −1，已提交）
本轮 Flutter 侧：未改任何文件
```

#### 📄 文档

```text
本文件（Session 018）
TODO.md（D106–D111 + 本轮工作流登记）
```

---

### 7. 未解决问题 —— 待裁决（本轮新增，编号 D106 起）

> 分类口径：`【产品冲突】【IA 冲突】【视觉/交互差异】【技术实现差异】`

| 编号 | 分类 | 问题 |
|---|---|---|
| **D106** | 【视觉/交互差异】 | 退出登录**确认弹层**是 Flutter 侧补的（Figma 只有按钮）。文案 / 是否保留 → 待确认 |
| **D107** | 【视觉/交互差异】 | 加图片 OCR 后，`on-resume` 上传卡文案「**PDF / Word** · 最大 10MB」必须改。**改法未定** → 待产品侧给文案 |
| **D108** | 【技术实现差异】 | 「OCR 依赖缺失」从**静默返回空**改为**显式报错**，该改动同样影响既有 `POST /api/v1/resume/upload` |
| **D109** | 【产品冲突】 | `BACKEND_API_CONTRACT.md` §0.5.2 记「文件上传 Flutter **明确不接**，排 P3」，与本轮指令直接冲突 |
| **D110** | 【产品冲突】 | 「获奖经历」用什么数据源？后端 `assets.py` 明确 awards「not parsed」，而 Figma 的提取清单列了「获奖与荣誉」。**不自行 invent** |
| **D111** | 【技术实现差异】 | `/resume/upload`（写 JSON 文件）与 `POST /resume`（写 careerly 库）**双轨**如何处理 —— 建议前者保留不动、Careerly 只走后者 |

**已在用户侧当场裁决、无需再议的两条**（记录备查）：

```text
✅ profile 写入者 1 → 2（上传即解析落库）
✅ OCR 依赖现在就装（图片一次做完）
```

---

### 8. 下一步（恢复时的**精确起点**）

```text
① ✅ 已提交（9d879c0）
② 🔶 后端完成 → **接着做 Flutter 侧 F1–F5**（见 §2.4）
④ 🔶 后端完成（与 ② 同一次改动）→ 随 ② 的 Flutter 侧一起收口
③ ⛔ 未开始（岗位 URL → Job Agent 爬虫 → 分析入口）
```

#### 恢复时的第一步

```text
1. 后端：把 §6 的 6 个文件提交（工作区当前**未提交**）
2. Flutter：先做 F1（ApiClient.postMultipart），因为 F2/F3 都依赖它
3. 然后 F3（修 fetchProfile 映射）—— 这条**独立可验证**，
   做完就能让 Onboarding 确认页的四行汇总卡真的动起来
4. 再 F2/F4/F5
```

#### ⚠️ 停止点

- ③ 岗位 URL **未开工**，且它是**新能力接线**（爬虫 → 分析入口），
  开工前需要先确认它落在「分析」的哪个交互上 → **先报告，不自行决定**。
- **不要**因为「② 后端都绿了」就认为 ② 已完成 —— **Flutter 一行没动**。

---

## Session 017 — Phase 8A：成长足迹「日历与事件解耦」（日历默认存在）

**日期**：2026-09-28
**阶段**：Phase 8A（我的 → 成长足迹）
**结论**：✅ 完成（⚠️ 未验收）

### 背景 —— 产品侧规则澄清（2026-09-28）

批 3 交付时，成长足迹页被实现成了**数据消费页**：整页包在
`CareerlyAsyncStateView` 的 `isEmpty` 门禁里 —— Mock 默认返回空，
于是**日历整块消失**，只剩一句「还没有成长记录」。

产品侧本轮明确这是错的：

```text
✅ 日历是默认存在的核心页面结构 —— 永远渲染
✅ 即使没有任何事件，也必须显示完整日历 + 对应的当天空状态
❌ 不得根据 Event 是否存在来决定是否渲染 Calendar
```

**事件不由本页产生**：它由各业务操作逐步写入
（更新简历 / 完成岗位分析 / 新增项目经历 → `GrowthEvent`），
本页是**容器**，不是数据来源。因此空数据下也必须是完整、正确的页面。

### 本次完成内容

| # | 改动 | 说明 |
|---|---|---|
| 1 | **拆掉顶层 Empty 门禁** | 日历（周条 + 月网格）无条件渲染，数据一律走 `events.data ?? const []` |
| 2 | **全部日期可点选** | 旧实现 `onTap: dayEvents.isEmpty ? null : …` —— 空日期不可点，与「日期选择」直接冲突 |
| 3 | **当天事件区恒渲染 + 当天空状态** | 新增 `_DayEmptyNote`；空事件给文案而不是隐藏整块 |
| 4 | **默认选中今天（今天定位）** | 旧实现预选「最近一个有事件的日期」，无事件时 `_selectedDate == null` |
| 5 | **「今天」快捷定位** | 视图离开今天时，月份标题行出现「今天」胶囊（复用 `CareerlyChip`） |
| 6 | **切月时选中日跟随** | 切月后选中该月同日（越界夹到月末）；切到当前月则回今天 |
| 7 | **时间线加区块标题「全部记录」** | 与「当天事件区」区分（产品侧裁决：两者都保留） |

页面结构（改后）：

```text
周日历条（真实日期，今天 = 渐变圆）
月网格 ← 月份切换 / 今天定位 / 日期选择 / 有事件日期标记
当天事件区 ← 按 selectedDate 过滤；为空给空状态，不隐藏
全部记录 ← 时间线（独立数据流，Figma 两份源数据）
```

### 重要决策

#### ① 产品侧规则（已裁决）→ TODO §3.2 · **D99**

日历 = 容器（默认存在），事件 = 动态数据。**不得**用 Event 存在与否
决定 Calendar 是否渲染。已写入 `growth_record_page.dart` 类文档 + 测试不变量。

#### ② 非今天日期的空态文案 → TODO §3.1 · **D100**（待确认）

- 今天：`今天还没有足迹` + `完成一次职业分析，这里会留下你的成长记录。`
  —— **逐字来自产品侧**；
- 非今天：`这一天还没有足迹` + 同一句说明 —— **Flutter 侧按同句式起草**，
  与 D90 同类（原型没有空态，必须有人起草文案）。

#### ③ 切月选中跟随 + 「今天」胶囊 → TODO §3.1 · **D101**（已拍板，备案）

Figma 是静态原型，没有月份导航、也没有「回到今天」。属
`CLAUDE.md` §3.2「Figma 天生无法表达，在 Flutter 里实现」一类
（与 D97 同源）。**未新增任何一级导航 / 一级页面。**

#### ④ 时间线保留 → 两者都保留（产品侧选择）

月网格 → 当天事件区 → 「全部记录」时间线。时间线保持**独立数据流**
（`GrowthTimelineProvider`），不受当天事件区 Loading / Error 牵连。

### 修改文件

```text
💻 lib/features/profile/presentation/growth_record_page.dart
     · 顶层 Empty 门禁拆除（日历无条件渲染）
     · _SelectedDayEvents（当天事件区，含四态）+ _DayEmptyNote（当天空状态）新增
     · _MonthDayCell.onTap 改为必填（空日期可点选）
     · _GrowthRecordPageState：_today / _dayInMonth / _isViewingToday / _goToday
     · _GrowthMonthGridCard：新增 eventsState / today / showTodayAction / onGoToday / onRetryEvents
     · 时间线区块标题「全部记录」（CareerlySectionHeader）

💻 test/phase8d_growth_record_test.dart（重写断言，用例数不变 8）
     · 新增「空数据：日历照常渲染，当天给出空状态」= Phase 8A 核心不变量
     · 新增「点选无事件的日期也可选中，并给出当天空状态」
     · 「默认定位今天」取代「预选中最新事件日」
     · 「月份切换 + 选中日跟随 + 今天定位」

💻 test/phase8_profile_test.dart（入口卡用例的连带更新）
     · 「还没有成长记录」→「今天还没有足迹」（旧全页文案已移除）

📄 本文件 · TODO.md（D99–D101）· CURRENT_STATUS.md（Phase 8A）
📄 docs/phase8a_footprint_report.md（交付报告）
```

### 测试结果（当次实测）

```bash
cd /g/ai_agent/careerly
flutter analyze  →  No issues found!                  (2026-09-28)
flutter test     →  All tests passed!（178 / 178）    (2026-09-28)
flutter test test/phase8d_growth_record_test.dart  →  8 / 8
```

### 🔴 新发现 —— 三个**与本批无关但必须记录**的事实

#### ① 仓库在本轮开工时**编译不过**（09-24 遗留的半成品）

`FILE_PICKER` v13 迁移没做完，`lib/` 里躺着 3 处编译错误：

```text
lib/data/mock/mock_resume_repository.dart
   引用了 ResumeFileData 但**没 import** '../models/resume_file.dart'
lib/core/services/resume_file_picker.dart
   按 file_picker 旧 API 写的：FilePicker.platform.pickFiles / FilePickerResult
   / file.bytes / file.size —— 而 pubspec 锁的是 ^13.1.0
   （v13：FilePicker.pickFile() 静态方法 + PlatformFile.readAsBytes()，无 withData）
test/phase6_analysis_test.dart · test/phase6_analysis_progress_test.dart
   StubResumeRepository 缺 submitResumeFile 实现（接口新增了成员）
```

**后果**：任何 pump 整个 App 的测试都编译不过 → **验证完全被挡住**。
**处置（产品侧已确认，2026-09-28）**：最小改动修复，**不重构** ——
补 import、适配 v13 两处调用、两个桩补实现；`onboarding_resume_page.dart`
的 2 处未使用 import 与 `resume_file.dart` 的 1 处冗余 import 一并清理
（只为让 `flutter analyze` 归零）。
⚠️ **「选择文件」在页面上的实际接线（D67）仍未做** —— 本轮只修到**可编译**，
没有替那条工作线把功能做完。

#### ② 🟠 `flutter test` 曾报 `Unable to connect to flutter_tester process`

```text
Unable to connect to flutter_tester process:
WebSocketException: Invalid WebSocket upgrade request
```

**根因**：环境里设了 `http_proxy` / `https_proxy`（`127.0.0.1:59332`），
测试运行器与 `flutter_tester` 之间的**本地 WebSocket** 被代理拦截。

**解法（后续会话照抄）**：

```bash
env -u http_proxy -u https_proxy -u HTTP_PROXY -u HTTPS_PROXY \
    NO_PROXY=localhost,127.0.0.1 no_proxy=localhost,127.0.0.1 \
    flutter test
```

⚠️ 这也解释了 09-23 那轮「`flutter test` 无输出」的假象 —— **不是测试全过**。

#### ③ D96 的**文档与代码不一致**（未处理，待裁决）

| 处 | 排名变化第 5 套配色 |
|---|---|
| `TODO.md` §3.1 · D96 正文 | 青色系 `#06B6D4 / #0891B2 / #CFFAFE / #0E7490` |
| 代码 `app_colors.dart` | **粉色系** `growthRankDot = #E878A6` · `growthGridRankDot = #FF6B9D` |
| `growth_record_page.dart` 注释 | 写「第 5 套**粉色系**」 |

两者**互相矛盾**。本轮**未改动**（属视觉裁决，且 D96 本身就是暂定值）——
但**验收前必须收敛到一套**，否则「改 Token 即全系统变化」这句话在 D96 上不成立。

### 未解决问题

```text
D100  非今天日期的空态文案（Flutter 起草，待产品侧确认）
D101  切月选中跟随 / 「今天」胶囊（Flutter 侧补充交互，已备案）
D96   ★ 文档与代码配色不一致（青色 vs 粉色），须在验收前收敛
D67   「选择文件」仍未接线（本轮只修到可编译，功能未补）
K1    字体文件仍缺失（所有视觉验收的排版盖章仍不能给）
```

> ⚠️ **本轮仍未做真机走查**（K3 已解除，但本轮未跑 APK）——
> 日历的**手势与滚动观感**、空状态在真机上的排版，`flutter test` 都验不到。

### 下一步

```text
1. 真机 / 模拟器走查：入口卡 → 日历 → 点选日期 → 空状态 → 切月 → 今天定位
2. 产品侧确认 D100 文案 + 收敛 D96 配色
3. 事件写入路径（各业务操作 → GrowthEvent）属**后续阶段**，本页只做容器
```

**停止点**：Phase 8A 交付完成，等待验收。**不自动进入下一步。**

---

## Session 016 — Phase 8 批 3：成长足迹二级页（周日历条 + 月网格 + 成长时间线）

**日期**：2026-09-23
**阶段**：Phase 8（我的）**批 3** —— 成长足迹 Detail 内部（D91 裁决后解锁）
**结论**：✅ **已交付** —— ⏹ **停在这里，等待验收**
**授权**：**D83**（Phase 8 我的 + 本轮收口；本批在其范围内）+
**D91 裁决**（2026-09-23 产品侧：4 色映射沿用 + 排名变化新增第 5 套配色；
日历范围 = 周条 + 月网格都进详情页）
**不可越过**：Phase 9（Global States）/ Phase 10（Android QA）**未获授权**，不得自动进入

---

### 一、本次完成内容

**成长足迹二级页重建**（`growth_record_page.dart`，Figma `App.tsx` L3973-4114 规格）

```text
顶栏       返回 + 「成长记录」+ 副标题「每一次变化，都是成长的痕迹。」
周日历条   动态真实日期（周一~周日），今天 = 蓝紫渐变圆，其余白圆
月网格日历 标题 + ‹ › 月份切换（D97）+ 5 类图例 + 事件圆点
           + 点选日期查看当日事件列表
成长时间线 右对齐日期 → 彩色圆点 + 渐变连接线 → 类型色卡
           （42px 圆形类型徽章 + 标题 + 日期 + 描述）
```

**D91 裁决落地**（5 类模型事件 → Figma 配色映射）：

```text
新增经历 experience   → 项目 project     蓝紫系（Figma 原值）
技能变化 skill        → 简历 resume      紫色系（Figma 原值）
能力变化 capability   → 能力 capability  橙色系（Figma 原值）
匹配度变化 matchScore  → 分析 analysis    绿色系（Figma 原值）
排名变化 rank         → 新增第 5 套青色系（暂定值，待确认 → D96）
```

**Token**：`AppColors` 新增 growth 时间线 4 套 Figma 原值 + 月网格事件圆点 4 色
+ rank 第 5 套暂定色；`AppShadows` / `AppTypography` 补对应角色。
页面与测试全部按 Token 取值，D96 改色不动结构。

**数据链路**：`GrowthProvider` 拆 `events` / `timeline` 两条数据流；
`MockGrowthRepository` 接 `DemoFixture`（`CAREERLY_DEMO_DATA` 门控，
样例数据逐字来自原型 L2996-3000 / L3940-3971），默认路径仍为空态。

**测试**：新增 `test/phase8d_growth_record_test.dart`（8 用例）。

---

### 二、本次拍板的执行决策（**已登记 `TODO.md`**）

| # | 决策 | 分类 |
|---|---|---|
| D91 | 成长事件类型映射：4 色沿用 + rank 新增第 5 套（产品侧裁决，留档 §3.2） | 【产品冲突】 |
| D96 | rank 第 5 套配色暂定青色系（`#06B6D4/#0891B2/#CFFAFE/#0E7490`），待产品确认 | 【产品冲突】 |
| D97 | 月网格补 `‹ ›` 月份切换箭头（Figma 写死单月，实现层补充交互） | 【视觉/交互差异】 |

---

### 三、修改文件

```text
lib/design_system/tokens/app_colors.dart       growth 时间线/月网格/rank 配色 Token
lib/design_system/tokens/app_shadows.dart      growth 徽章/卡片阴影
lib/design_system/tokens/app_typography.dart   growth 文字角色
lib/data/mock/demo_fixture.dart                月网格事件 + 时间线两份 Figma 样例
lib/data/mock/mock_growth_repository.dart      接 DemoFixture（演示门控）
lib/features/profile/state/growth_provider.dart  events/timeline 双数据流
lib/app/providers.dart                         Provider 注册更新
lib/features/profile/presentation/growth_record_page.dart  页面重建
test/phase8d_growth_record_test.dart           新增 8 用例
test/phase8_profile_test.dart                  入口卡跳转等待窗口放宽（见下）
docs/05_progress/TODO.md                       D91 裁决留档 §3.2 + D96/D97 登记 §3.1
docs/05_progress/CHANGELOG.md                  本 Session
docs/05_progress/CURRENT_STATUS.md             Phase 8 批 3
```

---

### 四、测试结果

```text
flutter analyze   No issues found!
flutter test      全量通过（含新增 phase8d 8/8）
```

**🐞 问题与修复**：

1. **phase8d 两个 Finder 命中过多** —— IndexedStack 保活的「我的」主页在背后
   贡献了同名渐变圆 / `chevron_right` 图标。修复：渐变圆精确匹配
   `growthTodayCircleGradient`；箭头 Finder 限定在月网格卡内。
2. **`phase8_profile_test.dart` 入口卡跳转残留 pending Timer** ——
   该用例 `pumpAndSettle(350ms)` 的时间窗盖不住 Mock 延迟（600ms），
   旧骨架页单次请求恰好侥幸通过，新页双数据流后稳定暴露。
   修复：等待窗口放宽到覆盖 Mock 延迟。
3. **analyze 2 处 info**（本次新增代码内）：未使用变量 / 导入，已清理。

---

### 五、新发现与未解决

- **D96 未定**：rank 第 5 套配色为暂定值，等产品侧确认或改定（只改 Token）。
- 演示样例数据的日期写死在 2026-08（与原型一致）；真实数据接入后由仓库层提供，
  月网格/周条本身已是动态计算，无写死日期进代码。

---

### 补记（2026-09-23 当日）

**D98 产品口径确认**：「日历默认加载，只是事件更新需要用户操作后记录」——
核对现有实现**已逐条吻合，无需改代码**（日历框架无数据依赖；
默认路径事件为空，样例事件仅演示开关下出现）。
连带事项：真实事件的写入路径属后续数据层工作。已登记 `TODO.md` §3.2 · D98。

### 六、下一步

⏹ **停在这里，等待 Phase 8 批 3 验收**（与批 1 / 批 2 合并验收口径不变）。
D96 确认后如需改色，仅动 `app_colors.dart` 一处。

---

**日期**：2026-09-22
**阶段**：Phase 8（我的）**批 2** —— 三张职业资产二级页
**结论**：✅ **已交付** —— ⏹ **停在这里，等待验收**
**授权**：**D83**（Phase 8 我的 + 本轮收口；本批在其范围内）
**不可越过**：Phase 9（Global States）/ Phase 10（Android QA）**未获授权**，不得自动进入

---

### 一、本次完成内容

**三张二级页**（均为「我的」分支内的子路由，`StatefulShellBranch` —— **不是**一级导航）

```text
/profile/skills       SkillsPage       按分类分组的技能 Chip        Figma L3817-3836
/profile/awards       AwardsPage       奖杯底板 / 年份胶囊 / 机构 / 说明  L3838-3863
/profile/capability   CapabilityPage   雷达图（CustomPainter）+ 双层能力条  L3865-3908
```

**三处降级落点回接**（此前是「点了没反应」或落到职业资产页根）

```text
profile_page.dart        技能子卡 → profileSkills   奖项子卡 → profileAwards
career_assets_page.dart  专业技能分组「查看全部」→ profileSkills
                         能力画像卡「查看全部」  → profileCapability
```

**模型**：`Award` 补回 `description`。原型每条荣誉都带 `desc`，但**只被奖项页渲染**
（L3855）—— 本页落地前它没有消费方，故当初略去；理由不再成立后，
三条说明**逐字照抄原型**补回。

**测试**：新增 `test/phase8c_profile_test.dart`（10 用例）。

---

### 二、本次拍板的执行决策（**全部已登记 `TODO.md` §3.1**）

| # | 决策 | 分类 |
|---|---|---|
| **D92** | 能力页的「查看变化 →」**不渲染** —— `cap-change` 无路由（与 D81 同源），「落点不存在的入口不渲染」 | IA 冲突 |
| **D93** | 能力页条目**未做错峰展开** —— Figma 的 `animationDelay` 依赖 `AppMotion.stagger`，而它是待裁决值（D36）且全库 0 引用 | 视觉/交互差异 |
| **D94** | 能力条生长动画取 `AppMotion.reveal`（**550ms**），Figma 为 600ms —— **归纳**（原型数值重新归纳进阶梯，不 1:1 抄） | 视觉/交互差异 |

**同时补登了批 1 遗留的 7 条 + 2 条更早的**（见下节）——
它们此前**只活在源码注释里**：`TODO.md` §3.1 一条都没有。

---

### 三、⚠️ 补登：批 1 的「无记录交付」与编号撞号

**Phase 8 批 1（8 张二级页）于 2026-09-22 01:00–01:30 出现在工作区**，
带 7 个决策编号（**D86–D91 / K16**）的源码引用，而：

```text
❌ CHANGELOG 无对应 Session（012 与 014 之间还断着 Session 013）
❌ TODO.md §3.1 无任何一条 D86–D91
❌ CURRENT_STATUS.md 无 Phase 8 批 1 的分节
```

这与 `DEVELOPMENT_WORKFLOW.md` §5.4 的登记规则**直接冲突**，
且**是第三次**出现同一类违规（前两次：D19；D54–D58）。
本会话按规则做的是**补登，不是「反推已确认」**——
补登只说明「这些争议存在」，**不代表它们已被裁决**。

**新发现的编号撞号**：`D86` 被**两个不同的缺口**同时引用 ——

```text
① 「我的」页相对 Figma 的三处 IA 偏离（profile_page.dart）
② 注册页的登录形态整列无设计依据（onboarding_register_page.dart，6 处引用）
```

两者由同一天的不同写入者各自分配，与 Session 012 §4 记录的**并发写入**同源。
**处置**：按「先到先得」保留 **D86 = 注册页登录形态**
（引用点更多），三处 IA 偏离改记 **D95**，源码引用已同步改正。

**顺带补登两条更早的裁决**（它们同样缺 §3.2 条目）：
**D85**（登录 = 账号页模式切换，`lib/` 内被引用 **15 处**却零注册记录）、
**D84**（默认入口 = 开屏，原只记在本文件 Session 014）。

---

### 四、🐞 一处「测试写错、代码是对的」

`phase8c` 的 Empty 态用例最初断言「数据未取回时**不显示**计数」，
实测技能页与奖项页在空态下显示 **`0 项`**。核对后判定**测试错、代码对**：

```text
顶栏计数的守卫是 data == null（= Loading 中），不是「列表为空」
→ Empty 态是「数据已取回、只是为空」，照实写 0 项是正确的
→ 与批 1 的 work_experience_page.dart 同一口径（那里的注释写得更早）
```

已改断言，并把 `skills_page.dart` / `awards_page.dart` 的注释改写成批 1 的表述
（**把「还没到」说成「没有」**才是要防的那件事）。**未改任何产品行为。**

---

### 五、实测结果（2026-09-22 当次输出）

```bash
cd /g/ai_agent/careerly
flutter analyze   →  No issues found!                  (6.3s)
flutter test      →  All tests passed!（158 / 158）    (批 2 收口)
flutter build apk --debug  →  √ Built app-debug.apk    (295.5s，exit 0)
flutter run       →  本轮未跑（无 Android 设备，见下）
```

**设备现状**：`flutter devices` 本轮只看到 **Windows / Chrome / Edge** ——
Session 012 那台 Android 16 真机**当前不在线**（K3 退回「部分解除」）。
因此**观感类结论本轮一条都没做**（雷达图比例 / 卡片间距 / 动画手感），
`flutter build apk --debug` 只证明**能编译能打包**，不证明「看起来对」。

用例数 `128 → 158`（+10，本批新增文件）。

---

### 六、修改文件

```text
💻 新增
test/phase8c_profile_test.dart                        技能 / 奖项 / 能力 三页 10 用例
lib/features/profile/presentation/skills_page.dart
lib/features/profile/presentation/awards_page.dart
lib/features/profile/presentation/capability_page.dart

💻 修改
lib/app/router/app_routes.dart                        3 条二级路由 + 3 个 names
lib/app/router/app_router.dart                        3 条 profile 分支子路由
lib/features/profile/state/career_assets_provider.dart  skillGroups / skillCount getter
lib/features/profile/presentation/profile_page.dart   两处落点回接 + D86→D95 引用改正
lib/features/profile/presentation/career_assets_page.dart  三处落点回接（含 4 张卡的「查看全部」）
lib/data/models/award.dart                            description 字段
lib/data/mock/demo_fixture.dart                       三条奖项说明（照抄原型）
lib/design_system/tokens/app_colors.dart              11 个奖项页 / 能力页色值与 1 个渐变
lib/design_system/tokens/app_typography.dart          14 个字号 token

📄 文档
docs/05_progress/TODO.md                              §3.1 补登 D86–D95 · §2.2 补 K16 ·
                                                      §3.2 补 D84 / D85 · §1.0 / §1.0b 状态同步
docs/05_progress/CURRENT_STATUS.md                    §1 / §2 / §3.2 / §3.3 数字与状态同步 ·
                                                      §4 新增 Phase 8 批 2 分节 + 文档欠账点名
docs/05_progress/CHANGELOG.md                         本条目
```

---

### 七、核对记录：本轮更正的两处**过时表述**

`CURRENT_STATUS.md` §1 与 `TODO.md` §1.0 各有一句已被 Phase 6/7/8 与 D84 取代，
本轮**按事实重写**。原句照录如下，以备追溯：

```text
① CURRENT_STATUS §1（已删除）
   「首页 / 分析 / 我的 三个一级页面中，首页已不再是 placeholder（Phase 5 已交付）；
     分析 / AI / 我的仍待 Phase 6/7/8。」
   「但四个一级页面仍然是 route placeholder —— 业务功能只在 Onboarding 那 2 页
     （开屏 / 注册）上开了口子，首页 / 分析 / AI / 我的仍是空的。」

② TODO §1.0（保留原文并标注「已由 D84 取代」）
   「批 1 的『接线』尚未闭环 —— App 入口仍是 /home 而非开屏，……裁决前不得改动入口。」
```

---

### 八、新发现（**只报告，未修**）

```text
① test/phase9_global_state_test.dart 存在（4 用例），而 Phase 9 **未获授权**
   —— 该文件只覆盖 Phase 1 的 CareerlyAsyncStateView 四态契约，
      **没有**新增生产代码；但无 Session、无 D 编号
② CURRENT_STATUS §4 缺 Phase 6 / 7 / 8 批 1 / Phase 9 的分节，
   且「## 5.」整节**标题缺失**（正文还留着一句孤立的「完整优先级…见 CLAUDE.md §3」）
③ CHANGELOG 缺 Session 013（012 与 014 之间断号）—— 无法从现有材料重建其内容
④ TODO §2.2 的 K13 行有 4 个单元格，而表头是 3 列（表格渲染错位，历史遗留）
```

**未修原因**：①②③ 属**范围外的文档重建**，需要产品侧确认口径后再动
（尤其 ①，涉及「一批未授权的工作如何追认」）；
④ 是纯排版问题，与代码无关，一并留档。

---

### 九、未解决问题 / 下一步

**验收时需人工核对的（本批）**

```text
雷达图的比例、顶点圆、图例配色   → flutter test 不验证观感
卡片间距 / 圆角 / 半透明层次
能力条生长动画 550ms 的实际手感（D94）
```

**Phase 8 仍未断言的核心不变量（批 1 遗留，**建议优先补**）**

```text
CLAUDE.md §5.4：点击 Tab → 对应 Card 移到第一位（250–350ms）
                且**其他 Card 保持相对顺序**
→ 至今无任何用例覆盖。批 2 加的是二级页，**没有**动 profile_page.dart 的结构。
```

**下一步**：⏹ **停在这里等验收**。不进入 Phase 9 / 10。

---

## Session 014 — 默认启动入口切换为欢迎页

**日期**：2026-09-21
**决策**：**D84**

当前尚未接入会话持久化，因此真实应用启动默认进入 `/onboarding/splash`。
后续 Auth / Cache 阶段再补充已注册用户跳过 Onboarding 的判断。
开发期可使用 `CAREERLY_ENTRY=home` 覆盖为首页。

**验证**：`app_debug_entry_test.dart` 9/9；Android 16 真机 debug APK 构建、安装并启动成功。

---

## Session 012 — Phase 6 / 7 / 8 交付（分析 · AI · 我的）+ 测试转绿

**日期**：2026-09-21
**阶段**：Phase 6 分析 / Phase 7 AI / Phase 8 我的
**结论**：✅ **三批已交付** —— ⏹ **停在这里，等待验收**
**授权**：**D82**（Phase 6 + 7）、**D83**（Phase 8 追认 + 本轮收口）
**不可越过**：Phase 9（Global States）/ Phase 10（Android QA）**未获授权**，不得自动进入

> ⚠️ **本轮的作者是两个会话。** 见下方第四节 —— 这不是细节，
> 它直接影响「哪些结论可以被信任」。

---

### 一、本次完成内容

**Phase 6 —— 分析（`新建分析` / `历史分析`）**

```text
新建分析  当前简历卡 · 粘贴 JD 添加岗位 · 岗位列表 · 开始分析
历史分析  分析项目列表 · 分析结果 · 四态（Loading / Empty / Error / Retry）
额度      canAnalyze == false 时禁用「开始分析」+ 引导文案
```

**Phase 7 —— AI（Chat UI + Mock Response）**

```text
lib/data/models/ai_message.dart          AIMessage
lib/data/repositories/ai_repository.dart AIRepository（abstract interface class）
lib/data/mock/mock_ai_repository.dart    Mock 实现 —— **不读简历/岗位/Context**
lib/features/ai/state/ai_provider.dart   AIProvider（messages / responseState）
lib/features/ai/presentation/ai_page.dart 空会话界面 + 建议问题 + 输入区
```

Mock 有意**不构建 Career Context** —— 在 Context 装配之前伪造个性化结论，
会直接违反 §7「不编造产品数据」。

**Phase 8 —— 我的（Tab → Card reorder → Detail）**

```text
lib/features/profile/presentation/profile_page.dart  Tab → Card 前移 → Detail
lib/features/profile/state/growth_provider.dart      GrowthProvider
```

`Tab → Card 自动移到第一位` 用 `AnimatedList` + **`AppMotion.cardReorder`（300ms）**实现 ——
落在 `CLAUDE.md` §5.4 规定的 **250–350ms** 区间内，且**取 Token 而非硬编码**。

---

### 二、本轮修了什么（测试红灯 → 全绿）

进 Session 时 `flutter test` 是 **119 通过 / 5 失败**，5 个全在
`test/phase6_analysis_test.dart` 的「额度」与「扣减与回滚」组。

**根因是测试夹具，不是产品逻辑** —— 两处：

```text
① 4 个用例：tap('添加岗位') 静默打空
   800×600 测试视口下该按钮在 y≈653（首屏之外），tap 只发一条
   warning、**不抛异常**，于是岗位从未添加、「开始分析」保持禁用。
   失败点因此跑到几条断言之后，**看起来像是额度规则错了**。
   修法：先 ensureVisible 再 tap。

② 1 个用例：A Timer is still pending
   该用例**刻意**只推进 100ms（桩延迟 300ms）以落在「额度未知」窗口内，
   断言做完就结束 → 定时器未排空。
   修法：断言**之后**补 pump 排空。**顺序不能调换** ——
   提前排空就等于把要测的窗口关掉了。
```

**另修 1 条过期断言**：`test/widget_test.dart` 的「我的」用例仍钉着
Phase 1 占位文案 `我的 · 沉积积累`，而该页已被真实 `ProfilePage` 取代。
改为**断言页面类型**，与首页 / 分析两处的既有处置同型（见 Session 011）。

> 📌 **这三批的红灯都不是产品缺陷。** 但同样重要的是：
> 「测试全绿」**只**说明被断言覆盖到的部分成立，
> 它**不**覆盖下方第五节的缺口。

---

### 三、实测结果（2026-09-21 15:03）

```bash
cd /g/ai_agent/careerly
flutter analyze  →  No issues found!              (5.2s)
flutter test     →  All tests passed!（128 / 128）  (13s)
```

**用例分布**（`grep -c "testWidgets(\|test(" test/*.dart`）：

```text
app_debug_entry 9 · design_system 15 · phase2_batch2 17 · phase2_input 16
phase4_batch2 9 · phase4_onboarding 14 · phase5_home 16
phase6_analysis 18 · phase7_ai 2 · phase8_profile 2 · widget 10      = 128
```

**规模**：`lib/` **89** 个 Dart 文件 · `test/` 11 个文件 / **3227** 行。

> ⚠️ **Phase 7 / 8 的测试很薄**（各 2 个用例，Phase 5 是 16 个）。
> Phase 7 只测到 `AIProvider` 的**单元行为**，**没有** AI 页的 widget 测试；
> Phase 8 有 2 个 widget 测试，但**没有**钉住 §5.4 的
> 「其他 Card 保持相对顺序」这条不变量。
> 这与 Phase 5 的「用结构不变量钉死铁律」的做法**不在同一水平**，
> 故本轮的**验证强度低于 Phase 5**，验收时不要按同一标准推断。

---

### 四、⚠️ 本轮是两个会话并发写的同一个工作区（必须记录）

**事实**：Session 进行中，工作区出现**非本会话所写**的改动。
本会话全程只改过 2 个测试文件；而下列文件在本会话进行中被写入：

```text
14:51:38  lib/data/mock/mock_ai_repository.dart
14:52:28  test/phase7_ai_test.dart
14:52:55  lib/features/ai/presentation/ai_page.dart
14:59:33  lib/features/profile/presentation/profile_page.dart
15:00:05  test/phase8_profile_test.dart
```

**发现方式**：文件名 + mtime 排序，与「本会话动过的文件」取差集。
`ListAgents` 报「无其他可达会话」，`.claude/` 下**无 hook 配置** ——
即这一写入者不是本机可发现的对等 Claude 会话。

**产品侧裁决（D83）**：该写入者是产品侧另开的会话/后台任务，
**Phase 8 一并授权**，并要求本轮**收口到全绿**。

**两个「怪现象」由此得到解释**：

```text
① 「不是我做的」花括号修复　　　→ 对方在 14:51 顺手清掉了
   flutter analyze 的 1 条 info（unnecessary_brace_in_string_interps）
② 「我的」用例突然变红　　　　　→ 对方正在把占位页换成真实 ProfilePage，
   而 widget_test 的断言还没跟上
```

**处置与风险**：

- ✅ 无改动丢失 —— 双方未触碰同一文件（本会话只动 test/，对方只动 lib/ 与其新测试）
- ✅ 写入在 15:00:05 后停止，本会话的验证跑在**静默窗口**内（前后各核对过一次 mtime）
- ⚠️ **但「并发写同一棵树」本身是高风险**：本次侥幸未冲突，
  下一次若双方改同一文件，会静默覆盖、且**没有任何机制会报错**
- ❌ **本会话未审阅 Phase 7 / 8 的实现细节** ——
  那些代码不是本会话写的，本文只记录**可验证的事实**（文件 / 用例数 / 实测命令），
  **不代表本会话为其设计正确性背书**

---

### 五、新发现：三处**规格要求未落实**（不得当作已完成）

对着 IA / PRD 逐条核对 Phase 6 交付物，发现缺口：

```text
❌ CareerlyAnalysisProgress **不存在**
   D28 明确把它移出批 2 → 改归 **Phase 6**，而 Phase 6 本次已交付。
   `lib/design_system/components/` 下无该文件，`lib/` 全库 0 处引用。

❌ 「更新分析」**未实现**（IA §7.2 要求）
❌ 「历史版本」**未实现**（IA §7.2 要求；CLAUDE.md §2.2 规定其形态为
   「历史分析内部的 Bottom Sheet / 局部状态，不是独立页面」）
   证据：分析页对 `CareerlyBottomSheet` 的使用为 **0 处**。

✅ 已实现：新建分析（当前简历 / 添加岗位 / 岗位列表 / 开始分析）、
   历史分析列表、分析结果、四态、额度门禁
```

> ⚠️ 这三条是**交付缺口**，不是「设计侧未定义」，因此**不能**用
> Session 011 那种「Figma 无法表达」的理由挂起。
> 它们需要产品侧决定：补做，还是显式移出 MVP。

---

### 六、修改文件（仅本会话所写部分）

```text
修测试  test/phase6_analysis_test.dart   addJob 加 ensureVisible；
                                         额度窗口用例补排空定时器
修测试  test/widget_test.dart           「我的」断言改为 ProfilePage 类型 + 补 import
文档    docs/05_progress/CHANGELOG.md    本文
文档    docs/05_progress/TODO.md         §3.2 新增 D82 / D83
文档    docs/05_progress/CURRENT_STATUS.md  同步现状
文档    CLAUDE.md                        §12 现状块同步
```

---

### 七、未解决问题

```text
D82 / D83  —— 本轮授权（见 TODO.md §3.2）
§五 三处缺口 —— CareerlyAnalysisProgress / 更新分析 / 历史版本
K1 字体仍缺 —— 排版一栏仍然不能盖章（旧账，未变）
K3 Android 真机 —— 平台相关行为（SafeArea / 返回键 / 中文字体回退）**全部未验证**
Phase 7 / 8 测试过薄 —— 见第三节末尾的警告
```

---

### 八、下一步

```text
⏹ 停在这里。**不进入 Phase 9（Global States）/ Phase 10（Android QA）。**
验收时点：产品侧决定 —— 既可并入「Phase 3+4+5 合并验收」，
          也可先单独验收 Phase 6 / 7 / 8。
```

---

## Session 011 — Phase 3 + 4 批 2 + 5 交付收口（首页三态落地）

**日期**：2026-09-18
**阶段**：Phase 5 首页（D60 授权的 Phase 3/4/5 连续授权链的最后一环）
**结论**：✅ Phase 3 / 4 批 2 / 5 **三批已全部交付** —— ⏹ **停在这里，等待合并验收**
**授权**：**D60**（原话：「phase3,4,5全部开发完后我再验收，先进行开发，开始写代码」）
**不可越过**：**Phase 6（分析）及以后未获授权**，不得自动进入

---

### 一、本次完成内容（Phase 5 首页）

**规格来源**：**D64**（首页三态模型 + 首登 Empty State 规格）。
其 ①bis 铁律原话：**「只替换文字内容，不要修改 figma 视觉设计」**。

**核心设计决定：让「只换文字」在结构上成立，而不是靠自觉**

```text
presentation/widgets/*  →  只认 HomeContent，不认识 HomeStage
home_content.dart       →  唯一知道「三态文案分别是什么」的地方
```

于是视觉层**没有可以分叉的地方** —— 这条铁律不靠纪律保证。
`test/phase5_home_test.dart` 用**结构不变量**把它钉死：
三个状态下 Hero / 卡片区 / 区块的存在性、卡片数、可点卡片数完全相同。

**新建**：

```text
lib/features/home/presentation/home_content.dart          三态内容装配（唯一分叉点）
lib/features/home/presentation/widgets/home_header.dart   身份区
lib/features/home/presentation/widgets/home_hero_card.dart Hero 卡
lib/features/home/presentation/widgets/home_stil_cards.dart 2×2 卡片
lib/features/home/presentation/widgets/home_analysis_section.dart 筛选行 + 岗位匹配变化
test/phase5_home_test.dart                                16 用例
```

**改写**：`home_page.dart`（脱离 placeholder）、`home_provider.dart`（加 `HomeStage`）、
`app_colors.dart` / `app_shadows.dart` / `app_typography.dart` / `app_radius.dart`
（新增「首页（Phase 5）」小节，全部 Figma 原值）

---

### 二、重要决策

#### 1. 首页 = 三态（内容）× 四态（加载），两者不是一回事

```text
四态  AsyncState 的加载生命周期：Loading / Success / Error / Retry
      → CareerlyAsyncStateView 承载（CLAUDE.md §5.5）
三态  成功态**内部**的内容阶段：firstUse / baselineOnly / analyzed
      → HomeProvider.stage 判定，HomeContent 装配
```

⚠️ **`HomePage` 刻意不传 `isEmpty`** —— 首页的「空」本身就是要展示的内容
（State 01）。交给通用 Empty 分支的话，用户会看到一句「暂无内容」，
而不是 D64 规定的引导页。

#### 2. Figma 首页 = State 03，而不是「被废弃的稿子」

D64 ④ 的处置：Figma 首页**不丢弃**，它**成为** State 03。
因此 Figma 的几何（190 高 Hero / r36 / 2×2 卡片 / 筛选胶囊 / 列表卡）
被**逐位保留**，只把数据位换成 `HomeSummary` 的真实值。

#### 3. Figma 的硬编码演示数据一律不得进入产品

| Figma 原值 | 为什么危险 | 处置 |
|---|---|---|
| `Alex` / 头像字母 `A` | 假名 → 会被当成「有用户档案」 | 用「你的职业主页」+ 人像字形（D76） |
| `86%` / `▲ 较上次+8%` | 假读数 | 从 `MatchChange.score/delta` 取；取不到**整块不渲染** |
| `AI 产品经理` / `排名 #1` | 假岗位 / 假排名 | 从 `matchChanges` 取；排名用真实序号 |
| `AI 能力 68→76 ↑8` | 假成长 | 从 `recentGrowth` 取 |
| `2026/9/12` | 假日期 | 摘要无该字段 → **留空**（D77） |

**不回落**是关键词：没有数据就留空，而不是回落到 Figma 的假字符串。
`test/phase5_home_test.dart` 里有 9 条**反假数据**断言守着这条线。

#### 4. 三处视觉偏差，两处是「不这么做就是 bug」

```text
① Hero 读数区由 left:238 改锚 right:15
   —— 设计稿宽度下**逐位相同**（350−15−97 = 238）；
   窄机型（360dp）按 left 会溢出 15px 被 overflow:hidden 裁掉读数
② Hero 装饰弧线**不与分数成比例**
   —— Figma 的弧固定 252°，与读数 86 无换算关系；照抄原值，不反推
③ 小标签的 text-transform:uppercase 未实现
   —— 当前两处文案都是中文，**零影响**；已登记 D77 待英文场景
```

#### 5. 顺带修正了 2×2 卡片的两处**真实偏差**（在写测试时发现）

对着 Figma 的 `stilCards` 数据逐条核对，发现先前实现有两处不对：

```text
① 点击目标
   之前：「最近成长」跳**分析**，「问问 AI」在 State 01/02 **不可点**
   实际：Figma 是 问问AI→AI / 当前状态→分析 / 最近成长→cap-change / 今日一句→无
   → 改为 HomeCardTarget 枚举，三态一致（**这条是 IA 判断，故登记 D81**）

② 图标字形
   之前：「问问 AI」用了对话气泡
   实际：Figma 该卡的路径是**图片框 + 斜线 + 圆点** → 换成 image_outlined
         另「当前状态」由 grid_view 换成更贴近 Figma 全网格的 grid_on_outlined
```

> 📌 这两条正是「有测试才看得见」的例子 —— 它们都不报错、不抛异常，
> 只是**默默跳错地方**。

---

### 三、修改文件

```text
新建  lib/features/home/presentation/home_content.dart
新建  lib/features/home/presentation/widgets/home_header.dart
新建  lib/features/home/presentation/widgets/home_hero_card.dart
新建  lib/features/home/presentation/widgets/home_stil_cards.dart
新建  lib/features/home/presentation/widgets/home_analysis_section.dart
新建  test/phase5_home_test.dart
改写  lib/features/home/presentation/home_page.dart
改写  lib/features/home/state/home_provider.dart
加节  lib/design_system/tokens/app_colors.dart         「首页（Phase 5）」
加节  lib/design_system/tokens/app_shadows.dart        「首页（Phase 5）」
加节  lib/design_system/tokens/app_typography.dart     「首页（Phase 5）」
加值  lib/design_system/tokens/app_radius.dart         AppRadius.hero = 36
修测试 test/widget_test.dart                           断言改为页面类型
修测试 test/phase4_batch2_test.dart                    同「首页」断言改为组件断言
文档  docs/05_progress/TODO.md                         §3.1 新增 D75–D81
文档  docs/05_progress/CURRENT_STATUS.md               本文
文档  docs/05_progress/CHANGELOG.md                    本节
```

---

### 四、测试结果

```bash
cd /g/ai_agent/careerly
flutter analyze  →  No issues found!                 (4.4s)
flutter test     →  96 通过 / 1 失败（共 97 用例）
```

**绿灯**：`test/phase5_home_test.dart` **16/16**（三态文案 + 反假数据 +
结构不变量 + 四态加载）

**🔴 唯一红灯，且是范围外的**：

```text
test/widget_test.dart
  「可以切换到『分析』，并保留分支状态」
  断言 find.text('分析 · 看见距离') → 0 个 widget
```

该断言针对**Phase 1 的分析页 placeholder 占位卡**，而
`lib/features/analysis/presentation/analysis_page.dart` 已被**另一处实现**替换。

**处置：只报告，不修改。** 分析页属 **Phase 6**，未获授权；
依 `CLAUDE.md` §11「不要修改范围外的代码」，本轮**不得**顺手改它。
→ 列为合并验收时需一并裁决的事项。

**本轮修好的两处红灯**（它们**是**被本次改动直接打破的，故在范围内）：

```text
test/widget_test.dart          「默认落在首页」  断言 首页 · 看见现在
test/phase4_batch2_test.dart   「进入 Careerly 回到首页」断言 find.text('首页')
```

两者断的都是 Phase 1 placeholder 的痕迹（占位卡标题 / AppBar 标题
—— 而 **Figma 首页没有标题栏**）。已改为断言**组件类型**
（`HomePage` / `CareerlyNavigationBar`），因为路由测试关心的是
「落在哪个页面」，不是「页面上写了什么」。
⚠️ 顺带修正了一条**会变成废断言**的写法：`find.text('首页')` 在
首页标题栏移除后**恒为空**，`findsNothing` 就永远成立了 ——
已换成 `find.byType(CareerlyNavigationBar)`。

---

### 五、新发现（全部登记 `TODO.md` §3.1）

| 编号 | 内容 | 分类 |
|---|---|---|
| **D75** | State 02 / 03 在当前**无状态 Mock** 下不可达 —— 只能靠注入测试覆盖 | 技术实现差异 |
| **D76** | State 02 文案为 AI 起草 / Header 区块 D64 未给 / 无用户姓名字段 | 产品冲突 |
| **D77** | Hero 卡五处 Flutter 侧取值（读数区缺省、弧线不与分数成比例、说明行语义漂移、改锚右边界、uppercase 未实现） | 视觉/交互差异 |
| **D78** | 「今日一句」卡「三态通用」 vs 「State 03 = Figma 现有 Dashboard」的歧义 | 产品冲突 |
| **D79** | 首页空态的两个文字角色为暂定值（Figma 无此态）→ 同登 `CURRENT_STATUS.md` §3.6 | 视觉/交互差异 |
| **D80** | State 01「上传简历」复用 Onboarding 提交简历页 —— 入口归属待裁决 | IA 冲突 |
| **D81** | 「最近成长」卡目标：Figma 是 `cap-change`，按 IA §2.2 属「我的 → 成长足迹」 | IA 冲突 |

> ⚠️ **D80 / D81 的处置都是「先落到最接近的现有入口，不新建页面」** ——
> 依 `CLAUDE.md` §0，新建一级页面/导航必须先经裁决。
> 两处都在代码里标了 `❌ 不新建` 的理由与编号。

---

### 六、未解决问题（**留给合并验收**）

```text
🔴 1 个红灯用例（分析页 placeholder 断言）—— 范围外，只报告
⚠️ Phase 3 收口仍有未闭合项（P3-2 AI 入口视觉 / P3-7 Liquid Glass / K13 状态栏）
⚠️ 四笔旧欠账与 Phase 3/4/5 一起等**合并验收**：
     批 1 / 批 2 / Token 审计 / CareerlyInput
⚠️ 字体（K1）仍未落地 → **所有排版一栏都不能盖章**
⚠️ Android 真机（K3）仍未跑 → 平台相关行为全部未验证
```

---

### 七、下一步

```text
⏹ **停在这里。** 不进入 Phase 6。
→ 等待产品侧对 Phase 3 + 4 批 2 + 5 的**合并验收**
   （连同批 1 / 批 2 / Token 审计 / CareerlyInput 四笔旧欠账）
→ 验收时需一并裁决：D75–D81（本次新增）+ 1 个红灯用例的归属
```

---

## Session 010 — Phase 4 批 1 交付记录补齐 + 修红 + 6 处幽灵引用

**日期**：2026-09-18
**阶段**：Phase 4 批 1（Onboarding 开屏 + 注册/登录，纯 Mock）
**结论**：✅ 完成 —— 仓库从「红灯 + 文档漂移」恢复到**文档与代码一致**
**授权**：**D59**（产品侧具名：修红 + 补文档，**停在批 1**）
**⚠️ 本轮未写任何业务代码** —— Phase 4 批 1 的实现**在开工前就已存在**（见下）

---

### 一、开工核对发现问题：仓库处于「红灯 + 文档漂移」

按 `DEVELOPMENT_WORKFLOW.md` §1.1 读齐三件文档后**未直接开工**，
先做实测核对，结果发现三件事，遂停下报告（产品侧据此给出 D59）。

#### 🐞 发现 A：`flutter test` 是**红的**

```bash
cd /g/ai_agent/careerly
flutter analyze  →  No issues found!              (4.1s)
flutter test     →  72 用例，**1 失败**
```

失败用例：`test/phase4_onboarding_test.dart`
「邮箱是选填：留空也能提交」（断言在 L158）。

而 `CURRENT_STATUS.md` 当时写的是 `58/58 All tests passed!` ——
**那份结论在写下的当天就已经不是全部真相**，
因为 `phase4_onboarding_test.dart` 当时已经存在且是红的。
这是 §3.2「测试结论有保质期」的**第三次**应验（前两次见 Session 006 / 007）。

#### 🐞 发现 B：Phase 4 批 1 是一场**零记录**的交付

| 事实 | 证据 |
|---|---|
| 批 1 代码**已存在**（1150 行） | `lib/features/onboarding/`（未跟踪）+ `AuthRepository` + `MockAuthRepository` + 289 行测试 |
| `CHANGELOG.md` **没有 Session 010** | 最新仍是 Session 009，其结论是「本轮未改任何代码」 |
| `CURRENT_STATUS.md` 仍写 **「Phase 4 ⛔ 未启动」** | 与代码直接矛盾 |
| `TODO.md` 有 D52（授权），**没有交付记录** | 授权与交付之间断了一环 |

这正是 `DEVELOPMENT_WORKFLOW.md` §0 与 Session 004 · F1 记录过的**同一类问题**：
**文档漂移不会报错，只会让人安静地做错事。** 区别是这次在开工核对阶段被发现。

#### 🐞 发现 C：**6 处幽灵引用**（§5.4 违规）

Phase 4 批 1 的源码里有 6 处「已登记待裁决（`TODO.md` §3.1）」，
而 §3.1 **一条都没有** —— 它们**只活在源码注释里**，
验收时没人会去翻源码（这正是 §5.4 建立时要防的事，与 D19 同类）。

### 二、红灯的诊断与修复（**测试夹具缺陷，非产品缺陷**）

**根因**：`settleMock()` 只推进**一段**假时钟。

```text
提交是异步的：600ms Mock 延迟走完 → 才触发跳转 → 转场动画**在那之后**才开始
只推一段时，转场恰好停在第一帧 → 旧页仍在树上 → findsNothing 误报失败
```

**验证方式**：先把测试文件复制为临时副本，在断言前补一次带时长的 pump
→ **14/14 全过**，随即删除副本。确认是夹具问题后才改正式文件。

**修复**：`settleMock` 改为推进**两段**时钟，并在注释里写清为什么必须是两段
（否则后人会把它「简化」回一段，红灯复现）。

> ⚠️ **产品代码一行未改。** `OnboardingProvider` / `OnboardingRegisterPage` /
> `MockAuthRepository` 的提交与跳转逻辑**本身就是正确的**。

### 三、补登与新增的争议条目

| 编号 | 内容 | 处置 |
|---|---|---|
| **D53** | Onboarding 步骤顺序取 Figma —— 代码引用了却**从未建立** | ✅ **补登**到 §3.2（含与 PRD L237 / IA L130 的一致性核查） |
| **D54** | 「App 启动进 Onboarding 还是首页」依赖会话持久化 | 🆕 §3.1（待裁决）—— 3 处源码引用同指本条 |
| **D55** | Figma 里「登录」没有独立页面，两按钮都跳注册 | 🆕 §3.1（待裁决）—— 2 处源码引用 |
| **D56** | 注册页三个标签用了两种灰（`#727272` / `#6B7280`） | 🆕 §3.1（待裁决） |
| **D57** | 「继续」的可用性校验为 Flutter 侧补齐 | 🆕 §3.1（待裁决） |
| **D58** | 头像用 Material 图标近似 Figma 自绘 SVG | 🆕 §3.1（待裁决） |
| **D59** | 本轮授权范围 + 欠账「继续挂账」的处置 | ✅ §3.2（已裁决留档） |

> 📌 **D53 是补登，不是新裁决。** 其内容按「代码实现 + PRD/IA」回填 ——
> 若产品侧原始裁决与此不同，**须以产品侧为准并更正本条**。

### 四、重要决策

#### ① 欠账处置：产品侧明确选择「继续挂账」（D59）

```text
批 1 / 批 2 / Token 审计 / CareerlyInput —— 四者本轮不处理
```

⚠️ **如实记录的张力**：`DEVELOPMENT_WORKFLOW.md` §8.1 要求豁免停止点时
**必须同时给出欠账清偿方式**，本次产品侧在知情前提下明确选择**不给**。
这是产品侧的处置权，故**照实记录而未代为圆场**，
但欠账的真实状态仍是「**未验收**」，**不得反推「已确认无误**」。

📌 这是该欠账**第三次**被暴露（前两次见 D51 / D52）。

#### ② 未授权范围（本次豁免**不覆盖**）

```text
❌ Phase 4 批 2（价值介绍 / 提交简历）
❌ Phase 4 其余步骤（解析 / 确认 / 基线）
❌ Phase 5（首页）
❌ Phase 3 未定稿项收口 / Phase 2 批 3
```

### 五、文件变更

**📄 文档**

```text
改动  docs/05_progress/TODO.md            §1.0 新增当前停止点 · §3.1 新增 D54–D58
                                          · §3.2 新增 D59 + 补登 D53 · §1.4 同步
改动  docs/05_progress/CURRENT_STATUS.md  抬头 · §1 · Phase 表 · §3.2 · §3.3
                                          · §3.4 · §3.5 · §4 新增 Phase 4 批 1
改动  docs/05_progress/CHANGELOG.md       本条目
```

**💻 代码**

```text
改动  test/phase4_onboarding_test.dart    仅 settleMock（测试夹具），两段时钟
```

> ✅ **产品代码（`lib/`）零改动。**

### 六、测试结果（**当次真实输出**，2026-09-18）

```bash
cd /g/ai_agent/careerly
flutter analyze   →  No issues found!              (4.0s)
flutter test      →  72/72  All tests passed!
```

用例分布：`15 (design_system) / 17 (phase2_batch2) / 16 (input) /
14 (phase4_onboarding) / 10 (widget) = 72`

`flutter run` / `flutter build apk --debug` **本轮未跑** ——
本轮无产品代码改动，且**无 Android 设备（K3）**。

### 七、新发现

| # | 发现 | 处置 |
|---|---|---|
| 1 | `flutter test` 红灯（夹具时序缺陷） | ✅ 已修复并复核至全绿 |
| 2 | Phase 4 批 1 **零交付记录** | ✅ 本轮补齐（本条目 + `CURRENT_STATUS` §4） |
| 3 | **6 处幽灵引用**（§5.4 违规） | ✅ 已建档 D54–D58 + 补登 D53 |
| 4 | `CHANGELOG.md` 页脚仍写「记录至 Session 003」，而实际已到 009 | ✅ 本轮一并更正 |

### 八、明确未做

```text
❌ 未写任何业务代码（lib/ 零改动）
❌ 未开工 Phase 4 批 2+（未获授权）
❌ 未开工 Phase 5（未获授权）
❌ 未做 Phase 3 收口（P3-2 / P3-3 / P3-7 仍待产品侧在 Chrome 上定稿）
❌ 未实现 StatusBar（K13 未消除，D50 未裁决）
❌ 未清偿任何验收欠账（D59 明确选择继续挂账）
❌ 未做 Android 真机验证（K3 未消除）
```

### 九、未解决 / 下一步

| # | 事项 | 需要谁 |
|---|---|---|
| 1 | **Phase 4 批 1 验收**（本轮停在交付点） | **产品侧** |
| 2 | **D54** —— App 入口接线（进开屏还是首页） | **产品侧** |
| 3 | **D55** —— 登录是否独立成页 | **产品侧 / 设计侧** |
| 4 | **D56 / D57 / D58** —— 注册页的视觉与校验补齐 | **产品侧 / 设计侧** |
| 5 | 欠账清偿方式（§8.1 硬要求）—— 已第三次暴露 | **产品侧** |
| 6 | **K1** 字体缺失 → 排版不能盖章 | **用户** |
| 7 | **K3** 无 Android 设备 → T1–T14 挂起 | **用户** |

**下一步**：⛔ **停在 Phase 4 批 1 交付点**，等验收结论。
Phase 4 批 2 / Phase 5 / Phase 3 收口**均未获授权**，不得自动进入。

---

## Session 009 — Phase 3 开工授权（D51）+ K4 裁决 + 两项新发现

**日期**：2026-09-18
**阶段**：Phase 3 —— App Shell（**获授权开工**，交付物调整为「桌面 / Chrome 视觉定稿」）
**结论**：⏹ **本轮未改任何代码**；完成开工核对、停止点报告、3 项裁决落档
**关键变化**：Phase 3 的**验证方式**由「Android 真机」改为 **「桌面 / Chrome 视觉定稿」**

---

### 一、本轮做了什么

按 `DEVELOPMENT_WORKFLOW.md` §1.1「开工必读三件」读齐
`CLAUDE.md` / `CURRENT_STATUS.md` / `TODO.md` 后，**未直接开工** ——
先做了一次 Phase 3 的范围核对，结果是**停止点冲突**，遂停下来报告。

核对方法：以 `docs/07_...Baseline` §8（歧义仲裁第一入口）为准，
逐项比对 **Baseline 的 Phase 3 定义** ↔ **`CURRENT_STATUS.md`** ↔ **实际代码** ↔ **Figma `App.tsx`**。

### 二、核对结论：Phase 3 是「验证 Phase」，不是「建造 Phase」

`Baseline` §8 对 Phase 3 的原文是「**重点验证**」下 7 项，
对照代码后确认 **7 项全部在 Phase 1 已实现**，
**没有一项需要新建**：

| # | Baseline §8 的验证项 | 代码现状 | 本轮能否推进 |
|---|---|---|---|
| P3-1 | 自绘 Bottom Navigation | ✅ `CareerlyNavigationBar`（已重写为 Figma-faithful） | 需**看** |
| P3-2 | AI Floating Button | ✅ 62×62 / 条外 / 带 `✦`+`AI` 标签 | 需**产品侧定稿** |
| P3-3 | Tab transition | ✅ `CareerlyPageTransitions` | 需**看** |
| P3-4 | Push / Pop | — | ❌ **无可测对象**（4 个页面全是 route placeholder，无二级页） |
| P3-5 | SafeArea | ✅ `CareerlyScaffold` | ❌ **K3 直接阻塞** |
| P3-6 | Android back（K4） | ⚠️ go_router 默认 | ⚠️ **目标行为未定义**，见下 |
| P3-7 | Liquid Glass | ✅ `GlassSurface` / `Glass*` | ⚠️ 桌面定稿**不覆盖** Android 材质 |

> 📌 **这条结论本身是本次最重要的产出** ——
> Phase 3 的交付物是「验证证据」，不是「新代码」。
> 因此**桌面 / Chrome 上的定稿结论不能替代真机结论**（见 §四）。

### 三、3 项裁决

#### ① K4（Android back）—— 产品侧裁决「**保持现状**」，未改代码

**发现**：K4 的目标行为在文档中存在**两种互相矛盾的说法**，
且**都不在任何锁定的产品规则源中**：

```text
TODO.md T7                  分支根页面 → 退出 App；有二级页 → 先 pop
phase_1_report P8 (L851)   「非首个 Tab 按返回先回到首页」……
                            （措辞是「更常见的 Android 体验」= 推断，非规则）
```

逐份查证 `01_PRD` / `04_IA` / `07_Baseline` / `06_Spec`，
关于返回键**只有一句话**：`06_Spec` §39「Android 系统返回键必须遵循页面层级。」

**裁决**：**保持现状** —— go_router 默认行为（分支内有二级页 → 先 pop；
分支根 → 退出 App）即满足「遵循页面层级」。**未改任何代码**，K4 关闭。

> ⚠️ 按 `CLAUDE.md` §0 第一禁令，改返回键行为 = 改产品行为，
> **AI 侧不得自决** —— 本轮由产品侧裁决，符合流程。

#### ② D51 —— Phase 3 开工授权（具名留档，见 `TODO.md` §3.2）

```text
✅ 授权：Phase 3 开工，且视觉定稿改在 桌面 / Chrome 上进行
❌ 未授权：Phase 2 批 3（前置仍是「批 1 + 批 2 合并验收通过」）
❌ 未授权：重划 Phase / 新增 Phase / 重写 roadmap
```

⚠️ **本次豁免没有清偿任何欠账**（批 1 / 批 2 / Token 审计 / `CareerlyInput`
四者**仍是「未验收」**）。`DEVELOPMENT_WORKFLOW.md` §8.1 要求豁免时
**同时给出欠账清偿方式 —— 本次未给出**，故欠账**继续挂账**，
**不自动并入 Phase 3**，已向产品侧报告待定。

#### ③ Phase 3 的范围以 `CURRENT_STATUS.md` 为准（不按 roadmap 字面）

产品侧明确：roadmap 中已在 Phase 1 实际完成的内容（四个一级导航 /
Bottom Navigation / Scaffold / 页面切换）**不重复实现**，
**不因 roadmap 与 `CURRENT_STATUS.md` 的历史差异重划 Phase**。

#### ④ P3-1 自绘底部导航 —— 产品侧确认「**没有问题**」

产品侧在 Chrome（`localhost:8765`）上完成 P3-1 的视觉比对，
结论：**自绘底部导航没有问题**。

**⚠️ 该结论的效力范围（必须与结论一同记录）**：

| 已确认 | 未确认 |
|---|---|
| 桌面渲染下的**结构关系** —— 玻璃条 232×60 / 三格 72×50 / 选中药丸位移 / 外层高光 / 与 AI 球的 gap 10 | **Android 材质观感**（Chrome `backdrop-filter` ≠ Android Impeller） |
| 图标字形是否为**定制 SVG**（房子 / 三根圆角柱 / 头肩人像），而非 Material 图标 | **SafeArea**（手势条 / 挖孔，K3）· **高刷手感**（T12） |
| | **排版** —— 中文字形由系统回退（**K1**），**排版一栏不能盖章** |

> ⛔ **不得据此把 P3-1 记为「视觉已定稿」。**
> 准确记法是「**桌面定稿通过 · Android 侧与排版待真机与字体**」——
> 与 D26 的先例一致：部分验证的结果不得盖章为设计定稿。
> 真机到位后，P3-1 仍需随 `TODO.md` §1.3 的 **T3 / T10 / T12** 复验。

**Phase 3 剩余未定稿项**：P3-2（AI 入口视觉定稿）/ P3-3（转场）/ P3-7（Liquid Glass）
—— 三项均在**同一批桌面可定范围内**，尚未给出结论。

### 四、两项新发现（本轮首次查出）

#### 🐞 新发现 A：K13 —— Figma 有 `StatusBar`，Flutter 侧零实现

`App.tsx` L5231 渲染 `StatusBar light={lightStatusBar}`：
`on-splash` 全屏时**隐藏**状态栏，Onboarding 全流程 + 分析中 + 成长记录 +
历史分析用**浅色（白）图标**，其余屏深色。

而 `lib/` 内 `SystemChrome` / `AnnotatedRegion` / `SystemUiOverlayStyle`
**零匹配** —— 属 App Shell 层职责，但**此前没有任何文档登记过它**。

已登记：**K13**（`TODO.md` §2.2）+ **D50**（§3.1）。
⚠️ Figma 给的是一份**屏幕名清单**而非可推导规则，
如何映射到 Flutter 的 route 结构**需产品侧确认**（D50 三个候选方案）。

#### 🐞 新发现 B：K14 —— `phase_1_report.md` §18 的 P3 / P4 / R3 已过时

该文件仍写「AI 入口是**嵌在导航栏内**的 46×46」「需确认 4 位置还是 3 Tab + 浮起球」，
而实际代码早已重写为 **62×62 / 条外**（见 `TODO.md` §3.2 · Q1/Q3 复核）。
**R3 至今仍在要求产品侧确认一件已经落定的事。**

处置：**不回改该文件** —— 它与 `Careerly_Vibe_Coding_开发启动_Prompt_V1.0.md`
同属**历史产物**，按只追加原则保留（与 `TODO.md` §3.1 对 `docs/06_` 的处置同一先例）。
已在 `TODO.md` §2.3 登记 **K14** 作为其失效标记。

> ⚠️ 这与 `CHANGELOG` Session 004 · F1 记录的是**同一类问题**（文档漂移不会报错，
> 只会让人安静地做错事）。区别是这次**在开工核对阶段就被发现**，未造成返工。

### 五、📄 文档改动

| 文件 | 改动 |
|---|---|
| `TODO.md` | K4 → §2.4 已关闭（含裁决理由）· 新增 **K13** / **K14** · 新增 **D50** · 新增 **D51**（§3.2）· §1.1 与 §1.4 同步停止点状态 |
| `CURRENT_STATUS.md` | 抬头状态 · Phase 表 Phase 3 → **进行中** · §1 停止点块重写（明确「未清偿任何欠账」） |
| `CHANGELOG.md` | 本条目 |

**💻 代码改动：无。** 本轮 `lib/` 与 `test/` **零改动**。

### 六、实测结果（**当次真实输出**，2026-09-18）

```bash
cd /g/ai_agent/careerly
flutter analyze   →  No issues found!              (ran in 118.8s)
flutter test      →  58/58  All tests passed!
flutter run -d chrome --web-port=8765
                  →  启动成功，Chrome 已连上 debug service
```

> ✅ 与 `CURRENT_STATUS.md` §3.2 记录的 `58/58` / 零 issue **一致**
> （analyze 耗时较文档记录的 5.1s 长，属冷缓存，非差异）。

**App 已跑起来供视觉定稿**：`http://localhost:8765`
（`--web-browser-flag="--window-size=430,960"`，近似 Figma 的 390×844 手机框）。

### 七、明确未做

```text
❌ 未写任何代码（K4 裁决为「保持现状」，无代码可写）
❌ 未做 Android 真机验证（K3 未消除）
❌ 未实现 StatusBar（K13 未消除，D50 未裁决）
❌ 未清偿任何验收欠账（D51 未给出清偿方式）
❌ 未开工 Phase 2 批 3（未被授权）
```

### 八、⚠️ 视觉定稿结论的效力边界（重要）

本轮定稿在 **桌面 / Chrome** 上进行，**其结论只在以下范围内成立**：

| 可定 | 不可定 |
|---|---|
| 结构关系（玻璃条 232×60 / AI 球 62×62 / gap 10 / 滑动药丸位移） | **Android 材质观感** —— Chrome 的 `backdrop-filter` 与 Android Impeller 的 `BackdropFilter` 是两套实现 |
| 组件间相对位置、间距、层级 | **SafeArea** —— 手势条 / 挖孔（K3） |
| 转场时序的**逻辑**（时长 / 曲线是否按 Token 生效） | **高刷手感** —— 90/120Hz 下的实际观感（K3 / T12） |
| 三态（Loading / Empty / Error）可达性 | **排版** —— 中文字形由系统回退（**K1**），排版一栏**不能盖章** |

> ⛔ **桌面定稿的结论不得写成「视觉已定稿」。**
> 与 D26 的先例一致：**补齐 / 部分验证的结果不得盖章为设计定稿。**

### 九、未解决 / 下一步

| # | 事项 | 需要谁 |
|---|---|---|
| 1 | **欠账清偿方式未给出**（§8.1 的硬要求）—— 批 1 / 批 2 / Token 审计 / Input 四者挂账 | **产品侧** |
| 2 | **K1** 字体文件缺失 → 排版不能盖章 | **用户**（放入 `assets/fonts/`） |
| 3 | **K3** 无 Android 设备 → T1–T14 全表挂起 | **用户**（设备 / 模拟器） |
| 4 | **D50** 状态栏逐屏映射方式（3 个候选方案） | **产品侧 / 设计侧** |
| 5 | P3-1 / P3-2 / P3-3 / P3-7 的**桌面视觉定稿结论** | **产品侧**（App 已在 Chrome 上运行） |

**下一步**：等产品侧在 Chrome 上完成 P3-1 / P3-2 / P3-3 / P3-7 的视觉定稿，
回填结论后再判断 Phase 3 是否可收口。**不自动进入 Phase 4。**

---

## Session 008 — Token 依据审计 + `CareerlyInput` + Phase 2 执行方式调整

**日期**：2026-09-18
**阶段**：Phase 2 —— **执行方式调整** → Token 审计 → Input 交付
**结论**：✅ **审计完成 · `CareerlyInput` 已交付**（⚠️ **未验收**）
**关键变化**：Phase 2 **不再「一次性确定所有 Token」**，改为
**「先实现 → 实际视觉验证 → 再裁决 → Token 收敛」**

> 本轮由产品侧发起，核心诉求是**调整 Phase 2 的执行节奏**：
>
> > 「我目前无法在没有看到完整实际界面的情况下，对所有 Design Token 做最终视觉裁决。」
>
> 因此把 Token 明确分成「**已有依据**」与「**暂定**」两类，
> 暂定值集中登记、只写在 Token 层，等真实页面出来后再逐项收敛。
>
> ⛔ **本轮结束即停止，未进入批 3。**

---

### 一、执行方式的调整（本轮的总纲）

产品侧给出的 10 条原则，落到本项目后的具体形态：

| 原则 | 落地为 |
|---|---|
| 有 Figma / Spec 依据的 Token 直接实现 | 审计中逐项标注「✅ 有依据」，列出出处 |
| 无依据的用合理暂定值 | 标注 `⚠️ 暂定值 · 待视觉验证` |
| **暂定值必须集中管理** | `CURRENT_STATUS.md` **§3.6** 集中登记表 + `CLAUDE.md` §8.2 新增硬规则 |
| 暂定 ≠ 最终裁决 | 文档中一律写「暂定」，**不得**写成已定稿的规则 |
| Button / Card / Input / Chip / Navigation 先跑通 | **Input 是唯一缺失的** → 本轮实现 `CareerlyInput` |
| 看实际视觉后再调 Token | 暂定值**只写在 Token 层**，调整永远只改一处 |
| 不为「提前确定 Token」阻塞开发 | 审计只标注、**未改任何值**，全部开发照常推进 |
| 不新增大量规则文档 | 集中登记放进**已存在**的 `CURRENT_STATUS.md`，未新建文档 |
| 保持现有 Figma 作视觉参考 | **未重新设计任何视觉语言**，所有新值都从 Figma 取值 |

**本轮最重要的产出其实不是组件，而是这条边界**：

```text
有依据的  → 现在就定，改动它等于改设计真值
暂定的    → 先给合理值，等真实页面视觉验证后再裁决
```

在此之前，「哪些 Token 是确定的、哪些是猜的」**在文档中完全没有区分** ——
这正是「假数据被当成需求」的同类风险：**假的设计值会被当成设计规则**。

---

### 二、Token 依据审计（6 个文件逐个核查）

审计方法：逐个 Token 反查 Figma 源（`App.tsx` / `index.css` /
motion-spec），统计命中次数，区分「**逐位一致**」「**取值存在但选错档**」
「**完全无来源**」三档。

| 文件 | ✅ 有明确依据 | ⚠️ 暂定 |
|---|---|---|
| `app_colors.dart` | 绝大多数（多为 10 次以上命中）· `nav*` / `progress*` / `sheet*` 逐层还原 | 3 项**出现 0 次** |
| `app_typography.dart` | 6 个组件级角色 + 5 个 `input*` 角色全是原值 | **整节 Type Scale** 为归纳值 |
| `app_spacing.dart` | 9 个刻度值均有 Tailwind 对应 | **全部语义别名** |
| `app_radius.dart` | 6 个刻度值 + pill 均有出处 | 语义别名 |
| `app_shadows.dart` | `glass` / `glassLight` / `md` / `button` / `primaryButton` / `nav*` 逐位一致 | `sm` / `brand` / **`sheet`（取错源）** |
| `app_motion.dart` | 六档时长（spec §27 区间）+ 2 条真实曲线 | **`stagger` 落在区间之外** |

**审计中发现的 6 个最值得注意的结论**：

```text
① Figma 的 S 对象只有 12 个 Token —— 而 AppColors 有 ~50 个值。
   绝大多数 Flutter Token 不是 S 里的，而是从内联色值归纳的。

② Figma 里【根本没有 Type Scale】—— 是 22 个零散字号，
   且 text-[Npx] 与内联 fontSize 两套写法混用。
   出现最多的三档是 11 / 12 / 13px。
   行高与字距【完全没有来源】。

③ pageHorizontal 取 16，而 Figma 最主流的是 20
   （px-5 47 次 vs px-4 12 次）—— 【选错了档】。

④ AppMotion.stagger = 40ms，而 motion-spec 明写 50–80ms
   —— 【落在区间之外】。

⑤ AppShadows.sheet = md，而 md 的真值是【一张 Glass 信息卡】，
   不是 Bottom Sheet。Figma 里 Sheet 的阴影是【向上】的。
   —— 【取错了源】。

⑥ Figma 中【完全没有】:focus / ::placeholder / disabled: / ::selection
   规则 —— 占位符用的是浏览器默认色。
   这直接决定了 Input 组件的状态设计（见下）。
```

**处置**：**22 行暂定值全部只标注、未改值**。
改值属视觉决策，按 `CLAUDE.md` §0 第一禁令不得自决；
且在没有真实页面的情况下改了也无从验证。

> 复算命令（数字必须可被独立复算）：
> ```bash
> awk '/^#### ⚠️ 暂定值清单/,/^#### ✅ 已有明确依据/' \
>   docs/05_progress/CURRENT_STATUS.md | grep "^| " | wc -l
> # → 24（含表头与分隔行）→ 有效行 22
> ```

---

### 三、`CareerlyInput`（产品侧点名要求的第 5 个组件）

产品侧要求 **Button / Card / Input / Chip / Navigation** 五者先完成可运行实现，
**Input 是唯一尚不存在的**。

#### 从 Figma 查到的事实

Figma **不存在统一的 Input 组件**，实际有 **4 套互不相同的写法**：

| 变体 | Figma 位置 | 形态 | 圆角 | 字号 |
|---|---|---|---|---|
| `underline` | L510-541 | 透明底 + **仅下边框** `1.217px` | 无 | 16px |
| `boxed` | L1344-1390 | 半透明底 + 细边框 `1.5px` | `rounded-2xl`(16) | 13px |
| `filled` | L1673-1722 | 灰底 + **无边框** | `rounded-xl`(12) | 13px |
| `plain` | L2631-2644 | 完全无底色无边框 | 无 | — |

#### 关键决策：**有意不做收敛**

「4 套输入样式是否应该统一成 1 套」是**视觉方向的重大决策**。
本轮**原样保留 4 档**，透过 variant 参数暴露 ——
即 **Flutter 侧不代替设计侧做这个决定**，让页面先跑起来，
在真实页面上看到实际效果后再裁决（D45）。

这正是本轮执行方式的直接体现，而不是「偷懒不做」。

#### 另一项关键决策：绕开 Material 的输入主题

`CareerlyTheme._inputDecorationTheme` 是 **Phase 1 的 M3 兜底**，
用 `filled: true` + `OutlineInputBorder` ——
而 **Figma 中没有任何输入框使用这套样式**（真实输入框都是透明/半透明底 + 细边框）。

因此 `CareerlyInput` 用 `InputDecoration.collapsed` **彻底绕开它**（D44）。
若沿用 M3 主题，4 种真实形态会**全部与之冲突**。

#### 四态的诚实处理

| 态 | 处置 |
|---|---|
| Disabled | ✅ 实现 —— 文字色 / 填充色 / `TextField.enabled` **三者都变** |
| Error | ✅ 实现 —— `errorText` 抢占 `helperText` 的位置 |
| Loading | ❌ **显式声明不适用** —— 输入框自身没有「加载中」语义 |
| Retry | ❌ **显式声明不适用** —— 重试的主体是提交动作 |

**`Loading` / `Retry` 不是遗漏，是不硬塞。**
为「凑齐四态」往输入框里塞一个转圈，会造出**没有任何 Figma 依据的形态**，
且与 `CLAUDE.md` §5.5 的立法本意（业务页面必须有真实可达的状态）相反。

**并且有意未把错误态边框改成红色** ——
Figma 没有任何输入框错误态，改成红色会让它看起来像设计定稿。
**未知的保持中性，只有有出处的（禁用态）才真的换色。**

---

### 四、本轮自查发现的 3 个实现问题

| # | 问题 | 修复 |
|---|---|---|
| 1 | `TextField.maxLength` 会让 **Material 在输入框右下角自绘计数器**，与 Figma 的「标题行右端」计数器位置冲突，且样式无依据 | 改为 `LengthLimitingTextInputFormatter` 限长，计数器由组件在标题行自绘 |
| 2 | 若沿用 `TextField.maxLength`，测试里 `find.text('0 / 5000')` 会命中**两个** widget | 同上 —— 从结构上消除重复，而不是在测试里绕开 |
| 3 | 测试里写 `BoxDecoration.border` 的类型为 `BorderGeometry` | 实际是 `BoxBorder`；且 `left` / `right` 只存在于 `Border`，需向下转型 |

> **第 3 条是一个值得记录的教训**：`flutter analyze` **在写完测试文件之前**跑过，
> 所以它没有报错；真正暴露错误的是 `flutter test` 的编译步骤。
> 这与 K2（go_router）同源 —— **`analyze` 不是完整的编译检查**。

---

### 五、新增待裁决项：D35–D49（**15 条**）

| # | 内容 | 类别 |
|---|---|---|
| D35 | `AppShadows.sheet` 语义别名很可能取错源 | 技术实现 |
| D36 | `AppMotion.stagger` 落在 motion-spec 区间之外 | 视觉/交互 |
| D37 | `AppSpacing.pageHorizontal` 取 16，Figma 主流是 20 | 视觉/交互 |
| D38 | `AppTypography.numeric.fontSize = 32` 不在 Figma 字号集合内 | 视觉/交互 |
| D39 | `AppRadius.input` 与 Figma 输入框圆角不统一（16 / 12） | 视觉/交互 |
| D40 | `AppTypography` Type Scale 整节为归纳值（含行高 / 字距） | 视觉/交互 |
| D41 | `AppSpacing` / `AppRadius` 语义别名整节为归纳值 | 技术实现 |
| D42 | `AppShadows.sm` / `brand` 无逐位一致的来源 | 视觉/交互 |
| D43 | `AppColors` 中 3 个色值出现 0 次 | 视觉/交互 |
| D44 | `careerly_theme._inputDecorationTheme` 没有 Figma 依据 | 技术实现 |
| D45 | `CareerlyInput` 的 4 档变体是否应收敛（含命名待确认） | **产品冲突** |
| D46 | `CareerlyInput` 的聚焦 / 占位 / 错误态取值均为补齐 | 视觉/交互 |
| D47 | `inputLabel` 未施加 Figma 声明的 `text-transform: uppercase` | 视觉/交互 |
| D48 | `CareerlyInput` 中两处无 Figma 出处的几何值 | 技术实现 |
| D49 | `AppMotion` 的四条曲线是归纳值（spec 只给文字描述） | 视觉/交互 |

**登记时自查发现的两项执行漏洞**（都已修）：

```text
① `app_typography.dart` 的注释里写了字面量 `TODO.md`
   → 会触发 Dart 的 `todo` lint
   → 改为「docs/05_progress/ 待裁决清单 §3.1」

② `AppMotion` 的四条归纳曲线【有标记但没有编号】
   → 违反 §5.4 双向登记规则
   → 补登 D49，并在代码里补上编号引用
```

> 第 ② 条正是 §5.4 那条规则要防的东西：
> **标记活在注释里，编号活在文档里，两边对不上就会静默沉淀。**
>
> 修完之后用 grep 复验：`lib/` 下**没有**不带编号的争议标记，
> 且**没有**残留的字面量 `TODO`。

---

### 六、📄 修改的文件

**双向登记规则已执行**：所有代码注释里的争议标记都带编号，
所有编号条目都能在代码里找到对应（`DEVELOPMENT_WORKFLOW.md` §5.4）。

| 文件 | 改动 |
|---|---|
| `lib/design_system/components/careerly_input.dart` | 🆕 **新建** —— `CareerlyInput` + 4 档 variant + 2 档 tone |
| `test/phase2_input_test.dart` | 🆕 **新建** —— 16 项测试 |
| `lib/design_system/tokens/app_colors.dart` | ➕ 8 个 `input*` 色值；⚠️ 3 处暂定标注 + D43 |
| `lib/design_system/tokens/app_typography.dart` | ➕ 5 个 `input*` 角色；⚠️ Type Scale 整节标注 + D40 / D38 / D47 |
| `lib/design_system/tokens/app_spacing.dart` | ⚠️ 语义别名整节标注 + Figma 频次表 + D37 / D41 |
| `lib/design_system/tokens/app_radius.dart` | ⚠️ 语义别名标注 + 频次表 + D39 / D41 |
| `lib/design_system/tokens/app_shadows.dart` | ⚠️ `sm` / `brand` / `sheet` / `navigationBar` 标注 + D35 / D42 |
| `lib/design_system/tokens/app_motion.dart` | ⚠️ `stagger` + 四条归纳曲线标注 + D36 |
| `lib/design_system/components/components.dart` | ➕ 导出 `careerly_input.dart` |
| `docs/05_progress/CURRENT_STATUS.md` | ➕ **§3.6 暂定 Token 集中登记表**；更新 §1 / §2 / §3.2–§3.5 / §4 |
| `docs/05_progress/TODO.md` | ➕ D35–D48；更新 §1.1 欠账台账 / §1.2 交付结果 |
| `CLAUDE.md` | ➕ **§8.2 暂定值规则**；§8.4 ② 加 `CareerlyInput`；§12 状态 |

**未改动的**：`app_typography.dart` 的 Type Scale **取值**、
所有暂定 Token 的**数值**、任何批 1 / 批 2 组件的代码。

---

### 七、测试结果

```bash
cd /g/ai_agent/careerly
flutter analyze   →  No issues found!                (5.1s)
flutter test      →  58/58 All tests passed!
```

| 文件 | 用例 |
|---|---|
| `test/design_system_test.dart` | 15 |
| `test/phase2_batch2_test.dart` | 17 |
| `test/phase2_input_test.dart` | **16**（本轮新增） |
| `test/widget_test.dart` | 10 |
| **合计** | **58** |

复算命令（数字必须可被独立复算）：

```bash
grep -c "testWidgets(\|test(" test/*.dart
# → 15 / 17 / 16 / 10 = 58
```

---

### 八、新发现

1. **Figma 的 `S` 对象只有 12 个 Token**，而 `AppColors` 有约 50 个值 ——
   说明绝大多数颜色 Token 是**从内联色值归纳**的，不是设计侧显式定义的。
   这是「归纳值需视觉验证」这一结论的根源。
2. **Figma 没有 Type Scale** —— 22 个零散字号，无阶梯、无层级命名。
3. **Figma 没有任何输入框的状态定义**（`:focus` / `::placeholder` /
   `disabled:` / `::selection` 全部缺失），只有 `caretColor` 有定义。
4. **`AppShadows.sheet` 取错了源** —— 指向一张 Glass 信息卡而非 Bottom Sheet，
   且方向相反（Figma 的 Sheet 阴影向上）。
5. **`flutter analyze` 不覆盖「新写的文件」** ——
   本轮测试文件的类型错误由 `flutter test` 的编译步骤暴露。
   与 K2 同源，**`analyze` 不是完整的编译检查**。

---

### 九、未解决

**新增**：D35–D48（14 条，见 `TODO.md` §3.1）。其中 **D37 最可能需要调整** ——
`pageHorizontal` 影响**所有页面的左右留白**。

**延续**：

```text
K1   字体缺失        → 两批 + Input 的排版都不能盖章
K3   无 Android 设备  → T1–T14 平台验证仍全部未做
K10  导航栏与 GlassSurface 重复实现
K11  Toast 在设计侧无视觉实体
K12  Glass 的第三处组合
```

**验收欠账**：批 1 + 批 2 合并验收**仍未进行**，
且本轮又添了 Token 审计与 `CareerlyInput` —— **四者一并验收**。

---

### 十、下一步

```text
⏹ 停在停止点 —— 等待验收。
```

**本轮已经做完产品侧要求的三件事**：

```text
✅ 检查 Token 哪些有依据、哪些属暂定   → 18 项暂定值集中登记
✅ 继续 Phase 2 开发（Input 组件）      → 4 档 variant + 两态 + 16 项测试
✅ 运行 flutter analyze 与 flutter test → 干净 + 58/58
```

**建议的下一步（需产品侧决定）**：

```text
① 验收：批 1 + 批 2 + Token 审计 + CareerlyInput 一并过一遍
② 若同意：提供一个能看到真实页面的方式（真机 / 模拟器 / 构建 APK）
   —— 因为「暂定 Token 收敛」这个循环【必须有真实页面才能转起来】
③ 裁决 D45：4 档输入变体是否收敛（这是最影响后续页面的一个）
```

> ⛔ **不得自行进入批 3**（`ScoreIndicator` / `AIMessageBubble` /
> 导航栏 Glass 统一）。前置仍是「**批 1 + 批 2 合并验收通过**」。

---

## Session 007 — 批 2 交付（3 个反馈层组件）+ 6 条新待裁决项

**日期**：2026-09-18
**阶段**：Phase 2 —— 批 2 开发 → **交付，停在停止点**
**结论**：✅ **批 2 已交付**（⚠️ **未验收**，与批 1 合并验收）

> 本轮从 Session 006 的「批 2 遇阻」继续。三项产品侧裁决
> （D26 / D27 / D28）解除了阻塞，批 2 得以交付。
>
> ⛔ **本轮结束即停止，未进入批 3。**

---

### 一、三项产品侧裁决（D26 / D27 / D28）

详见 `TODO.md` §3.2 的留档条目。摘要：

| # | 决策 | 后果 |
|---|---|---|
| **D26** | `CareerlyToast` 视觉用**已有 Token** 补齐 | 阻塞解除；但**补齐值不是设计值**，验收时不得盖章 |
| **D27** | `CareerlyBottomSheet` = **参数化 shell + 变体预设** | 3 档 tone 属**分析归纳**，待确认归纳方式本身 |
| **D28** | `CareerlyAnalysisProgress` **移出批 2 → Phase 6** | 批 2 组件数 **4 → 3** |

> ⚠️ **D26 的边界**：Token 里**没有**「停留时长」「轻提示动画档」这类值，
> 因此 `CareerlyToast` 的 `2500ms` / `160ms` **不在 D26 的授权范围内** ——
> 它们是新造的数字，另行登记为 **D32 / D33**。

---

### 二、Glass 非均匀圆角 —— 一处**既有代码的错误前提**

写 `CareerlyBottomSheet` 时发现：`glass_edge_painter.dart` 的注释写

> 「圆角半径。要求**四角一致**——Figma 的所有 Glass 面都是均匀圆角。」

**这个前提是错的。** Figma 的 BottomSheet 变体 E / F 用的正是
`S.glass` + `rounded-t-3xl`（**仅顶部圆角**）。

**处置**：

```text
✅ 旁路 GlassSurface，直接组合 GlassFilters.blur() + glassFill / glassBorder
✅ 不改 GlassSurface / GlassEdgePainter 的既有代码（属批 1，未验收）
⚠️ 代价：项目里出现第三处 Glass 组合 → 登记为 K12
⚠️ 遗留：那句错误的前提**仍在源码中**
```

**为什么不「顺手」改掉那句注释**：批 2 的开发边界是
「**只新增、不改既有实现**」（`TODO.md` §1.1）。
一句注释的改动看似无害，但它是**批 1 未验收代码**的一部分，
且改它会开一个「批 2 可以碰批 1」的先例。→ 登记为 **D30**，等裁决。

> 📌 **侥幸之处**：`S.glass` **本身没有 inset 高光**（`GlassSurface` 文档已载明），
> 所以不需要 `GlassEdgePainter` —— 只需填充 + 1px 描边 + blur，
> 这三样对**非均匀圆角**都成立。否则批 2 会被硬性卡住。

---

### 三、`AppRadius.sheet` 是**欠定义**的

同样是 BottomSheet 引出的：`AppRadius.sheet`（批 1 建立）注释写
「Bottom Sheet 顶部圆角」，值是 **28**。

但 Figma 的 6 处变体里**只有 C / D 用 28**，A / B / E / F 用的是 **24**。
该 Token 因而**把两种取值收敛成了一档**，名字却是通用的。

**处置**：`CareerlyBottomSheet` **不改该 Token**，
改为按 tone 分别取 `AppRadius.xxl`（28）/ `AppRadius.xl`（24）。
→ 登记为 **D29**。

---

### 四、批 2 交付内容

#### 💻 新增组件（3 个）

| 组件 | 真值来源 | 关键实现点 |
|---|---|---|
| `CareerlyProgress` | Figma `OnboardingProgress`（`App.tsx` L428-457） | 还原 `left:-4px` + `calc(pct% + 4px)`；入场 0 → value；**确定型** |
| `CareerlyBottomSheet` | Figma **6 处内联变体**（L2082 / L2298 / L4431 / L4595 / L5056 / L5098） | 参数化 shell + 3 档 tone；scrim 自绘 blur；仅顶部圆角 |
| `CareerlyToast` | Figma **只有动画骨架**（`index.css` 关键帧，**无元素引用**） | 视觉按 D26 用已有 Token 补齐；`liveRegion`；不拦截点击 |

#### 🐞 开发中自查出的 3 个问题

| # | 问题 | 修复 |
|---|---|---|
| 1 | `Positioned.fill` 被 `FadeTransition` 隔断 → **运行时报错**（`Positioned` 必须是 `Stack` 的直接子节点） | 把 `Positioned.fill` 提到 `Stack` 层，`_SheetScrim` 改为不定位的纯内容 |
| 2 | 重复实现了 `GlassFilters.blur()` —— 该工厂方法**已存在** | 改用既有方法，删掉自写的 `ui.ImageFilter.blur` |
| 3 | 自造 `_specFor` → `_specForTone` 两层跳转，其中一层类型名笔误 | 合并为一层 `_specFor` |

> 📌 问题 2 值得记：**批 2 的组件要组合 Glass 基元时，
> 应先读 `glass/` 目录，而不是照着 `GlassSurface` 的用法重写一遍。**
> 这与 K10 / K12 是同一类漂移。

#### 💻 Token 补齐（`app_colors.dart`）

```text
progressTrack / progressGradient（172deg，⚠️ 非 brandGradient 的 135deg）
sheetScrimConfirm / sheetScrimAction / sheetScrimOverlay
sheetFillHigh / sheetFillMid
sheetHandleLight / sheetHandleDark
```

#### 💻 测试

新增 `test/phase2_batch2_test.dart`（**17** 用例）。
断言取向：**能真的发现回归**，不是「渲染不抛异常」。

钉死的三件易被「顺手简化」的事：

```text
1. 进度填充用 progressGradient，不是 brandGradient（172deg vs 135deg）
2. 进度填充左端有 -4px 外扩（Figma 固有细节，不是笔误）
3. BottomSheet 面板只有顶部圆角
```

> 🐞 **测试自身的 3 个坑**（写测试时踩到，记下来避免重蹈）：
>
> ```text
> ① Positioned.fill 的 left 是 0.0，不是 null
>    → 用 left != null 区分轨道与填充条会命中 2 个
>    → 改用 width != null（只有填充条显式给了 width）
> ② addTearDown(handle.dispose) 跑在 framework 的
>    「SemanticsHandle 是否已释放」校验之后 → 必须在测试体内 dispose
> ③ 同一 testWidgets 内循环 pumpWidget 不会重置 Navigator
>    → 上一轮打开的弹层还挂着，第二次点击被遮挡
>    → 给 MaterialApp 一个 UniqueKey 强制重建
> ```

---

### 五、批 2 新增的待裁决项（D29–D34）

**6 条**，全部登记在 `TODO.md` §3.1。按 `DEVELOPMENT_WORKFLOW.md` §5.4
的**双向登记规则**逐条核对过 —— 代码里每一处 `待裁决` / `偏差` / `未定义`
标记都有对应的编号条目，**无反例**。

| # | 事项 | 类别 |
|---|---|---|
| **D29** | `AppRadius.sheet` 只覆盖 28，未覆盖 24 | 【技术实现差异】 |
| **D30** | `GlassSurface` 不支持非均匀圆角 → BottomSheet 旁路 | 【技术实现差异】 |
| **D31** | `CareerlyProgress` 统一取 550ms（Figma 为 500 / 600） | 【视觉/交互差异】 |
| **D32** | `CareerlyToast` 停留时长 `2500ms` 设计侧未定义 | 【视觉/交互差异】 |
| **D33** | `CareerlyToast` 退出动画 180ms → 取 160ms；是否新增时长档 | 【视觉/交互差异】 |
| **D34** | `CareerlyBottomSheet` 高度上限 `0.9` 为工程兜底；下滑关闭未做 | 【技术实现差异】 |

> 📌 **D32 / D33 全部源自「Token 覆盖不到」** ——
> D26 授权的是「用**已有** Token 补齐」，而这两个值在 Token 里根本不存在。
> **授权范围**与**实际需要补的值**之间有缺口，这不是失误，
> 是「补齐」这条路本身的天花板。设计侧补视觉时应优先解决这两条。

---

### 六、新增 Known Issue

| # | 问题 | 处理时机 |
|---|---|---|
| **K12** | `CareerlyBottomSheet` 成为**第三处 Glass 组合**（K10 是第二处） | 批 3，与 K10 一并 |
| **K11** | （状态变更）从「🔴 阻塞批 2 交付」降级为「🟠 阻塞视觉盖章」 | 设计侧补视觉 |

---

### 七、停止点 —— 本轮结束

```text
批 2 已交付 → 输出报告 → ⏹ 停止
```

⛔ **不进入批 3。** 理由：

```text
1. CLAUDE.md §0「禁止自动进入下一个 Phase / 批次」
2. 批 1→批 2 的豁免（D20）是**具名、一次性**的，不覆盖批 2→批 3
3. 批 1 与批 2 都**未验收**，欠账不能继续滚
4. 批 3 的前置是「批 1 + 批 2 合并验收通过」（TODO.md §1.2）
```

---

### 📄 修改文件

**文档**

```text
CLAUDE.md                            §8.4 组件状态（3 项 ⛔ → ✅）· §8.4③ 规划 ·
                                     §12 当前状态（批 1+2 已交付 · 停止点改为合并验收）
docs/05_progress/TODO.md             §1.1 批 2 交付状态 · §1.2 批次表 ·
                                     §2.1 K11 降级 · §2.2 新增 K12 ·
                                     §3.1 新增 D29–D34 · §3.2 留档 D26–D28
docs/05_progress/CURRENT_STATUS.md   §1 现状 · §2 · §2.1 · §3.2 测试数字 ·
                                     §3.3 代码规模 · §3.4 基础设施 · §3.5 · §4 批 2
docs/05_progress/CHANGELOG.md        本条目
```

**代码**

```text
lib/design_system/components/careerly_progress.dart      新增
lib/design_system/components/careerly_bottom_sheet.dart  新增
lib/design_system/components/careerly_toast.dart         新增
lib/design_system/components/components.dart             +3 export
lib/design_system/tokens/app_colors.dart                 +9 个 Token
test/phase2_batch2_test.dart                             新增（17 用例）
```

> ℹ️ **`CLAUDE.md` 的改动全是「状态事实同步」，未改任何规则。**
> §8.4 的组件状态表写着这三个组件「⛔ 未实现」，交付后已成为**事实错误** ——
> 而该文件每次会话都会自动加载，留着会误导后续 Session。

---

### 🧪 测试结果

```bash
cd /g/ai_agent/careerly
flutter analyze   →  No issues found!                (5.2s)
flutter test      →  42/42 All tests passed!
```

**数字可独立复算**（这是 Session 006 §七那次「测了却记错」的教训）：

```bash
ls -R lib | grep -c "\.dart$"                              # → 67
for f in test/*.dart; do grep -cE "^\s+(testWidgets|test)\(" "$f"; done
# → 15 (design_system) / 17 (phase2_batch2) / 10 (widget) = 42
```

> ⚠️ **`cd` 到仓库根再跑。** Bash 工具的工作目录在调用之间**会保持**；
> 本轮之前的 Session 曾因此分析了错误的目录。
> **`flutter analyze` 抓不到包编译错误**（K2 的教训），只有 `test` / `build` 才暴露。

---

### 🔍 新发现

| # | 发现 |
|---|---|
| 1 | `GlassEdgePainter` 的「四角一致」前提**是错的**（见 §二） |
| 2 | `AppRadius.sheet` **欠定义**，只覆盖 28（见 §三） |
| 3 | `GlassFilters.blur()` **早已存在**，我差点重复实现（见 §四） |
| 4 | **D26 的授权有天花板** —— Token 覆盖不到的值仍需单独裁决（见 §五） |
| 5 | `Positioned.fill` 的 `left` 是 `0.0` 而非 `null`（测试坑） |

---

### ❓ 未解决问题

```text
⚠️ 批 1 + 批 2 均未验收 —— 欠账仍在（TODO.md §1.1）
⚠️ K1 字体缺失 —— 两批的排版都不能盖章
⚠️ K12 第三处 Glass 组合（批 3）
🔴 K11 Toast 无设计视觉 —— 阻塞视觉盖章，不阻塞交付
⏳ D29–D34 六条待裁决
⏸ Android 真机测试 T1–T14 仍未执行（K3）
```

---

### ▶ 下一步

**等待产品侧裁决。** 本轮**不做任何推进**。

待裁决清单（按优先级）：

```text
1. 安排批 1 + 批 2 合并验收（TODO.md §1.1）
2. D29–D34 六条待裁决项（TODO.md §3.1）
3. K1 字体 —— 阻塞一切排版结论
4. K11 Toast 视觉 —— 设计侧补充
```

---

## Session 006 — 批 1 跳过验收（授权）+ K6 落地 + 批 2 规格核查

**日期**：2026-09-18
**阶段**：Phase 2 —— 批 1 **跳过验收** → 批 2 开发中
**结论**：⚠️ **PASS WITH NOTES** —— 记录机制建立，但**批 2 遇阻**（`CareerlyToast` 无视觉规格）

> 本轮开局处于 `TODO.md` §1.1 的停止点（批 1 验收）。
> 产品侧在知情前提下**授权跳过批 1 验收**，直接开工批 2 —— 见 **D20**。
> 随后落地 K6，并对批 2 三个组件做 Figma 规格核查，
> **核查结果改变了批 2 的可执行范围**。

---

### 一、D20 —— 跳过批 1 验收的具名授权

#### 背景

`CLAUDE.md` §0 三条最高禁令之一：**禁止自动进入下一个 Phase / 批次**。
`DEVELOPMENT_WORKFLOW.md` §3.1：每个批次结束 → 输出报告 → 停止 → 等待验收。

AI 侧**不得自行**作出「跳过验收」的判断。本轮由产品侧在**知情前提下明确选择**
「跳过验收，直接开工批 2」，并确认批 1 视为通过。

#### 执行方式 —— 授权 ≠ 验收

```text
✅ 记为本轮的一次具名豁免
❌ 不记为「批 1 已验收通过」
```

**批 1 的真实验收状态 = ⚠️ 未验收。**

#### 配套欠账处理

```text
欠账约定：批 2 交付时，批 1 + 批 2 合并验收。
```

**为什么不是永久跳过**（依据 `DEVELOPMENT_WORKFLOW.md` §3.2）：

未验收的假设会被当成已确认的基础。批 2 的组件本就建在批 1 之上
（`CareerlyBottomSheet` 预期复用 `GlassSurface`），两者无法真正分开验收。

> 📌 已同步写入：
> `TODO.md` §1.1（欠账台账）· §3.2（D20 留档）
> `CURRENT_STATUS.md` §1 / §2 / §2.1
> `DEVELOPMENT_WORKFLOW.md` §8.1（停止点豁免规则）

---

### 二、D24 —— 停止点只能由产品侧豁免，且必须具名留档（**新规则**）

D20 暴露出一个**规则缺口**：原 `DEVELOPMENT_WORKFLOW.md` §8 列了停止点，
但**没有写「停止点能否被豁免、由谁豁免、豁免后怎么记」**。

**新增规则**（`DEVELOPMENT_WORKFLOW.md` §8.1），豁免必须满足**全部三条**：

```text
① 由产品侧在知情前提下明确选择（AI 不得提议「要不要跳过」并自行采纳）
② 豁免内容具名 —— 豁免的是什么、豁免到哪一步
③ 写入 TODO.md §3.2 已裁决留档 + CHANGELOG 对应 Session
```

**并且——被跳过的验收不会消失，只会变成欠账。**
豁免时必须同时给出**欠账的清偿方式**。

---

### 三、K6 落地 —— `flutter_localizations`

```text
💻  pubspec.yaml              新增 flutter_localizations (sdk: flutter)
💻  lib/app/app.dart          接线 delegates + supportedLocales
```

**实测确认**：`meta` 仍锁定 **1.18.0** —— K2（go_router 必须 <18.0.0）的约束**未被影响**。

#### D23 —— 实现选择：`supportedLocales` 只登记 `zh_CN`（**待裁决**）

K6 只裁决了「引入」，**未裁决语言登记范围**。落地时做了如下选择：

```dart
supportedLocales: const <Locale>[Locale('zh', 'CN')],
```

**理由**：Careerly 目前只提供中文 UI。只登记 `zh_CN` 时，无论设备语言是什么，
Flutter 都解析到唯一候选，Material 内建组件（日期选择器 / 长按菜单 / Tooltip）保持中文。

**影响**：未来若要支持多语言，此处必须改为多语言列表 + 语言切换入口。
**⚠️ 未经产品侧裁决**，已登记 `TODO.md` §3.1 · D23。

---

### 四、D19 —— 补登一笔「只活在代码注释里」的争议

核查中发现：`careerly_button.dart:198-205` 记录着
「Figma 按钮 `transition 120ms`，代码取 `AppMotion.micro`（100ms），**偏差 20ms**，
待产品侧裁决」——**但 `TODO.md` §3.1 没有这条**。

```text
⚠️ 这正是「争议只写在注释里 → 静默沉淀成已确认」的典型漏洞。
   验收时没人会去翻组件源码。
```

**处置**：补登为 **D19**，并建立**双向登记规则**（见下）。

---

### 五、D25 —— 争议项必须双向登记（**新规则**）

```text
代码注释里的 待裁决 / 待确认 / 偏差 标记
        ↕  必须一一对应，缺一即违规
TODO.md §3.1 的带编号条目
```

**理由**：`TODO.md` §3.1 是**查争议的唯一入口**。规则已写入
`DEVELOPMENT_WORKFLOW.md` §5.4。

**本轮同时登记的新争议项**：

| # | 争议项 | 分类 |
|---|---|---|
| **D19** | `CareerlyButton` 按压时长偏差 20ms（补登） | 【视觉/交互差异】 |
| **D21** | `CareerlyAsyncStateView._Loading` 与 `CareerlyProgress` 职责重叠 | 【技术实现差异】 |
| **D22** | Material `SnackBar` / `bottomSheet` 主题与自绘组件重叠 | 【技术实现差异】 |
| **D23** | K6 的 `supportedLocales` 只登记 `zh_CN` | 【技术实现差异】 |

> D21 / D22 **本轮不动** —— 属跨组件重构，不在批 2 边界内（与 K10 同类）。
> **批 2 只新增、不改既有实现。**

---

### 六、⚠️ 批 2 规格核查 —— **结果改变了批 2 的可执行范围**

对 `docs/Careerly App Interface Design (Copy)/src/App.tsx`（5310 行）
与 6 份 `pasted_text/*.md` 做了规格提取。结论：

#### ✅ `CareerlyProgress` —— 可实现，规格明确

Figma `OnboardingProgress`（`App.tsx` L428-457）给出了完整真值：

| 项 | Figma 真值 |
|---|---|
| 轨道高 | `7`，圆角 `9999` |
| 轨道色 | `rgba(79,126,245,0.12)` |
| 填充渐变 | `linear-gradient(172deg, #4F7EF5 → #A77BE6)` |
| 填充偏移 | `left: -4px`，宽 `calc(pct% + 4px)` |
| 动画 | `transition: all 500ms` |

> 📌 另有**三种更复杂的形态**（`AnalysisProcessing` 圆环 / `OnParsing` 圆环 / 各种数据条）。
> 它们是**页面级复合体**，不是 design-system 组件 —— 归属需裁决。

#### ⚠️ `CareerlyBottomSheet` —— 可实现，但需**归纳**（Figma 无统一组件）

Figma 里**没有统一的 BottomSheet 组件**，而是 **6 处内联变体**（A–F），
差异维度是可枚举的：

| 维度 | 取值 |
|---|---|
| 顶部圆角 | `24px`（A/B/E/F） vs `28px`（C/D） |
| 把手宽 | `36`（A/B）· `40`（C/D/E）· `48`（F），高统一 `4` |
| 面板背景 | 纯白（A/B）· `rgba(255,255,255,0.95)`（C）· `0.88`（D）· `S.glass`（E/F） |
| scrim | `rgba(0,0,0,0.28)+blur3`（确认类）· `0.40+blur6`（操作类）· `0.45+blur4`（Dialog 型） |

**共性**：绝对定位铺满 + scrim + 底部面板 + 顶部圆角 + 拖拽把手。

> ⚠️ **Figma 未定义变体枚举**。上述归类是**分析归纳**，
> 不是设计侧给出的正式枚举 —— 实现时需标明哪些是归纳。

#### ❌ `CareerlyToast` —— **无法实现：Figma 中没有视觉实体**

**这是本轮最重要的发现。**

```text
App.tsx 中不存在任何 Toast 组件或使用点。
```

仅能提取到**动画骨架**（`src/index.css` L225-235）：

| 项 | 值 |
|---|---|
| 进入 | `opacity 0→1` + `translateY(8px)→0`，**160ms ease-out** |
| 退出 | `opacity 1→0` + `translateY(0)→8px`，**180ms ease-in** |
| 定位 | 底部，自下 `+8px` 上移（`motion-spec` L823-849） |
| 用途限定 | 保存成功 / 复制成功 / 删除成功 / 简历更新成功 |

⚠️ **以下全部未找到**，且 `.toast-in` / `.toast-out` 两个 CSS 类
**无任何元素引用**（定义了但从未使用）：

```text
❌ 容器样式（背景色 / 圆角 / 内边距 / 宽度）
❌ 图标、文字字号 / 字重 / 颜色
❌ 成功 / 错误变体枚举
❌ 停留时长
```

**依据 `CLAUDE.md` §7「不编造产品数据」与 §0「禁止自行修改产品规则」——
不得凭空补全 Toast 的视觉。**

**正确动作**：停下，报告，等裁决。
这不是「Figma 画不出的运行时行为」（那是 `DEVELOPMENT_WORKFLOW.md` §5.3 说的
「Flutter 负责实现」），而是**设计侧从未产出过这个组件的视觉**。

---

### 七、🐞 修正：测试数字失真（24 → **25**）

```bash
flutter test                                        →  +25  All tests passed!
flutter test test/design_system_test.dart           →  +15  All tests passed!
flutter test test/widget_test.dart                  →  +10  All tests passed!
```

| 文件 | 文档记录 | **实际** |
|---|---|---|
| `test/design_system_test.dart` | 14 | **15** |
| `test/widget_test.dart` | 10 | 10 |
| **合计** | ~~24~~ | **25** |

`CHANGELOG.md` Session 004 / Session 005 **都写着「24/24」**，
且 Session 005 明确声称「已重跑确认」—— **两轮的记录都是错的**。

**根因**：`design_system_test.dart` 的实际用例数比记录多 1。
不是「没测」，而是**测了却记错** —— 这与 F2（Session 004）是**同一个失效模式的变体**：

```text
F2：文档写着 10/10，实际 6/4        —— 结论过期
本轮：文档写着 24/24，实际 25/25     —— 数字记错
共同点：测试数字没有以「可复核的方式」产出
```

**对策建议**（待产品侧确认是否采纳）：
状态文档引用测试数字时，**一并记录产出该数字的命令**，
而不是只写结论 —— 让数字可被下一个人独立复算。

---

### 修改文件

```text
💻  修改  pubspec.yaml                                      （K6：flutter_localizations）
💻  修改  lib/app/app.dart                                  （K6：delegates + supportedLocales）

📄  修改  TODO.md                （§1.1 欠账台账 / §1.2 K6 / §2.1 / §2.4 / §3.1 新增 D19·D21·D22·D23 / §3.2 新增 D20）
📄  修改  CURRENT_STATUS.md      （§1 / §2 / §2.1 状态变更）
📄  修改  DEVELOPMENT_WORKFLOW.md（§5.4 双向登记 / §8.1 豁免规则）
📄  修改  CHANGELOG.md           （本条目）
```

**本 Session 未新增任何组件代码** —— 批 2 的实现被 `CareerlyToast` 的规格缺口阻断。

---

### 测试结果

**当次实测**（非沿用）：

```bash
flutter analyze   →  No issues found!                (62.8s)
flutter test      →  25/25 All tests passed!
```

> ⚠️ 见第七节 —— 本轮**修正**了此前文档中的 `24/24`。

---

### 新发现

1. 🔴 **`CareerlyToast` 在设计侧不存在视觉实体** —— 只有动画骨架。
   批 2 的四个交付项里，这一项**无法在不编造的前提下实现**。
2. ⚠️ **「争议只在注释里」是系统性风险**，不是偶发 ——
   本轮即捞出一笔（D19）。已用双向登记规则封堵。
3. ⚠️ **测试数字被记错了两轮**，且两轮都自称「已重跑」——
   说明「重跑」本身不足以保证数字正确，需要**留下可复算的命令**。
4. 📌 **Figma 的 BottomSheet 没有统一组件**，是 6 处内联变体。
   这与「Figma Make 是静态原型」的判断一致 —— 组件抽象尚未发生。

---

### 未解决问题

| # | 问题 | 状态 |
|---|---|---|
| **—** | 🔴 **`CareerlyToast` 无视觉规格** | ⚠️ **待产品侧裁决**（阻塞批 2 交付） |
| K1 | Noto Sans SC 字体文件缺失 | ⏸ 等用户放入 `assets/fonts/` |
| K3 | 无 Android 设备 | ⏸ 阻塞 T1–T14 |
| **D19** | `CareerlyButton` 时长偏差 20ms | ⚠️ 待裁决（【视觉/交互差异】） |
| **D21** | `_Loading` 与 `CareerlyProgress` 重叠 | ⚠️ 待裁决（本轮不动） |
| **D22** | Material 主题与自绘组件重叠 | ⚠️ 待裁决（本轮不动） |
| **D23** | `supportedLocales` 只登记 `zh_CN` | ⚠️ 待裁决 |
| **—** | 批 2 的 `CareerlyAnalysisProgress` / 数据条归属 | ⚠️ 待裁决（页面级复合体 vs 组件） |
| D16 | Disabled 态具体取值 | ⚠️ 待裁决（自 Session 004 起挂起） |

---

### 下一步（**停止点**）

```text
⛔ 停在这里 —— 批 2 的 CareerlyToast 遇到规格缺口，不得编造。
```

**批 2 的三个分支**（待裁决后继续）：

```text
① CareerlyProgress              —— 规格完整，可立即开工
② CareerlyBottomSheet           —— 需确认「变体归纳」方式后开工
③ CareerlyToast                 —— 🔴 阻塞，等设计侧补视觉
```

---

## Session 005 — 建立进度文档系统 + 组件命名规范裁决

**日期**：2026-09-18
**阶段**：Phase 2 Design System —— 批 1 等待验收（**本 Session 未动代码**）
**结论**：✅ 完成 —— 项目上下文系统就位，命名规范裁决落地

> 本轮是**产品侧主动要求的基础设施建设**，不是 Phase 2 的推进。
> 目的：让后续每一步开发都有一个稳定的基准，避免再次出现 Session 004 那类文档漂移。

### 本次完成内容

1. **建立 `docs/05_progress/` 进度文档系统**（三分：状态 / 计划 / 决策史）
2. **迁移并删除旧文件**（`PROJECT_STATE.md` 拆分；`DEV_LOG.md` 改名）
3. **新建 `DEVELOPMENT_WORKFLOW.md`**（根目录）
4. **裁决并落地组件命名规范**（D17）

**⚠️ 本 Session 零代码改动。**

---

### 一、文档系统重构

#### 目标结构

```text
careerly/
├── CLAUDE.md                      规则 —— 什么能做 / 不能做 / 听谁的   （每次会话自动加载）
├── DEVELOPMENT_WORKFLOW.md        流程 —— 每次开发怎么做
└── docs/
    └── 05_progress/               ← 补上了 docs/ 编号体系缺的那一格（01 04 _ 06 07）
        ├── CURRENT_STATUS.md      状态 —— 现在在哪
        ├── TODO.md                计划 —— 接下来做什么 / 什么挡路 / 什么等人拍板
        └── CHANGELOG.md           决策史 —— 为什么这么做（本文件）
```

#### 迁移映射

| 旧 | 新 | 方式 |
|---|---|---|
| `docs/PROJECT_STATE.md`（25 KB，12 章） | `CURRENT_STATUS.md` + `TODO.md` | **拆分**后删除 |
| `docs/DEV_LOG.md`（32 KB） | `docs/05_progress/CHANGELOG.md` | **改名**，历史 Session 001–004 一字未动 |
| `CLAUDE.md` §9 命令 / §11 协作方式 | `DEVELOPMENT_WORKFLOW.md` | **展开**；CLAUDE.md 保留速查 + 指针 |

#### 拆分规则

```text
「现在在哪」        → CURRENT_STATUS
「接下来做什么」「什么挡路」「什么等人拍板」 → TODO
「为什么这么决定」  → CHANGELOG
```

`PROJECT_STATE.md` 的 Known Issues 与待裁决项**全部并入 `TODO.md`**，分三区：

```text
一、接下来做什么
二、卡住的事（2.1 真正阻塞 / 2.2 已排期 / 2.3 已处理 / 2.4 已关闭）
三、等产品侧裁决（3.1 待裁决 / 3.2 已裁决留档）
```

> **为什么把「已知问题」并进 TODO 而不是独立成文件**：
> 每次开工要回答的是「做什么」+「什么挡在它前面」—— 这是**同一个决策**。
> 拆到两个文件会让「做什么」和「什么挡路」脱节。

---

#### D17 — 文档职责分离：一个事实只有一个出处

```text
CLAUDE.md              只写规则，不写进度
CURRENT_STATUS.md      只写现状，不写决策理由
TODO.md                只写计划与阻塞
CHANGELOG.md           只追加，不覆盖
```

**为什么**：Session 004 的两处严重问题（F1 文档断环 / F2 基线失真）**根因相同** ——
同一个事实被两个地方描述，然后其中一个先变了。

**操作化**（已写入 `DEVELOPMENT_WORKFLOW.md` §0）：
写之前先问「这件事归哪个文件」，**不要让两个文件描述同一件事**。

**验证**：迁移后已 grep 全项目，`PROJECT_STATE` / `DEV_LOG` 的残留引用
**全部在 `CHANGELOG.md` 内部** —— 那是历史条目在说当时的文件名，正确且已在头部注明。

---

#### 🐞 顺带修复：`CLAUDE.md` §12 状态过期

```text
原：Current → Android Real Device Testing  ／ Phase 2 → NOT STARTED
实：Phase 2 批 1 已交付，等待验收
```

**这正是「规则文件里混进进度」的典型症状** —— 规则文件谁都不该为进度去改它，
所以进度写在里面必然过期。§12 已改为指针 + 一句当前状态。

---

### 二、D18 — 组件命名规范（产品侧裁决）

#### 原问题（【技术实现差异】）

`CLAUDE.md` §8.4 的组件清单与 Phase 2 批 1 实际建成的组件对不上，
且 §8.4 自身与 §6.4「统一前缀 `Careerly`」**互相矛盾**。

| §8.4 原写的 | 实际建成的 |
|---|---|
| `GlassSurface / GlassCard` | `GlassSurface` / **`CareerlyCard`** |
| `PrimaryButton / SecondaryButton` | **`CareerlyButton`**（含 variant） |
| `EmptyState / LoadingState / ErrorState` | **`CareerlyAsyncStateView`** |

#### 裁决：以实际代码为准，**不修改已实现的组件命名**

按**层级**分两类 —— 判定标准是「**有没有 Careerly 业务语义**」，不是「好不好看」：

| 层 | `Careerly` 前缀 | 判定标准 | 例 |
|---|---|---|---|
| **Design Primitive** | ❌ **不加** | 纯视觉 / 基础设施，不含业务语义，可被任何项目复用 | `GlassSurface` · `GlassEdgePainter` · `GlassFilters` |
| **产品级共享组件** | ✅ **必须加** | 承载 Careerly 的产品交互语义 | `CareerlyCard` · `CareerlyButton` · `CareerlyChip` · `CareerlyPressFeedback` · `CareerlyAsyncStateView` |

#### 三条「不拆分」决策

```text
CareerlyButton            用 variant 区分 primary / secondary
                          ❌ 不创建 PrimaryButton / SecondaryButton 两个组件

CareerlyAsyncStateView    统一承载 loading / empty / error 等异步状态
                          ❌ 不拆成 EmptyState / LoadingState / ErrorState
                            —— 除非后续出现明确的独立复用需求

GlassSurface              保持基础视觉 primitive 定位
                          ❌ 不改名为 CareerlyGlassSurface
```

> **原则：变体用参数，不用新组件。**
> 只有当两个形态的**行为**真的不同（而不只是样式不同）时，才拆成两个组件。
> 这条原则对后续所有共享组件生效，不限于本轮裁决的三个。

#### ⚠️ 遗留（**待批 2 / 批 3 确认，不预先改名**）

> 🔧 **2026-09-18 更正**：本节初稿称下列名称「都是 Baseline 中的原始名称」，
> **该归属是错的** —— 未经核实即写下。
> `docs/07_...Baseline` §7.5 实际只规划了 **8 项**，
> 其中**不含** `AnalysisProgress` / `ScoreIndicator` / `AIMessageBubble`。
> 已按 Baseline 实际内容重新归类，并同步修正 `CLAUDE.md` §8.4 与 `TODO.md`。

**Baseline §7.5 实际包含的**（未实现部分）：

```text
CareerlyProgress          ✅ 确在 Baseline
CareerlyBottomSheet       ✅ 确在 Baseline
CareerlyToast             ✅ 确在 Baseline
```

**不在 Baseline、属项目自有规划的**：

```text
CareerlyAnalysisProgress  ← 已按 D18 补前缀（原写 AnalysisProgress）
ScoreIndicator            ← ⚠️ 命名未复核
AIMessageBubble           ← ⚠️ 命名未复核
```

`ScoreIndicator` 与 `AIMessageBubble` 都承载 Careerly 业务语义
（匹配度 0–100 / AI 对话），按 D18 **大概率应加前缀** ——
但**裁决只覆盖已实现组件**，故**不预先改名**，留待实现时确认。

---

### 修改文件

```text
📄  新建  DEVELOPMENT_WORKFLOW.md
📄  新建  docs/05_progress/CURRENT_STATUS.md
📄  新建  docs/05_progress/TODO.md
📄  改名  docs/DEV_LOG.md  →  docs/05_progress/CHANGELOG.md
📄  删除  docs/PROJECT_STATE.md                          （内容已拆分迁移）
📄  修改  CLAUDE.md                                      （头部指针 / §3.2 / §6.4 / §8.4 / §9 / §11 / §12）
```

**本 Session 零 Dart 文件改动。**

---

### 测试结果

**当次实测**（虽然未改代码，仍按 `DEVELOPMENT_WORKFLOW.md` §1.3 的要求重跑）：

```bash
flutter analyze   →  No issues found!        (4.1s)
flutter test      →  24/24 All tests passed!
```

> 数字与 Session 004 一致 —— 因为**确实没有代码变动**。
> 重跑的意义不是「数字会变」，而是**确认它没变**。

---

### 新发现

1. **「规则文件里写状态」必然过期** —— `CLAUDE.md` §12 就是活例。
   规则文件的修改频率应该极低；一旦混进高频变化的内容，它就会稳定地过期。
2. **矛盾常常有两半** —— §8.4 与实际代码矛盾，§6.4 又和 §8.4 矛盾。
   只修用户点名的那一处，会留下另一半继续矛盾。
   → 已一并处理，并在报告中显式说明（见下）。

---

### 未解决问题

| # | 问题 | 状态 |
|---|---|---|
| K1 | Noto Sans SC 字体文件缺失 | ⏸ 等用户放入 `assets/fonts/` |
| K3 | 无 Android 设备 | ⏸ 阻塞 T1–T14 |
| K6 | `flutter_localizations` 未落地 pubspec | ⏸ 已批准，待写入 |
| D16 | Disabled 态具体取值 | ⚠️ **待产品侧裁决**（【视觉/交互差异】） |
| — | `ScoreIndicator` / `AIMessageBubble` 命名未复核 | 批 2 / 批 3 确认 |
| — | 工作区**未提交** | 本 Session 未收到提交指令 |

---

### 下一步（**停止点**）

```text
⛔ 停在这里，等待下一步指令。
```

**当前两个并列的待办**（均等指令）：

```text
① Phase 2 批 1 验收
② Phase 2 批 2 开工（前置：K6 写入 pubspec）
```

> 本 Session **扩大了文档基础设施**，但**未扩大 Phase 2 的代码 Batch**。
> 批 1 的交付边界与验收清单不变。

---

## Session 004 — 修复文档断环与失效基线 + Phase 2 批 1 交付

**日期**：2026-09-17
**阶段**：Phase 2 Design System —— **批 1 已交付，等待验收**
**结论**：⚠️ 发现并修复两处严重问题（文档断环 / 基线失效），随后完成批 1

> 本轮开局的「读取操作记忆」暴露了一个**比预期严重**的情况：
> 记忆文件与实际代码、文档三者互相矛盾。
> 本轮先**修复一致性**，再开始 Phase 2 —— 否则会在错误的地基上盖楼。

### 一、修复：三个问题（**先修地基，再开工**）

#### 🐞 F1 — 文档断环：导航栏被 Figma-faithful 重写，但**没有任何 Session 记录**

`lib/design_system/components/careerly_navigation_bar.dart`（856 行）
的实际实现与 `PROJECT_STATE.md` 的描述**完全不符**：

| 文档原记录 | 代码实际 |
|---|---|
| 「3 个 Tab 各带中文文字标签」 | 3 个 Tab **纯图标，无文字**（Figma `App.tsx` L235–334 确实是 `<Icon active={active}/>`） |
| 「AI 是导航栏内的第 4 个入口」 | AI 是**条外独立浮球** 62×62，`✦` + `AI` 小标签 |
| 未提及玻璃实现细节 | 内含 `_GlassEdgePainter` / `_GlassFilters` / `_NavHighlights` 三个私有类 |

**判定**：**代码是对的，文档是旧的** —— 已对照 Figma 源文件逐行核实。
这说明**导航栏曾被重写为 Figma-faithful，但那次重写没有留下任何 DEV_LOG 记录**。
Record 链在此断裂，导致下一个 Session（本轮）一开始读到的是过时描述。

**修复**：`PROJECT_STATE.md` 的 Q1 / Q3 / Q4 / K5 / §7 T3 全部按**代码 + Figma 现状**重写，
并标注「⚠️ 原记录与代码不符，2026-09-17 复核更正」。
**本 Session 即为那次缺失重写的补记。**

---

#### 🐞 F2 — 基线失效：文档声称 10/10，**实测 6/4**

```bash
flutter test   →   +6 -4   ❌  4 个测试失败
```

而 `PROJECT_STATE.md` §4.2 当时写着 **「10/10 All tests passed!」**。

**根因**：F1 的导航栏重写同步改变了 Tab 的 widget 结构，
但 `test/widget_test.dart` **没有一起更新** —— 它仍在断言
`find.text('分析')`（Tab 文字）和 `find.byIcon(Icons.auto_awesome_outlined)`（AI 图标）。

**判定**：**实现是对的，测试是陈旧的**（同 F1 的核实结论）。

**修复**：重写 4 个失效断言，并新增 `tapNavDestination()` 辅助函数。
过程中又踩到两个坑（见下）。

---

#### 🐞 F3 — `find.bySemanticsLabel` 找不到 `Semantics`

```text
The finder "Found 0 widgets with a semantics label named "AI" ..." could not find any matching widgets.
```

**根因**：`Semantics` 默认 `container: false` —— 它只是**给父节点附加标注**，
**不创建自己的语义节点**。`find.bySemanticsLabel` 读的是
`renderObject.debugSemantics`，对这类节点恒为 `null`。

**修复**：改为直接匹配 widget 属性：

```dart
find.byWidgetPredicate(
  (Widget w) => w is Semantics && w.properties.label == label,
)
```

顺带删掉了因此变得多余的 `tester.ensureSemantics()` / `addTearDown`。

---

#### 🐞 F4 — 断言范围过宽：`find.text('首页')` 命中了**页面标题**

修好 F3 后 9/10 通过，剩 1 个失败：

```text
Expected: no matching candidates
  Actual: Found 1 widget with text "首页": [Text("首页", ... size: 22.0, weight: 700 ...)]
```

那是页面 AppBar 的标题（`AppTypography.title`）—— **页面标题本来就该叫「首页」**。
断言「导航栏里没有文字」时**没有限定范围**，把页面标题也算进去了。

**修复**：用 `find.descendant(of: find.byType(CareerlyNavigationBar), ...)` 收窄范围。

---

#### 📌 F1–F4 的共同教训

```text
状态类结论必须每次重新实测。
```

「10/10 通过」这句话在写下时是真的，**在下一轮就可能变成假的**。
文档里的测试结论若没有注明**验证时间与验证范围**，就会被后人当成仍然成立的事实。

→ 已据此修正 `PROJECT_STATE.md` §4.2，明确写出「曾一度为 6/4」这个事实。

---

### 二、Phase 2 批 1 交付

用户裁决的节奏：**分批交付，每批暂停验收**。

```text
批 1 = 地基     GlassSurface · CareerlyButton · CareerlyCard · CareerlyChip   ← 本轮
批 2 = 反馈层   Progress / AnalysisProgress · BottomSheet · Toast
批 3 = 领域     ScoreIndicator · AIMessageBubble · 导航栏 Glass 统一
```

#### 本次完成内容

1. **`GlassSurface` + 玻璃基元** —— 把导航栏里**私有的** `_GlassEdgePainter` /
   `_GlassFilters` **泛化**为公共基元（`components/glass/`）。
2. **`CareerlyButton`**（primary / secondary，含 Disabled 态）
3. **`CareerlyCard`**（glass / glassLight / brand / surface 四种变体）
4. **`CareerlyChip`**（8 种语义色调 × 2 种尺寸）
5. **`CareerlyPressFeedback`** —— 按压反馈，供卡片与后续组件复用
6. **Token 补齐**：语义色底衬 · 组件级 Typography · 主按钮投影 · 禁用文字色
7. **14 个新测试用例**（`test/design_system_test.dart`）

#### 重要决策

##### D13 — 泛化，而不是另起一套：`GlassSurface` 复用导航栏的私有实现

K5 原本记录为「Flutter `BoxShadow` 不支持 `inset`，方案未定」。

实际读代码后发现：**方案早就有了** —— 导航栏里的 `_GlassEdgePainter`
就是在用「裁剪到 RRect + 画内侧色带」模拟 inset 高光，`_GlassFilters`
也已经把 CSS `backdrop-filter: blur(24px)` 正确映射成
`ImageFilter.blur(sigmaX: 24, sigmaY: 24)`
（CSS `blur(Npx)` 的参数是**高斯标准差**，不是直径 —— 直接对应 sigma）。

**决定**：**泛化为公共类，不重新发明**。
K5 由此从「阻塞项」降级为「低风险重构」。

---

##### D14 — 导航栏**暂不切换**到公共 `GlassSurface`（→ K10）

批 1 只做「泛化」，**不做「切换调用方」**。

**为什么**：`careerly_navigation_bar.dart` 是 856 行、品牌识别度最高、
最复杂的单文件。把改动扩散进去会让批 1 的验收边界变得模糊 ——
「验收 4 个组件」会变成「验收 4 个组件 + 一个 856 行文件的重构」。

**代价**：当前存在**两份功能重叠的 Glass 实现**。
已登记为 **K10**，计划在批 3 合并时删除私有副本。

**风险（未处理）**：两份实现若各自演化会产生**视觉漂移**。
在批 3 完成前，改任何一边都必须**同步检查另一边**。

---

##### D15 — 组件里不内建「业务判断」

两个具体的克制：

| 遇到的东西 | 为什么没做 |
|---|---|
| Figma `TrendBadge`（按 delta 正负自动选绿/灰/红） | 那是**业务判断**不是视觉规则。`CareerlyChip` 只提供色调，由调用方按 delta 选 |
| Figma brand 卡片的投影（每张卡片都不同：`0 8px 24px @0.25` / `0 16px 40px @0.28` / `0 20px 48px @0.28`） | 尚未归纳成 Token。**不擅自固化**，改为暴露 `shadow` 参数 + 文档注明 |

**依据**：CLAUDE.md §0「禁止自行修改产品规则」。

---

##### D16 — Disabled 态是 Flutter 补齐的，不是 Figma 定义的（**标记待确认**）

Figma 的 `PrimaryBtn` 在不可用时**只是把文字调灰**，没有定义背景/边框。

**Flutter 的处理**：用**已有 Token**（`disabledSurface` / `textDisabled`）补齐，
保证四态齐备（CLAUDE.md §5.5 的硬要求）。

**⚠️ 分类：【视觉/交互差异】——待产品侧确认。**
这是**补齐**，不是**发明**，但它的**具体取值**未经产品侧裁决。

---

### 修改文件

```text
💻  新建  lib/design_system/components/glass/glass_edge_painter.dart
💻  新建  lib/design_system/components/glass/glass_filters.dart
💻  新建  lib/design_system/components/glass/glass_surface.dart
💻  新建  lib/design_system/components/glass/glass.dart
💻  新建  lib/design_system/components/careerly_button.dart
💻  新建  lib/design_system/components/careerly_card.dart
💻  新建  lib/design_system/components/careerly_chip.dart
💻  新建  lib/design_system/components/careerly_press_feedback.dart
💻  新建  test/design_system_test.dart

💻  修改  lib/design_system/components/components.dart        （导出 + 批次进度）
💻  修改  lib/design_system/tokens/app_colors.dart           （7 个语义底衬 + textDisabled）
💻  修改  lib/design_system/tokens/app_shadows.dart          （primaryButton）
💻  修改  lib/design_system/tokens/app_typography.dart       （4 个组件级角色）
💻  修改  test/widget_test.dart                              （修复 4 个失效断言）

📄  修改  docs/PROJECT_STATE.md                              （F1/F2 更正 + K10 + §11）
📄  修改  docs/DEV_LOG.md                                    （本文件）
```

### 测试结果

**实测输出**（本轮真实执行，非沿用旧结论）：

```bash
flutter analyze   →  No issues found!        (4.1s)
flutter test      →  24/24 All tests passed!
```

测试构成：

```text
test/design_system_test.dart   14 个   Phase 2 批 1 组件 + Token 断言
test/widget_test.dart          10 个   Phase 1 App Shell（已修复）
```

### 新发现

1. **文档链会断，而且断得很安静** —— F1 的重写没有记录，
   后果是一整个后续 Session 读到错误的页面结构描述。
   **对策**：凡改动 `lib/design_system/` 或页面结构，**必须**同步 DEV_LOG。
2. **测试结论有保质期** —— F2 的「10/10」在写下时是真的。
   没有附验证时间的测试结论会被当成永久事实。
3. **`Semantics` 的坑值得记住** —— 默认 `container: false` 时
   `find.bySemanticsLabel` 永远找不到它。这不是 Flutter bug，是语义树的设计。

### 未解决问题

| # | 问题 | 状态 |
|---|---|---|
| K1 | **Noto Sans SC 字体文件缺失** | ⏸ 用户将放入 `assets/fonts/`；**未到位**。到位后需注册 `pubspec.yaml` 并实测 |
| K6 | `flutter_localizations` | ✅ 用户已批准「现在引入」，但**尚未写入 `pubspec.yaml`** |
| K10 | 导航栏与 `GlassSurface` 的**重复实现** | 🟡 有意保留，批 3 合并 |
| — | **D16 Disabled 态取值** | ⚠️ **待产品侧确认**（【视觉/交互差异】） |
| — | Android 真机测试 T1–T14 | ⏸ **推迟，未取消** |
| — | 工作区**未提交** | 本轮未收到提交指令，`git` 保持 dirty |

### 下一步（**停止点**）

```text
⛔ 停在这里，等待批 1 验收结论。
❌ 不得自动进入批 2（CLAUDE.md §0 / §11）。
```

**批 2 前置项**（详见 `PROJECT_STATE.md` §11.2）：
K1 字体**不阻塞**批 2 开工（反馈层组件的几何与状态机不依赖中文字形），
但它**阻塞任何「排版已定稿」的结论**。

---

## Session 003 — 持久化开发上下文机制 + 进入 Android 真机测试

**日期**：2026-09-17
**阶段**：Session Handoff → **Android 真机测试**（Phase 2 未启动）
**结论**：✅ 完成 —— 三个持久化上下文文件建立，开发暂停，等待真机测试指令

### 本次完成内容

1. **Session Handoff** —— 阅读项目状态，总结本次会话实际完成的工作
2. **建立持久化开发上下文机制**（3 个文件，跨会话可恢复）
3. **重写 `CLAUDE.md`** —— 从「脚手架说明书」升级为「Careerly 长期开发规则」
4. **建立 `docs/PROJECT_STATE.md`** —— 实时状态快照
5. **建立 `docs/DEV_LOG.md`** —— 本文件
6. **状态切换**：Phase 1 → PASS WITH NOTES，当前阶段 → **Android 真机测试**
7. **输出真机测试清单 T1–T14**（`docs/PROJECT_STATE.md` §7）

> ⚠️ 本轮**未修改任何产品逻辑、未新增任何页面、未进入 Phase 2**。
> 改动**全部是文档**。

### 重要决策

#### D8 — 三个上下文文件，职责严格分离

```text
CLAUDE.md               →  规则：「什么能做、什么不能做、听谁的」   （自动加载，稳定）
docs/PROJECT_STATE.md   →  状态：「现在在哪、还坏着什么」          （频繁更新，快照）
docs/DEV_LOG.md         →  过程：「当时为什么这么决定」            （只追加，不覆盖）
```

**为什么分开**：三者的**变更频率**差一个数量级。
混在一起会导致「规则被状态淹没」——每次状态更新都要动规则文件，规则就不再稳定。
分开后，`CLAUDE.md` 只在**产品规则真的变了**的时候才改。

---

#### D9 — 旧 `CLAUDE.md` 已过期，必须重写（**新发现**）

原 `CLAUDE.md` 与实际项目状态**已严重不符**：

| 原文档写的 | 实际状态 |
|---|---|
| 「fresh default Flutter scaffold，`main.dart` 还是 counter demo」 | ❌ 56 个 Dart 文件，App Shell 已建成 |
| 「只有 `cupertino_icons` 和 `flutter_lints`」 | ❌ 已有 `go_router ^17.0.0` + `provider ^6.1.5+1` |
| 目录写 `lib/core/theme/`、`lib/state/`、`lib/shared/` | ❌ 实际是 `lib/design_system/tokens/`、`lib/app/providers.dart` |
| 未提 `docs/07_...Baseline` | ❌ Baseline 是歧义仲裁第一入口 |

**决定**：**整体重写**，并把三条最高优先级禁令提到 **§0**（最前），
因为它们是「每次会话最先要看到的」。

---

#### D10 — 记录产品侧已确认项：AI 是正式一级 Tab

产品侧本轮明确了：

```text
AI 是正式一级 Tab      ✅
AI 可以特殊视觉表现     ✅
```

**记录意义**：这**排除**了此前 `PROJECT_STATE.md` 中 Q2 的猜测
（「AI 是否是独立于导航栏的浮动元素」）。
AI 是导航的**正式成员**，其特殊性属**表现层**，**不改变层级**。

**仍未定案的**：AI 入口的**具体视觉形态**（是否浮起 / 尺寸 / 是否带文字标签）
—— 归为 Q1，Phase 3 视觉定稿时按 Figma 确定，**不阻塞真机测试**。

> `docs/PROJECT_STATE.md` §9 已同步更新：Q2 标记为 ✅ 已确认。

---

#### D11 — 真机测试期间的改动边界

为防止「测着测着就顺手开发了」，本轮预先划定：

**允许**：

```text
✅ 修复真机上暴露的、属于 Phase 1 范围的平台适配问题（SafeArea / 布局溢出）
```

**禁止**：

```text
❌ 修改任何产品规则
❌ 新增任何页面
❌ 开始 Phase 2 的组件开发
❌ 因为真机上看到了不完美就顺手改视觉
```

**为什么**：真机测试的目的是**验证**，不是**改进**。
把「发现的问题」和「解决方案」分开——先记录全部问题，再统一处置。

---

#### D12 — 明确 T8 是「预期会失败」的验证项，不是 bug

真机测试清单中的 **T8（中文渲染）** 预期会**回退到系统字体**，
因为 Noto Sans SC 字体文件缺失（K1）。

**决定**：**不修**。本轮只**记录实际回退表现**，作为补齐字体后的对照基线。

**为什么**：这是 Phase 1 brief §11.2 的**明确要求**
（「不用其他中文字体偷偷替代产品决策」）。
把它当成 bug 去修 = 用替代字体掩盖了真实的字体缺口。

### 修改文件

```text
📄  重写  CLAUDE.md                    （过期 → 长期开发规则）
📄  新建  docs/PROJECT_STATE.md
📄  新建  docs/DEV_LOG.md              （本文件）
```

**本轮零代码改动。**

### 测试结果

本轮**未运行测试**（未改任何代码）。

Phase 1 的测试结论仍然有效：

```bash
flutter analyze            →  No issues found!           (5.2s)
flutter test               →  10/10 All tests passed!
flutter build apk --debug  →  ✅ app-debug.apk 75,419,271 bytes + .sha1
flutter devices            →  Windows / Chrome / Edge —— ⚠️ 无 Android 设备
```

**待执行**：真机测试清单 T1–T14（`docs/PROJECT_STATE.md` §7）。

### 新发现

1. **旧 `CLAUDE.md` 已过期**（见 D9）—— 这是一个**真实风险**：
   它的内容会让未来的会话误判项目状态。
   已通过重写消除。

2. **项目尚未纳入 Git（K8）** —— 真机测试即将开始，
   而**所有测试期间的改动都没有版本保护**。
   一旦需要回退，没有基线可退。

   > ⚠️ 建议在开始真机测试**之前** `git init` 并提交一个 Phase 1 基线。
   > **此项需用户确认**，未自行执行。

3. **真机测试的可测范围有限** —— 当前**没有任何业务页面**，
   能验证的只有 App Shell 的平台适配行为。
   这是 Phase 1 的收尾验证，**不是功能验收**。

### 未解决问题

| # | 问题 | 状态 |
|---|---|---|
| K1 | 🔴 Noto Sans SC 字体文件缺失 | **真机测试中将直接暴露**，本轮只记录不修 |
| K2 | 🟡 go_router 锁 17.x | 已处理，需注意升级风险 |
| K3 | 🟡 无 Android 设备 | **当前阶段正在消除** |
| K4 | 🟡 Android Back 用默认行为 | 本轮只记录，Phase 3 处理 |
| K5 | 🟡 Figma inset 阴影无 Flutter 方案 | Phase 2 处理 |
| K6 | 🟡 未引入 `flutter_localizations` | Phase 2 前补 |
| K7 | 🟡 `applicationId` 仍是 `com.example.careerly` | 发版前处理 |
| K8 | 🟡 **未纳入 Git** | ⚠️ **建议测试前解决（需确认）** |
| K9 | 🟡 `CareerlyPlaceholderNote` 是临时产物 | Phase 2 起逐页删除 |
| Q1 | AI 入口的具体视觉形态 | 待确认，不阻塞真机测试 |
| Q3 | AI 导航项是否需文字标签 | 待确认，低风险 |
| O4–O7 | Phase 0 开放项 | 未裁决，阻塞 Phase 8 / 9 |

### 下一步

```text
▶  Android 真机测试（按 T1–T14 清单）
▶  记录每项实际观测结果
▶  重点记录 T8（中文字体回退）作为 K1 对照基线
⏸  测试完成后输出报告，等待指令
⏸  Phase 2 未启动，不得自行进入
```

---

## Session 002 — Phase 1：Flutter 工程骨架

**日期**：2026-09-17
**阶段**：Phase 1（空项目 / 工程基础架构）
**结论**：✅ **PASS WITH NOTES** — 基础设施全部建成，业务功能零实现，已停止，等待验收

### 目标

把 Phase 0 已锁定的产品规则，转换成可维护的 Flutter 工程底座。
**只做基础设施**，不实现任何业务功能（brief §七 / §八 明令禁止）。

### 本次做了什么

| # | 动作 | 说明 |
|---|---|---|
| 1 | 环境与项目状态检查 | Flutter 3.44.0 / Dart 3.12.0；确认仓库是**默认脚手架**，无旧 Careerly 代码残留 |
| 2 | 建立目录结构 | `app/` `core/` `design_system/` `data/` `features/` |
| 3 | 建立 6 个 Design Token | Colors / Typography / Spacing / Radius / Shadows / Motion |
| 4 | 建立 `CareerlyTheme` | 未被 Material 3 默认样式主导 |
| 5 | 建立 Router | `createAppRouter()`，4 条一级 route，`StatefulShellRoute.indexedStack` |
| 6 | 建立 App Shell | `CareerlyShell` + **自绘** `CareerlyNavigationBar` |
| 7 | 建立 State 基础 | `AsyncState<T>` / `AsyncStateNotifier<T>` / 5 个 Provider |
| 8 | 建立 Repository + Mock | 4 个接口 + 4 个 Mock 实现 + `MockConfig` |
| 9 | 建立 Error 基础设施 | `AppError` sealed + 6 子类 + `ErrorHandler` |
| 10 | 建立 Motion 基础设施 | `AppMotion` 六档 |
| 11 | 建立四态渲染组件 | `CareerlyAsyncStateView<T>` |
| 12 | 重写 `pubspec.yaml` / `test/widget_test.dart` | 依赖收敛 + 10 个冒烟测试 |
| 13 | 输出 `docs/phase_1_report.md` | 22 节完整报告 |

### 关键决策

#### D1 — 背景渐变只在应用根部绘制一次

**背景**：最初每个页面各自绘制 `AppColors.backgroundGradient`。
**问题**：App Shell 与页面各自绘制同一渐变，两者尺寸不同 →
**在底部导航栏上沿出现一条肉眼可见的颜色断层**。
**决定**：`CareerlyScaffold` 改为**透明 Scaffold**，
渐变统一由 `CareerlyApp` 的 `MaterialApp.router.builder` 在**最外层包一个 `DecoratedBox`** 绘制一次。
**理由**：渐变是全屏资源，不是页面资源。每个页面自己画 = 每个页面画错一次。

> 💻 `lib/design_system/components/careerly_scaffold.dart`（重写）
> 💻 `lib/app/app.dart`

---

#### D2 — `go_router` 锁在 `^17.0.0`（**必须 <18.0.0**）

**问题**：`flutter pub add go_router` 解析到 **18.0.1**，随后 `flutter test` 编译失败：

```text
Error: Undefined name 'awaitNotRequired'.
  material_ui-1.3.0/lib/src/date_picker.dart:224
  cupertino_ui-1.1.0/lib/src/route.dart:1347
```

**根因**：go_router 18.x 依赖 `material_ui` / `cupertino_ui`，
这两个包要求 `meta >= 1.19`（`@awaitNotRequired`），
而当前 Flutter SDK 把 `meta` 锁死在 **1.18.0**。

⚠️ **`flutter analyze` 抓不到这个错**——它不编译包源码。
只有 `flutter test` / `flutter build` 才暴露。这是一个**很容易被漏掉的坑**。

**决定**：约束 `go_router: ^17.0.0`，实际解析 17.0.0。
`material_ui` / `cupertino_ui` / `intl` / `flutter_localizations` 从依赖树中消失。
**在 `pubspec.yaml` 中写下原因注释**，供未来升级时判断。

> 💻 `pubspec.yaml`

---

#### D3 — Mock 数据一律返回**空**，不编造产品数据

**决定**：所有 `MockXRepository` 返回**空集合 / 空状态**，
不编造「匹配度 86%」「Alex Chen」「某公司高级工程师」这类**看起来像真的**的假数据。

**为什么**：
1. 假数据一旦进入代码，会被误当成产品需求实现；
2. 空数据能让 **Empty 态真实可见**，而不是永远看不到；
3. 真实感由设计稿提供，不由 Mock 提供。

**例外**：`MockAnalysisRepository.fetchQuota()` 返回 `QuotaState.free`（3 次）。
**这不是编造数据，是复述一条已锁定的产品规则**（Baseline §5 / PRD）。

**配套**：`MockConfig` 提供 `latency = 600ms` 与 `failNext` 开关，
让 **Loading / Error 态实际可达**，不是理论上存在。

> 💻 `lib/data/mock/mock_config.dart` 及 4 个 `mock_*.dart`

---

#### D4 — 页面占位用显式组件，且标记为「Phase 2 起逐页删除」

Phase 1 禁止实现业务页面，但四个一级 route 必须可渲染。
建立 `CareerlyPlaceholderNote` 显式标注「这里现在是什么、将来是什么、Phase 几做」。

**这不是产品 UI，是脚手架**，因此：
- 文件名带 `placeholder`，不做成通用组件；
- 在报告与 `PROJECT_STATE.md`（K9）中明确记录：**Phase 2 起必须逐页删除**。

> 💻 `lib/design_system/components/careerly_placeholder_note.dart`

---

#### D5 — 不引入 `PopScope`（Android Back 交给 Phase 3）

「非首个 Tab 按返回先回首页」需要在 Shell 层加 `PopScope`，
但这会**连带阻断分支内二级页面的 pop**，需要更仔细的分支级处理。

Baseline §8 把「Android back」明确划归 **Phase 3** 验证，
Phase 1 因此**不引入**，当前行为是 go_router 默认：
分支内有二级页面 → 先 pop；分支根页面 → 退出 App。

**这条是「有意不做」，不是「漏做」。**

> 📄 `docs/PROJECT_STATE.md` Known Issue K4

---

#### D6 — 不自建 `AuthProvider` / `CareerProvider` / `AIProvider`

工程规范列出了 6 个 Provider。
Phase 1 只注册**当前真实被使用**的 5 个（App / Home / Analysis / Resume / Growth）。

**理由**：brief §二十一 要求「不为『以后可能用到』提前安装/创建」。
提前建 3 个空的 Provider 只会制造**读起来像需求、实际是死代码**的东西。
它们在对应 Phase 建立即可。

> 💻 `lib/app/providers.dart`

---

#### D7 — Token 数值以 Figma Make 实际视觉为准

按 Baseline **决策 8**：Visual Token 以当前 Figma Make 实际视觉为准，
Flutter **重新归纳**成 Token，而不是照抄 CSS。

具体处理：
- 背景渐变 CSS `128.67deg` → 方向向量 `(sin θ, -cos θ)` = `(0.781, 0.625)`
  → Flutter `Alignment(-0.78, -0.63) → (0.78, 0.63)`，三个停靠点 `0.0774 / 0.4577 / 0.9227` 保留
- `AppMotion` 六档时长对齐 motion-spec §27 的区间，并在测试中断言区间

> 💻 `lib/design_system/tokens/app_colors.dart` · `app_motion.dart`
> 💻 `test/widget_test.dart`（Token 区间断言）

---

### 🐞 问题与修复

| # | 问题 | 处理 |
|---|---|---|
| 1 | `Undefined class 'BuildContext'` ×4（`providers.dart`） | 补 `import 'package:flutter/widgets.dart'` |
| 2 | `The imported package 'meta' isn't a dependency` ×8 | 用 `package:flutter/foundation.dart` 替换 `package:meta/meta.dart`，**不新增依赖** |
| 3 | `job.dart`：`company` 不可为 null | 改为 `this.company = ''` 并修正文档注释 |
| 4 | `TextTheme` 无 `.body` getter | 改用 `.bodyLarge` |
| 5 | 若干未使用的 import | 删除 |
| 6 | **go_router 18.x 编译失败**（见 D2） | 锁定 `^17.0.0` |
| 7 | 测试 `find.text('AI')` 找不到控件 | AI 是特殊入口、**无文字标签**；改为按图标 `Icons.auto_awesome_outlined` 定位 |

修复后：`flutter analyze` → **No issues found!**

### 验证结果

```bash
flutter analyze            →  No issues found!           (5.2s)
flutter test               →  10/10 All tests passed!
flutter build apk --debug  →  ✅ app-debug.apk 75,419,271 bytes + .sha1
flutter devices            →  Windows / Chrome / Edge —— ⚠️ 无 Android 设备
```

### ⚠️ 待确认（**未写成正式产品规则**）

> 以下问题在 Phase 1 执行中浮现，**已按「兼容实现 + 明确记录」处理，未擅自定案**。
> 完整描述见 `docs/PROJECT_STATE.md` §7。

| # | 待确认问题 | 阻塞 |
|---|---|---|
| Q1 | **底部导航最终形态**：Baseline §6.5 / 决策 9 写「**3 Tab + AI 浮起球**」，Phase 1 brief §十四 / §十五 结构上画 **4 个位置**。二者描述不一致。 | **Phase 3** |
| Q2 | **AI 入口层级**：AI 是**第 3 个位置**，还是**浮在导航栏之上、不属于导航栏的独立元素**？（与 Q1 同源，建议合并裁决） | **Phase 3** |
| Q3 | **AI 入口是否显示文字标签**：当前实现无标签（仅渐变圆形图标），其余 3 个 Tab 有标签。 | Phase 2（低风险） |
| Q4 | 导航栏高度 `64`、AI 球 `46×46`（Figma 为 `62×62`）——**Phase 1 结构性占位值，非设计定稿**，Phase 2/3 按 Figma 重新取值。 | 无需产品确认，仅记录 |

**Phase 1 的临时处理**：按 **4 个位置 + AI 走 `isSpecial` 特殊渲染**实现，
使两种描述**都被满足**；Phase 3 只需替换视觉，**不需要改结构**。

> ⚠️ **Q1 / Q2 必须由产品侧裁决。** 在裁决前，不得在代码或文档中把它写成确定的产品规则。

### 文件变更

```text
新增  lib/            56 个 Dart 文件
新增  assets/fonts/README.md
新增  docs/phase_1_report.md
改动  pubspec.yaml
改动  test/widget_test.dart（重写）
改动  lib/main.dart（重写）
```

### 遗留

- 🔴 **K1** Noto Sans SC 字体文件缺失 —— 代码层已 100% 声明，但**无字体资产**，
  「中文走 Noto Sans SC」**无法视觉确认**。未下载、未替代。
- 🟡 **K2–K9** 见 `docs/PROJECT_STATE.md` §6
- 🟡 **O4–O7** Phase 0 开放项仍未裁决（不阻塞 Phase 1，阻塞 Phase 8/9）

### 停止点

⛔ **未进入 Phase 2。** 等待 Phase 1 验收结论。

---

## Session 001 — Phase 0：基准锁定

**日期**：2026-09-17
**阶段**：Phase 0（四来源一致性分析 + 基准锁定）
**结论**：✅ 完成 —— 9 个开放问题全部裁决，基准文档产出

### 本次做了什么

1. 将 **PRD V2.1 / IA V2.1 / Flutter Dev Spec V2.1 / Figma Make** 四方对照分析（A–E）
2. 冲突按四类分别标记：**【产品冲突】【IA 冲突】【视觉/交互差异】【技术实现差异】**
   —— 先识别，**不改代码解决**
3. 提出 Phase 0 的 9 个开放问题
4. 用户逐条裁决后，产出 `docs/07_Careerly_Development_Baseline_V1.0.md`

### 关键决策（用户裁决，已锁定）

| # | 问题 | **最终决定** |
|---|---|---|
| 1 | 「我的」Tab / Card 交互 | Tab → 对应 Card 自动移到第一位 → 点击 Card → Detail |
| 2 | 是否重新导出 Figma | **不需要** |
| 3 | 历史分析归属 | **只归「分析」**；「我的」不再提供历史分析入口 |
| 4 | 分析额度扣减时机 | **点击「开始分析」时**扣减 |
| 5 | 首页岗位变化点击 | 直接进入对应匹配结果 |
| 6 | Membership | MVP = 静态页面 + 额度门禁，**不做真实支付** |
| 7 | AI 会话历史 | **暂不进入 MVP** |
| 8 | Visual Token | 以 **Figma Make 实际视觉**为准，Flutter 重新归纳 Token |
| 9 | 底部导航 | **自绘 Careerly Navigation**，不使用 M3 NavigationBar；自定义页面转场 |

### 冲突裁决规则（硬规则，已写入 Vibe Coding Prompt）

```text
Figma ≠ PRD                  → PRD 胜
Figma ≠ IA                   → IA 胜
Figma 有视觉但 Flutter 无实现方式 → 重新实现，不放弃视觉
Figma 有页面但 PRD/IA 已取消      → 不实现
Figma 交互细节明确但 PRD 描述粗   → 采纳 Figma
```

### 一次重要的结论修正

**起初的判断**：「我的」模块落后于 PRD / IA V2.1，**必须重新导出 Figma**。

**用户的修正**（原文要点）：

> 「我不建议这么处理。…… 卡片现在有展示一些内容，所以保留卡片。
> 点击 Tab，对应卡片自动排序到第一个；用户点击卡片查看详细内容。
> **Figma 不需要重新做一版。Flutter 开发时直接实现这个行为即可。**
> 这甚至是一个很典型的：**设计稿负责视觉，Flutter 负责真实交互逻辑**。」

**处理**：原结论**标记作废**，改为上述规则并写入 `docs/07_...` §1.3。

**这条修正的意义**（值得反复引用）：
**「设计稿没画出来的交互」不等于「设计稿错了」**。
Figma Make 是 React 静态原型，天然无法表达 Card reorder、
Bottom Sheet 局部状态、额度回滚这类**运行时行为**。
遇到这类差异，正确动作是 **在 Flutter 里实现**，**不是**要求设计重新出稿。

### 文件变更

```text
新增  docs/07_Careerly_Development_Baseline_V1.0.md
```

### 产出

`docs/07_...Baseline_V1.0.md` —— 后续所有 Phase 的**唯一歧义仲裁入口**：
§1 来源优先级与裁决规则 · §2 九项锁定决策 · §3 信息归属 ·
§4 三大模块结构 · §5 额度规则 · §6 视觉/Token 规则 ·
§7 工程规则 · §8 Phase 序列 · §9 开放项 O1–O7

### 遗留

O1–O7 开放项（其中 **O1 字体 / O2 成长日历归属 / O3 历史版本形态** 已在 Phase 1 落实）。

---

## 模板 — 后续会话请照此追加

> 追加到文件**最上方**（最新在前）。

```markdown
## Session NNN — <阶段名>

**日期**：YYYY-MM-DD
**阶段**：
**结论**：✅ 完成 / ⚠️ PASS WITH NOTES / ⛔ BLOCKED

### 本次完成内容

### 重要决策
（每条：背景 → 问题 → 决定 → 理由）

### 修改文件
（📄 文档 / 💻 代码，分列）

### 测试结果
（命令 + **真实输出**；没跑就写「未运行」并说明原因）

### 新发现
（本轮才暴露出来的事实，尤其是与既有文档不符的）

### 未解决问题
（引用 Known Issue 编号；**未由产品侧确认的一律标「待确认」**）

### 下一步
（含明确的停止点）
```

---

**Careerly Dev Log** · 最后追加 2026-09-21 · 记录至 Session 012 · 最新在前
