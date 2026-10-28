import 'package:flutter/material.dart';
import 'package:study_planner_flutter/model/study_destination.dart';
import 'package:study_planner_flutter/viewmodel/study_planner_view_model.dart';
import 'package:study_planner_flutter/view/HM/hm01.dart';
import 'package:study_planner_flutter/view/HM/hm02.dart';
import 'package:study_planner_flutter/view/HM/hm03.dart';
import 'package:study_planner_flutter/view/HM/hm04.dart';
import 'package:study_planner_flutter/view/HM/hm05.dart';
import 'package:study_planner_flutter/view/HM/hm06.dart';
import 'package:study_planner_flutter/view/HM/hm07.dart';
import 'package:study_planner_flutter/view/HM/hm08.dart';
import 'package:study_planner_flutter/view/HM/hm09.dart';
import 'package:study_planner_flutter/view/HM/hm10.dart';

class HmFlow extends StatelessWidget {
  const HmFlow({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;

  @override
  Widget build(BuildContext context) => switch (viewModel.destination) {
    StudyDestination.hm01 => Hm01Screen(viewModel: viewModel),
    StudyDestination.hm02 => Hm02Screen(viewModel: viewModel),
    StudyDestination.hm03 => Hm03Screen(viewModel: viewModel),
    StudyDestination.hm04 => Hm04Screen(viewModel: viewModel),
    StudyDestination.hm05 => Hm05Screen(viewModel: viewModel),
    StudyDestination.hm06 => Hm06Screen(viewModel: viewModel),
    StudyDestination.hm07 => Hm07Screen(viewModel: viewModel),
    StudyDestination.hm08 => Hm08Screen(viewModel: viewModel),
    StudyDestination.hm09 => Hm09Screen(viewModel: viewModel),
    StudyDestination.hm10 => Hm10Screen(viewModel: viewModel),
    _ => const SizedBox.shrink(),
  };
}
