import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class NoteInputBottomSheet extends StatefulWidget {
  const NoteInputBottomSheet({super.key, required this.currentNote, required this.onNoteChanged});

  final String currentNote;
  final void Function(String) onNoteChanged;

  @override
  State<NoteInputBottomSheet> createState() => _NoteInputBottomSheetState();
}

class _NoteInputBottomSheetState extends State<NoteInputBottomSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController(text: widget.currentNote);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keyboard dismiss overlay — Pressable exception.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => ViewUtils.hideKeyboard(context),
      child: CommonPickerSheet(
        title: S.current.editNote,
        actions: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CommonButton(
              compact: true,
              text: S.current.save,
              onTap: () {
                widget.onNoteChanged(_controller.text);
                context.read<AppNavigator>().pop();
              },
            ),
            SizedBox(width: Dimens.d8.responsive()),
            CommonButton(
              compact: true,
              text: S.current.cancel,
              backgroundColor: surfaceColor,
              textColor: blackColor,
              onTap: () => context.read<AppNavigator>().pop(),
            ),
          ],
        ),
        child: CommonTextField(
          controller: _controller,
          maxLines: 8,
          contentPadding: EdgeInsets.symmetric(
            vertical: Dimens.d12.responsive(),
            horizontal: Dimens.d12.responsive(),
          ),
          hintText: S.current.createNoteHere,
        ),
      ),
    );
  }
}
