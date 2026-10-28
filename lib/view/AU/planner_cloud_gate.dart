import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../services/planner_state_repository.dart';
import '../../viewmodel/study_planner_view_model.dart';

class PlannerCloudGate extends StatefulWidget {
  const PlannerCloudGate({
    super.key,
    required this.repository,
    required this.vm,
    required this.child,
  });
  final PlannerStateRepository repository;
  final StudyPlannerViewModel vm;
  final Widget child;
  @override
  State<PlannerCloudGate> createState() => _PlannerCloudGateState();
}

class _PlannerCloudGateState extends State<PlannerCloudGate> {
  bool ready = false, writing = false;
  String? error;
  String saved = '';
  Timer? timer;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final data = await widget.repository.load();
      if (!mounted) return;
      if (data != null) widget.vm.restoreCloudState(data);
      saved = jsonEncode(widget.vm.cloudState);
      widget.vm.addListener(changed);
      setState(() {
        ready = true;
        error = null;
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'Không đọc được dữ liệu. Kiểm tra mạng và Firestore Rules.',
        );
      }
    }
  }

  void changed() {
    if (jsonEncode(widget.vm.cloudState) == saved) return;
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 600), save);
  }

  Future<void> save() async {
    if (writing) return;
    final state = widget.vm.cloudState;
    writing = true;
    try {
      await widget.repository.save(state);
      saved = jsonEncode(state);
      if (mounted) setState(() => error = null);
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'Chưa đồng bộ thay đổi. Nhấn Thử lại trước khi đăng xuất.',
        );
      }
    } finally {
      writing = false;
    }
    if (mounted && error == null && jsonEncode(widget.vm.cloudState) != saved) {
      changed();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    widget.vm.removeListener(changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!ready) {
      return Scaffold(
        body: Center(
          child: error == null
              ? const CircularProgressIndicator()
              : TextButton(onPressed: load, child: Text('$error\nThử lại')),
        ),
      );
    }
    return Column(
      children: [
        if (error != null)
          Material(
            color: Colors.amber.shade50,
            child: SafeArea(
              bottom: false,
              child: ListTile(
                title: Text(error!),
                trailing: TextButton(
                  onPressed: save,
                  child: const Text('Thử lại'),
                ),
              ),
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
