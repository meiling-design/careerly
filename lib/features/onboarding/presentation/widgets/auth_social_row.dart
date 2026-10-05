import 'package:flutter/material.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens/tokens.dart';

/// 登录页 / 注册页底部的「微信 · QQ」两枚第三方登录按钮。
///
/// 真值来源：2026-10-04 重新导出的 Figma ——
/// `OnLogin`（`src/App.tsx` L594-611）与 `OnRegister`（L775-792）：
///
/// ```text
/// grid grid-cols-2 gap-[21px]
/// ├── CareerlySocialButton 微信  （文字 #1872cf）
/// └── CareerlySocialButton QQ    （文字 #363333）
/// ```
///
/// 两页的按钮区**逐位一致**，故收敛成一个页面内共享组件，
/// 而不是在两个页面里各写一遍（`gap-[21px]` 已经是
/// `AppSpacing.authSocialGap`，这里只负责两个按钮的身份）。
///
/// ## ⚠️ 图标是**近似实现**（未解决的资源缺口）
///
/// Figma 用的是两个自有 SVG（`public/assets/cea01.svg` 微信、
/// `e9944.svg` QQ，各 25×25）。**Careerly 的 Flutter 仓库里没有这两个资产**，
/// 且 `CLAUDE.md` §8.3 明令**不得自行从网络下载**字体 / 资源 ——
/// 因此这里用 Material 图标近似，沿用 `_RegisterAvatar` 对头像 SVG 的
/// 既有先例（`Icons.person` + 既有 Token 色）。
///
/// ```text
/// 微信   Icons.wechat                 ← Material Icons 里确有该字形
/// QQ      Icons.chat_bubble_outline   ← **没有** QQ 字形，用通用对话气泡近似
/// ```
///
/// 图标的着色取**各自渠道的文字色**（微信蓝 / QQ 深灰）——
/// Figma 的 SVG 自带填色（微信原版是绿色），本实现拿不到那些颜色；
/// 取文字色至少让「图标 + 文案」读起来是同一个整体。
///
/// ⚠️ **这是近似，不是设计定稿** —— 已登记为待裁决项，
/// 验收时不得据此认为社交按钮的视觉已确认。
///
/// ## 行为
///
/// 点击**真实调用** `AuthRepository.signInWithOAuth`。后端当前一律返回
/// 501（未配置 / 未开通，见 `work_agent/app/api/router_auth.py`），
/// 由调用方把这条错误如实展示给用户 —— 按钮**不会**静默失败，
/// 也**不会**假装登录成功。
class AuthSocialRow extends StatelessWidget {
  const AuthSocialRow({
    super.key,
    required this.onWechat,
    required this.onQq,
  });

  /// 微信按钮回调。为 `null` 时该按钮不可用（请求在途）。
  final VoidCallback? onWechat;

  /// QQ 按钮回调。为 `null` 时该按钮不可用（请求在途）。
  final VoidCallback? onQq;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: CareerlySocialButton(
            label: '微信',
            labelColor: AppColors.authWechatInk,
            icon: const Icon(
              Icons.wechat,
              size: _SocialRowMetrics.iconSize,
              color: AppColors.authWechatInk,
            ),
            onPressed: onWechat,
          ),
        ),
        const SizedBox(width: AppSpacing.authSocialGap),
        Expanded(
          child: CareerlySocialButton(
            label: 'QQ',
            labelColor: AppColors.authQqInk,
            icon: const Icon(
              Icons.chat_bubble_outline,
              size: _SocialRowMetrics.iconSize,
              color: AppColors.authQqInk,
            ),
            onPressed: onQq,
          ),
        ),
      ],
    );
  }
}

/// 组件内部几何。
abstract final class _SocialRowMetrics {
  /// Figma：图标 `width="25" height="25"`。
  static const double iconSize = 25;
}
