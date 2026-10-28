import 'package:flutter/material.dart';
import 'package:study_planner_flutter/model/study_destination.dart';
import 'package:study_planner_flutter/viewmodel/study_planner_view_model.dart';
import 'package:study_planner_flutter/view/PL/pl01.dart';
import 'package:study_planner_flutter/view/PL/pl02.dart';
import 'package:study_planner_flutter/view/PL/pl03.dart';
import 'package:study_planner_flutter/view/PL/pl04.dart';
import 'package:study_planner_flutter/view/PL/pl05.dart';
import 'package:study_planner_flutter/view/PL/pl06.dart';
import 'package:study_planner_flutter/view/PL/pl07.dart';
import 'package:study_planner_flutter/view/PL/pl08.dart';
import 'package:study_planner_flutter/view/PL/pl09.dart';
import 'package:study_planner_flutter/view/PL/pl10.dart';
import 'package:study_planner_flutter/view/PL/pl11.dart';
import 'package:study_planner_flutter/view/PL/pl12.dart';
import 'package:study_planner_flutter/view/PL/pl13.dart';
import 'package:study_planner_flutter/view/PL/pl14.dart';
import 'package:study_planner_flutter/view/PL/pl15.dart';
import 'package:study_planner_flutter/view/PL/pl16.dart';
import 'package:study_planner_flutter/view/PL/pl17.dart';
import 'package:study_planner_flutter/view/PL/pl18.dart';

class PlannerFlow extends StatelessWidget {
  const PlannerFlow({super.key, required this.viewModel});
  final StudyPlannerViewModel viewModel;

  @override
  Widget build(BuildContext context) => switch (viewModel.destination) {
    StudyDestination.pl01 => Pl01Screen(viewModel: viewModel),
    StudyDestination.pl02 => Pl02Screen(viewModel: viewModel),
    StudyDestination.pl03 => Pl03Screen(viewModel: viewModel),
    StudyDestination.pl04 => Pl04Screen(viewModel: viewModel),
    StudyDestination.pl05 => Pl05Screen(viewModel: viewModel),
    StudyDestination.pl06 => Pl06Screen(viewModel: viewModel),
    StudyDestination.pl07 => Pl07Screen(viewModel: viewModel),
    StudyDestination.pl08 => Pl08Screen(viewModel: viewModel),
    StudyDestination.pl09 => Pl09Screen(viewModel: viewModel),
    StudyDestination.pl10 => Pl10Screen(viewModel: viewModel),
    StudyDestination.pl11 => Pl11Screen(viewModel: viewModel),
    StudyDestination.pl12 => Pl12Screen(viewModel: viewModel),
    StudyDestination.pl13 => Pl13Screen(viewModel: viewModel),
    StudyDestination.pl14 => Pl14Screen(viewModel: viewModel),
    StudyDestination.pl15 => Pl15Screen(viewModel: viewModel),
    StudyDestination.pl16 => Pl16Screen(viewModel: viewModel),
    StudyDestination.pl17 => Pl17Screen(viewModel: viewModel),
    StudyDestination.pl18 => Pl18Screen(viewModel: viewModel),
    _ => const SizedBox.shrink(),
  };
}
