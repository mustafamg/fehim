import 'package:flutter/material.dart';
import 'package:holy_quran/generated/l10n.dart';
import 'package:holy_quran/values/values_manager.dart';

class ResetProgressDialog extends StatelessWidget {
  const ResetProgressDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: EdgeInsets.fromLTRB(
        WidgetWidth.w24,
        WidgetHeight.h24,
        WidgetWidth.w24,
        WidgetHeight.h8,
      ),
      contentPadding: EdgeInsets.fromLTRB(
        WidgetWidth.w24,
        0,
        WidgetWidth.w24,
        WidgetHeight.h24,
      ),
      actionsPadding: EdgeInsets.fromLTRB(
        WidgetWidth.w16,
        0,
        WidgetWidth.w16,
        WidgetHeight.h16,
      ),
      title: Text(
        S.current.resetProgressTitle,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(S.current.resetProgressMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(S.current.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(S.current.resetProgressAction),
        ),
      ],
    );
  }
}
