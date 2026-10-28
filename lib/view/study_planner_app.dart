import 'package:flutter/material.dart';
import 'package:study_planner_flutter/view/AN/analytics_flow.dart';
import 'package:study_planner_flutter/view/GO/go_flow.dart';
import 'package:study_planner_flutter/view/HM/hm_flow.dart';
import 'package:study_planner_flutter/view/PL/planner_flow.dart';
import 'package:study_planner_flutter/view/PR/profile_flow.dart';
import 'package:study_planner_flutter/viewmodel/study_planner_view_model.dart';

class StudyPlannerApp extends StatelessWidget {
  const StudyPlannerApp({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) =>
        switch (viewModel.destination.name.substring(0, 2)) {
          'hm' => HmFlow(viewModel: viewModel),
          'go' => GoFlow(viewModel: viewModel),
          'an' => AnalyticsFlow(viewModel: viewModel),
          'pr' => ProfileFlow(viewModel: viewModel),
          'pl' => PlannerFlow(viewModel: viewModel),
          _ => HmFlow(viewModel: viewModel),
        },
  );
}
