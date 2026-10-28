import 'package:flutter/material.dart';
import 'package:study_planner_flutter/model/study_destination.dart';
import 'package:study_planner_flutter/viewmodel/study_planner_view_model.dart';
import 'package:study_planner_flutter/view/PR/pr01.dart';
import 'package:study_planner_flutter/view/PR/pr02.dart';
import 'package:study_planner_flutter/view/PR/pr03.dart';
import 'package:study_planner_flutter/view/PR/pr04.dart';
import 'package:study_planner_flutter/view/PR/pr05.dart';

class ProfileFlow extends StatelessWidget {
  const ProfileFlow({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;

  @override
  Widget build(BuildContext context) => switch (viewModel.destination) {
    StudyDestination.pr01 => Pr01Screen(viewModel: viewModel),
    StudyDestination.pr02 => Pr02Screen(viewModel: viewModel),
    StudyDestination.pr03 => Pr03Screen(viewModel: viewModel),
    StudyDestination.pr04 => Pr04Screen(viewModel: viewModel),
    StudyDestination.pr05 => Pr05Screen(viewModel: viewModel),
    _ => const SizedBox.shrink(),
  };
}
