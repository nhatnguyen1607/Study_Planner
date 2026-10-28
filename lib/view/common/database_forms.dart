import 'package:flutter/material.dart';

import '../../model/study_record.dart';

class DataInput {
  const DataInput(
    this.key,
    this.label, {
    this.value = '',
    this.required = false,
    this.numeric = false,
    this.max = 200,
    this.lines = 1,
  });
  final String key, label, value;
  final bool required, numeric;
  final int max, lines;
}

/// Retains text on Firestore errors. Dialog closes only after an acknowledged write.
Future<bool?> editData(
  BuildContext context, {
  required String title,
  required List<DataInput> fields,
  required Future<String?> Function(Map<String, String>) save,
}) => showDialog<bool>(
  context: context,
  barrierDismissible: false,
  builder: (_) => _DataDialog(title: title, fields: fields, save: save),
);

class _DataDialog extends StatefulWidget {
  const _DataDialog({
    required this.title,
    required this.fields,
    required this.save,
  });
  final String title;
  final List<DataInput> fields;
  final Future<String?> Function(Map<String, String>) save;
  @override
  State<_DataDialog> createState() => _DataDialogState();
}

class _DataDialogState extends State<_DataDialog> {
  final form = GlobalKey<FormState>();
  late final controllers = {
    for (final f in widget.fields) f.key: TextEditingController(text: f.value),
  };
  bool busy = false;
  String? error;
  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final f in widget.fields)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: controllers[f.key],
                      enabled: !busy,
                      maxLength: f.max,
                      maxLines: f.lines,
                      keyboardType: f.numeric
                          ? const TextInputType.numberWithOptions(decimal: true)
                          : TextInputType.text,
                      decoration: InputDecoration(
                        labelText: f.label,
                        counterText: '',
                      ),
                      validator: (v) => f.required && (v ?? '').trim().isEmpty
                          ? 'Vui lòng nhập ${f.label.toLowerCase()}'
                          : null,
                    ),
                  ),
                if (error != null)
                  Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.pop(context, false),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: busy
              ? null
              : () async {
                  if (!form.currentState!.validate()) return;
                  setState(() {
                    busy = true;
                    error = null;
                  });
                  try {
                    final result = await widget.save({
                      for (final e in controllers.entries)
                        e.key: e.value.text.trim(),
                    });
                    if (!context.mounted) return;
                    if (result == null) {
                      Navigator.pop(context, true);
                    } else {
                      setState(() => error = result);
                    }
                  } catch (e) {
                    if (mounted) {
                      setState(
                        () => error = e is DataFailure
                            ? e.toString()
                            : 'Không thể lưu dữ liệu. Vui lòng thử lại.',
                      );
                    }
                  } finally {
                    if (mounted) setState(() => busy = false);
                  }
                },
          child: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Lưu'),
        ),
      ],
    ),
  );
}
