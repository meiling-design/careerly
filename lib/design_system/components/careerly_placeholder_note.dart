import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

/// Phase 1 专用：页面占位说明。
///
/// 依据 Phase 1 §十：
/// > Features 可以暂时只有 placeholder / README / empty scaffold / route placeholder。
///
/// 这个组件存在的意义是让「这个页面已经接线通了，但业务还没做」
/// 这件事在真机上**可见**，而不是一个空白页让人误以为加载失败。
///
/// ⚠️ **Phase 2 起逐页删除**——真实业务 UI 落地时它不应该还留在代码里。
class CareerlyPlaceholderNote extends StatelessWidget {
  const CareerlyPlaceholderNote({
    super.key,
    required this.title,
    required this.contains,
    this.phase,
  });

  /// 页面名。
  final String title;

  /// 该页面**将来**承载的内容（来自 PRD / IA，不是猜的）。
  final List<String> contains;

  /// 计划实现的阶段。
  final String? phase;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: AppColors.glassFillLight,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.glassBorderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.construction_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Text(title, style: AppTypography.bodyStrong),
              ),
              if (phase != null)
                Text(phase!, style: AppTypography.caption),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('本页将来承载：', style: AppTypography.caption),
          const SizedBox(height: AppSpacing.xxs),
          for (final String item in contains)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xxs),
              child: Text('· $item', style: AppTypography.bodySmall),
            ),
        ],
      ),
    );
  }
}
