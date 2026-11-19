import 'package:flutter/material.dart';

import '../../../../data/models/analysis_job_input.dart';
import '../../../../data/models/analysis_project.dart';
import '../../../../data/models/job.dart';
import '../../../../data/models/resume_profile.dart';
import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens/tokens.dart';

class UpdateAnalysisSelection {
  const UpdateAnalysisSelection({this.resumeVersionId, required this.jobs});

  final String? resumeVersionId;
  final List<AnalysisJobInput> jobs;
}

Future<UpdateAnalysisSelection?> showUpdateAnalysisSheet(
  BuildContext context, {
  required AnalysisProject project,
  required ResumeProfile resume,
}) {
  return CareerlyBottomSheet.show<UpdateAnalysisSelection>(
    context,
    tone: CareerlyBottomSheetTone.action,
    child: _UpdateAnalysisSheet(project: project, resume: resume),
  );
}

class _UpdateAnalysisSheet extends StatefulWidget {
  const _UpdateAnalysisSheet({required this.project, required this.resume});

  final AnalysisProject project;
  final ResumeProfile resume;

  @override
  State<_UpdateAnalysisSheet> createState() => _UpdateAnalysisSheetState();
}

class _UpdateAnalysisSheetState extends State<_UpdateAnalysisSheet> {
  late final Map<String, bool> _selectedJobs;
  String? _resumeVersionId;

  @override
  void initState() {
    super.initState();
    _selectedJobs = <String, bool>{
      for (final Job job in widget.project.jobs) job.id: true,
    };
  }

  @override
  Widget build(BuildContext context) {
    ResumeVersion? current;
    for (final ResumeVersion version in widget.resume.versions) {
      if (version.isCurrent) {
        current = version;
        break;
      }
    }

    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 560),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text('更新这次分析', style: AppTypography.analysisSheetTitle),
                const SizedBox(height: 6),
                const Text(
                  '保留原有分析记录，看看新的职业能力能带来哪些变化',
                  style: AppTypography.analysisSheetBody,
                ),
                const SizedBox(height: 16),
                Text(
                  '当前分析：${widget.project.results.length} 个历史版本 · ${widget.project.jobs.length} 个岗位',
                  style: AppTypography.analysisSheetOptionDesc,
                ),
                const SizedBox(height: 12),
                _ResumeChoice(
                  title: '使用最新简历',
                  description: current == null
                      ? '使用当前最新版本重新评估'
                      : '${current.label} · 当前版本',
                  selected: _resumeVersionId == null,
                  onTap: () => setState(() => _resumeVersionId = null),
                ),
                for (final ResumeVersion version in widget.resume.versions)
                  if (!version.isCurrent) ...<Widget>[
                    const SizedBox(height: 8),
                    _ResumeChoice(
                      title: '使用${version.label}',
                      description: '指定历史简历版本重新评估',
                      selected: _resumeVersionId == version.id,
                      onTap: () =>
                          setState(() => _resumeVersionId = version.id),
                    ),
                  ],
                const SizedBox(height: 16),
                const Text(
                  '调整目标岗位',
                  style: AppTypography.analysisSheetOptionTitle,
                ),
                const SizedBox(height: 8),
                for (final Job job in widget.project.jobs) ...<Widget>[
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _selectedJobs[job.id] ?? false,
                    onChanged: (bool? value) =>
                        setState(() => _selectedJobs[job.id] = value ?? false),
                    title: Text(
                      job.displayName,
                      style: AppTypography.analysisSheetOptionDesc,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                CareerlyButton(
                  label: '确认并重新分析',
                  onPressed: () {
                    final List<AnalysisJobInput> jobs = <AnalysisJobInput>[
                      for (final Job job in widget.project.jobs)
                        if (_selectedJobs[job.id] == true)
                          AnalysisJobInput(
                            jobId: job.id,
                            title: job.title,
                            rawJd: job.rawJd,
                            company: job.company,
                            source: 'history',
                          ),
                    ];
                    if (jobs.isEmpty) return;
                    Navigator.of(context).pop(
                      UpdateAnalysisSelection(
                        resumeVersionId: _resumeVersionId,
                        jobs: jobs,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResumeChoice extends StatelessWidget {
  const _ResumeChoice({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.analysisSheetOptionPurpleFill
              : AppColors.analysisSheetGhostFill,
          borderRadius: AppRadius.borderLg,
          border: Border.all(
            color: selected
                ? AppColors.analysisSheetOptionPurpleBorder
                : AppColors.rowDivider,
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: AppTypography.analysisSheetOptionTitle),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTypography.analysisSheetOptionDesc,
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
            ),
          ],
        ),
      ),
    );
  }
}
