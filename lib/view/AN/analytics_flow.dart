import 'package:flutter/material.dart';
import 'package:study_planner_flutter/model/study_destination.dart';
import 'package:study_planner_flutter/viewmodel/study_planner_view_model.dart';
import 'package:study_planner_flutter/view/AN/an01.dart';
import 'package:study_planner_flutter/view/AN/an02.dart';
import 'package:study_planner_flutter/view/AN/an03.dart';
import 'package:study_planner_flutter/view/AN/an04.dart';
import 'package:study_planner_flutter/view/AN/an05.dart';
import 'package:study_planner_flutter/view/AN/an06.dart';
import 'package:study_planner_flutter/view/AN/an07.dart';
import 'package:study_planner_flutter/view/AN/an08.dart';
import 'package:study_planner_flutter/view/AN/an09.dart';

class AnalyticsFlow extends StatelessWidget {
  const AnalyticsFlow({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;

  @override
  Widget build(BuildContext context) => switch (viewModel.destination) {
    StudyDestination.an01 => An01Screen(viewModel: viewModel),
    StudyDestination.an02 => An02Screen(viewModel: viewModel),
    StudyDestination.an03 => An03Screen(viewModel: viewModel),
    StudyDestination.an04 => An04Screen(viewModel: viewModel),
    StudyDestination.an05 => An05Screen(viewModel: viewModel),
    StudyDestination.an06 => An06Screen(viewModel: viewModel),
    StudyDestination.an07 => An07Screen(viewModel: viewModel),
    StudyDestination.an08 => An08Screen(viewModel: viewModel),
    StudyDestination.an09 => An09Screen(viewModel: viewModel),
    _ => const SizedBox.shrink(),
  };
}
