import 'package:flutter/material.dart';
import 'package:study_planner_flutter/model/study_destination.dart';
import 'package:study_planner_flutter/viewmodel/study_planner_view_model.dart';
import 'package:study_planner_flutter/view/GO/go01.dart';
import 'package:study_planner_flutter/view/GO/go02.dart';
import 'package:study_planner_flutter/view/GO/go03.dart';
import 'package:study_planner_flutter/view/GO/go04.dart';
import 'package:study_planner_flutter/view/GO/go05.dart';
import 'package:study_planner_flutter/view/GO/go06.dart';
import 'package:study_planner_flutter/view/GO/go07.dart';
import 'package:study_planner_flutter/view/GO/go08.dart';
import 'package:study_planner_flutter/view/GO/go09.dart';
import 'package:study_planner_flutter/view/GO/go10.dart';

class GoFlow extends StatelessWidget {
  const GoFlow({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;

  @override
  Widget build(BuildContext context) => switch (viewModel.destination) {
    StudyDestination.go01 => Go01Screen(viewModel: viewModel),
    StudyDestination.go02 => Go02Screen(viewModel: viewModel),
    StudyDestination.go03 => Go03Screen(viewModel: viewModel),
    StudyDestination.go04 => Go04Screen(viewModel: viewModel),
    StudyDestination.go05 => Go05Screen(viewModel: viewModel),
    StudyDestination.go06 => Go06Screen(viewModel: viewModel),
    StudyDestination.go07 => Go07Screen(viewModel: viewModel),
    StudyDestination.go08 => Go08Screen(viewModel: viewModel),
    StudyDestination.go09 => Go09Screen(viewModel: viewModel),
    StudyDestination.go10 => Go10Screen(viewModel: viewModel),
    _ => const SizedBox.shrink(),
  };
}
