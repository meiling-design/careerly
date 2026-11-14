import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/router/back_navigation.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../onboarding/state/auth_provider.dart';

/// 删除职业数据但保留账号，属于「设置 → 隐私与数据」的二级页面。
class DeleteCareerDataPage extends StatelessWidget {
  const DeleteCareerDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();

    return CareerlyScaffold(
      title: '删除职业数据',
      leading: IconButton(
        onPressed: () => careerlyBack(context),
        icon: const Icon(Icons.arrow_back),
        tooltip: '返回',
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        children: <Widget>[
          _Section(
            title: '将删除的职业数据',
            children: const <Widget>[
              _Bullet('简历及简历版本'),
              _Bullet('保存的职位描述（JD）'),
              _Bullet('分析结果与匹配记录'),
              _Bullet('能力快照与成长记录'),
              _Bullet('相关服务端 session 和可归属的文件'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _Section(
            title: '账号会保留',
            children: const <Widget>[
              _Bullet('账号、登录凭据和当前登录状态不会被删除。'),
              _Bullet('无法确认归属的历史文件不会被猜测性删除；清理结果会提示。'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          CareerlyButton(
            label: '删除职业数据',
            variant: CareerlyButtonVariant.secondary,
            onPressed: auth.isDeletingCareerData
                ? null
                : () => _onDelete(context),
          ),
        ],
      ),
    );
  }

  Future<void> _onDelete(BuildContext context) async {
    final bool confirmed = await _confirmDelete(context);
    if (!confirmed || !context.mounted) return;

    final AuthProvider auth = context.read<AuthProvider>();
    final bool ok = await auth.deleteCareerData();
    if (!context.mounted) return;

    if (!ok) {
      CareerlyToast.show(
        context,
        message: auth.careerDataError?.message ?? '删除职业数据失败，请重试',
        icon: Icons.error_outline,
      );
      auth.resetDeleteCareerData();
      return;
    }

    final CareerDataDeletionResult result = auth.careerDataResult!;
    CareerlyToast.show(
      context,
      message: _resultMessage(result),
      icon: result.complete ? Icons.check_circle_outline : Icons.warning_amber,
    );
  }

  String _resultMessage(CareerDataDeletionResult result) {
    if (result.complete) {
      return '职业数据已删除，账号和登录状态保留。';
    }
    if (result.orphanArtifacts > 0) {
      return '已清除可归属的数据；${result.orphanArtifacts} 个历史文件无法确认归属，未删除。';
    }
    return '职业数据清理未完全完成，部分文件无法删除，请联系支持。';
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final bool? confirmed = await CareerlyBottomSheet.show<bool>(
      context,
      tone: CareerlyBottomSheetTone.confirm,
      child: Builder(
        builder: (BuildContext sheetContext) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('确认删除职业数据？', style: AppTypography.title),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '简历、职位描述、分析与成长记录等可归属数据将被清除。'
                '账号和当前登录状态会保留，此操作无法撤销。',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              CareerlyButton(
                label: '确认删除',
                variant: CareerlyButtonVariant.secondary,
                onPressed: () => Navigator.of(sheetContext).pop(true),
              ),
              const SizedBox(height: AppSpacing.xs),
              CareerlyButton(
                label: '取消',
                variant: CareerlyButtonVariant.neutral,
                onPressed: () => Navigator.of(sheetContext).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
    return confirmed ?? false;
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            bottom: AppSpacing.xs,
          ),
          child: Text(title, style: AppTypography.caption),
        ),
        CareerlyCard(
          variant: CareerlyCardVariant.glassLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('• '),
          Expanded(child: Text(text, style: AppTypography.bodySmall)),
        ],
      ),
    );
  }
}
