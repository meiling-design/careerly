import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../app/router/back_navigation.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/state/async_state.dart';
import '../../../design_system/components/components.dart';
import '../legal_document.dart';
import '../legal_markdown.dart';
import 'widgets/legal_document_body.dart';

/// 协议正文页（用户协议 / 隐私政策**共用**）。
///
/// 依据 `TODO.md` §1.0f ③ · E2 / E3：
/// 注册页的同意勾选必须能真的打开被同意的文档，否则「要求同意一份读不到的文件」
/// 在合规上不成立。本页就是那个「读得到」的落点。
///
/// 两份协议共用一个页面类，差异只有 [LegalDocument] —— 见该枚举文档
/// （`CLAUDE.md` §8.4「变体用参数，不用新组件」）。
///
/// ## 图里没有这个页面
///
/// Figma 里**不存在**协议页（也没有注册页的同意行）。本页的视觉是 Flutter 侧定的：
/// 容器沿用二级页既有写法，排版全部复用 `AppTypography` 的通用角色，
/// 间距复用既有 `AppSpacing` 档位。**未新增任何 Token，因此没有新的暂定值。**
/// 但「这一页长什么样」没有设计源，**验收时不得盖章为视觉已定稿**
/// —— 登记为 **待裁决 · D124**（`docs/05_progress/TODO.md` §3.1）。
///
/// ## 返回
///
/// 照 `delete_account_page.dart` 的二级页写法：只调 [careerlyBack]。
/// 本页没有未保存状态，因此**不**包 `CareerlyBackScope`
/// （`back_navigation.dart` 明确：无守卫的页面「一字不用改、完全透明」）。
/// 返回目标由路由层级表达，页面不自己决定回到哪（`CLAUDE.md` §5.6）。
///
/// ## 四态
///
/// 资产读取是异步的，因此必须处理 Loading / Empty / Error / Retry
/// （`CLAUDE.md` §5.5）。四态由 [CareerlyAsyncStateView] 承载，本页不自己写分支。
/// Empty 在这里的语义是「文件存在但没有可渲染的块」——
/// 属于内容事故（正文被清空），因此文案按错误来写，不写「暂无内容」。
///
/// ## 为什么关掉资产缓存（`cache: false`）
///
/// `rootBundle` 是 `CachingAssetBundle`：它按路径缓存**第一次**读取返回的
/// `Future`。这个缓存有个必须知道的副作用：
///
/// ```text
/// 一个 Future 的续体是在**创建它的 Zone** 里调度的。
/// widget test 里每个 `testWidgets` 各有一个 FakeAsync Zone，
/// 而 Zone 是**用完即弃**的 —— 于是第二个测试 await 到第一个测试
/// 缓存的 Future 时，续体被排进那个**已经作废的 Zone**，永远不执行。
/// 表现是：同一个资产「第一个测试读得到，之后全都读不到」。
/// ```
///
/// 那是个**测试侧的坑**，但踩中的是**生产代码**，所以在这里治：
/// 关掉缓存后每次读取都是全新请求，落在当前 Zone 里，行为与测试环境无关。
///
/// 生产侧代价为零：本页每次打开只读一次资产（几 KB），
/// 缓存本来也帮不上忙；而换来的是一组**真正读 bundled 资产**的测试
/// —— 少了 `pubspec.yaml` 的 `assets:` 声明这种事故，测试会直接红。
class LegalDocumentPage extends StatefulWidget {
  const LegalDocumentPage({super.key, required this.document, this.loader});

  /// 要展示哪一份协议。
  final LegalDocument document;

  /// 正文读取器。默认读 bundle 里的 [LegalDocument.assetPath]。
  ///
  /// ⚠️ 这是**测试注入缝**：真实资产永远读得成功，Error 态因此不可达、不可测。
  /// 与 `CareerlyApp.overrides` / `ResumeFilePicker` 的平台网关同一处置——
  /// 留一个缝，而不是为了可测性把错误处理删掉。
  final Future<String> Function()? loader;

  @override
  State<LegalDocumentPage> createState() => _LegalDocumentPageState();
}

class _LegalDocumentPageState extends State<LegalDocumentPage> {
  AsyncState<List<LegalBlock>> _state =
      const AsyncState<List<LegalBlock>>.initial();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<String> _readAsset() {
    final Future<String> Function()? loader = widget.loader;
    if (loader != null) return loader();
    // ⚠️ `cache: false` 是**故意的**，不是疏漏 —— 见下方「为什么关掉资产缓存」。
    return rootBundle.loadString(widget.document.assetPath, cache: false);
  }

  Future<void> _load() async {
    setState(() => _state = const AsyncState<List<LegalBlock>>.loading());
    try {
      // 解析放在加载里做一次，而不是在 build 里：正文不变，
      // 每次 rebuild 重解析一遍纯属浪费，且解析失败会落到 Error 态。
      final List<LegalBlock> blocks = parseLegalMarkdown(await _readAsset());
      if (!mounted) return;
      setState(() => _state = AsyncState<List<LegalBlock>>.success(blocks));
    } catch (error, stackTrace) {
      if (!mounted) return;
      setState(
        () => _state = AsyncState<List<LegalBlock>>.failure(
          // 归为 UnknownError：这是本地资源问题，不是网络问题，
          // 归成 NetworkError 会让用户去检查网络（错误归因）。
          UnknownError(
            message: '协议内容读取失败，请重试',
            cause: error,
            stackTrace: stackTrace,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CareerlyScaffold(
      title: widget.document.title,
      leading: IconButton(
        onPressed: () => careerlyBack(context),
        icon: const Icon(Icons.arrow_back),
        tooltip: '返回',
      ),
      child: CareerlyAsyncStateView<List<LegalBlock>>(
        state: _state,
        loadingMessage: '正在加载${widget.document.title}',
        onRetry: _load,
        isEmpty: (List<LegalBlock> blocks) => blocks.isEmpty,
        emptyTitle: '协议内容为空',
        emptyMessage: '正文未能加载，请稍后重试。',
        builder: (BuildContext context, List<LegalBlock> blocks) => ListView(
          children: <Widget>[LegalDocumentBody(blocks: blocks)],
        ),
      ),
    );
  }
}
