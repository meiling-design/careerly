import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/router/back_navigation.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/app_info_platform.dart';
import '../../../core/services/support_mail.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import 'widgets/support_email_action.dart';

/// 关于 Careerly。属于「设置 → 帮助与反馈」的二级页面。
///
/// ## 版本号
///
/// 底部版本号**不写死** —— 通过 [AppInfoPlatform] 读取宿主从 `pubspec.yaml`
/// 生成的真实 `versionName` / `versionCode`。通道不可用时如实显示
/// 「版本信息暂不可用」，不编造数字。
///
/// ## 星云
///
/// 页面顶部使用原创 IP「星云」的既有 SVG 素材，尺寸克制（[_AboutMetrics.ipSize]），
/// 只作为陪伴角色出现，不压过品牌文字。
class AboutCareerlyPage extends StatefulWidget {
  const AboutCareerlyPage({super.key, this.versionLoader, this.mailLauncher});

  /// 测试注入缝：默认读平台通道。
  final Future<AppVersion?> Function()? versionLoader;

  /// 测试注入缝：默认打开系统邮件应用。
  final SupportMailLauncher? mailLauncher;

  @override
  State<AboutCareerlyPage> createState() => _AboutCareerlyPageState();
}

class _AboutCareerlyPageState extends State<AboutCareerlyPage> {
  AppVersion? _version;
  bool _isLoadingVersion = true;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final Future<AppVersion?> Function() loader =
        widget.versionLoader ?? AppInfoPlatform.readVersion;

    AppVersion? version;
    try {
      version = await loader();
    } catch (_) {
      version = null;
    }

    if (!mounted) return;
    setState(() {
      _version = version;
      _isLoadingVersion = false;
    });
  }

  Future<void> _contact() {
    return sendSupportMail(
      context,
      subject: '关于 Careerly 的咨询',
      body: '你好，我想咨询：\n\n',
      launcher: widget.mailLauncher,
    );
  }

  String get _versionLabel {
    if (_isLoadingVersion) return '正在读取版本…';
    final AppVersion? version = _version;
    return version == null ? '版本信息暂不可用' : '版本 ${version.label}';
  }

  @override
  Widget build(BuildContext context) {
    return CareerlyScaffold(
      title: '关于 Careerly',
      leading: IconButton(
        onPressed: () => careerlyBack(context),
        icon: const Icon(Icons.arrow_back),
        tooltip: '返回',
      ),
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: <Widget>[
          const _BrandHero(),
          const SizedBox(height: AppSpacing.xl),
          _SectionTitle(title: '品牌介绍'),
          const SizedBox(height: AppSpacing.sm),
          CareerlyCard(
            variant: CareerlyCardVariant.glassLight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '职业成长，不一定始于一个明确的目标。',
                  style: AppTypography.bodyStrong,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '有时，它始于一次重新认识自己，发现自己已经拥有的能力，'
                  '也看见距离下一步还有多远。',
                  style: AppTypography.body,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Careerly 希望通过 AI，帮助你梳理职业经历、识别能力、'
                  '理解目标岗位的要求，并将模糊的职业差距转化为可以逐步完成的行动。',
                  style: AppTypography.body,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '我们相信，成长不是一次性的结果，而是持续积累、'
                  '不断看见自己的过程。',
                  style: AppTypography.body,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionTitle(title: '品牌价值'),
          const SizedBox(height: AppSpacing.sm),
          const _BrandValues(),
          const SizedBox(height: AppSpacing.xl),
          _AboutFooter(
            versionLabel: _versionLabel,
            onContact: _contact,
            onTerms: () => context.push(AppRoutes.legalTerms),
            onPrivacy: () => context.push(AppRoutes.legalPrivacy),
          ),
        ],
      ),
    );
  }
}

/// 品牌区：星云 + 字标 + 定位 + 主张。
class _BrandHero extends StatelessWidget {
  const _BrandHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SvgPicture.asset(
          'assets/images/nebula/nebula-welcome.svg',
          width: _AboutMetrics.ipSize,
          height: _AboutMetrics.ipSize,
          fit: BoxFit.contain,
          semanticsLabel: '星云，Careerly 的 AI 伙伴',
        ),
        const SizedBox(height: AppSpacing.sm),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (Rect bounds) =>
              AppColors.splashTitleGradient.createShader(bounds),
          child: Text(
            AppConstants.appName,
            textAlign: TextAlign.center,
            style: AppTypography.headline,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'AI 职业成长伙伴',
          textAlign: TextAlign.center,
          style: AppTypography.body,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          AppConstants.tagline,
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '星云 · Careerly 的 AI 伙伴',
          textAlign: TextAlign.center,
          style: AppTypography.caption,
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(title, style: AppTypography.subtitle),
    );
  }
}

/// 三个品牌价值。
class _BrandValues extends StatelessWidget {
  const _BrandValues();

  @override
  Widget build(BuildContext context) {
    return CareerlyCard(
      variant: CareerlyCardVariant.glassLight,
      child: Column(
        children: <Widget>[
          const _ValueRow(
            icon: Icons.visibility_outlined,
            title: '看见能力',
            description: '重新认识自己的经历、技能与职业价值。',
          ),
          const SizedBox(height: AppSpacing.md),
          const _ValueRow(
            icon: Icons.trending_up_rounded,
            title: '跨越 Gap',
            description: '理解目标与现状之间的差距，找到下一步方向。',
          ),
          const SizedBox(height: AppSpacing.md),
          const _ValueRow(
            icon: Icons.timeline_rounded,
            title: '记录成长',
            description: '让每一次经历、每一项能力和每一点进步都有迹可循。',
          ),
        ],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: _AboutMetrics.valueIconBox,
          height: _AboutMetrics.valueIconBox,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primaryBlueSurface,
            borderRadius: AppRadius.borderXs,
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 20),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: AppTypography.bodyStrong),
              const SizedBox(height: AppSpacing.xxs),
              Text(description, style: AppTypography.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

/// 页脚：品牌名 / 版本 / 联系邮箱 / 协议 / 版权。
class _AboutFooter extends StatelessWidget {
  const _AboutFooter({
    required this.versionLabel,
    required this.onContact,
    required this.onTerms,
    required this.onPrivacy,
  });

  final String versionLabel;
  final Future<void> Function() onContact;
  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  @override
  Widget build(BuildContext context) {
    final TextStyle linkStyle = AppTypography.bodySmall.copyWith(
      color: AppColors.primaryBlue,
    );

    return CareerlyCard(
      variant: CareerlyCardVariant.glassLight,
      child: Column(
        children: <Widget>[
          Text(AppConstants.appName, style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.xxs),
          Text(versionLabel, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.sm),
          CareerlyTextLink(
            label: SupportMail.address,
            style: linkStyle,
            semanticsLabel: '联系邮箱 ${SupportMail.address}',
            onPressed: onContact,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.xs,
            children: <Widget>[
              CareerlyTextLink(
                label: '用户协议',
                style: linkStyle,
                onPressed: onTerms,
              ),
              Text('·', style: AppTypography.bodySmall),
              CareerlyTextLink(
                label: '隐私政策',
                style: linkStyle,
                onPressed: onPrivacy,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('© 2026 Careerly', style: AppTypography.caption),
        ],
      ),
    );
  }
}

abstract final class _AboutMetrics {
  /// 星云 IP 尺寸。克制一点，避免装饰压过品牌文字。
  static const double ipSize = 96;

  /// 品牌价值图标底板边长。
  static const double valueIconBox = 40;
}
