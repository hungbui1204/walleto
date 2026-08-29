import 'package:flutter/material.dart';
import 'package:walleto/di/di.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class NoteInputBottomSheet extends StatefulWidget {
  const NoteInputBottomSheet({
    super.key,
    required this.currentNote,
    required this.onNoteChanged,
  });

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
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => ViewUtils.hideKeyboard(context),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(Dimens.d16.responsive()),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(S.current.editNote, style: AppTextStyles.s18wBoldBlack()),
              SizedBox(height: Dimens.d20.responsive()),
              CommonTextField(
                controller: _controller,
                maxLines: 8,
                contentPadding: EdgeInsets.symmetric(
                  vertical: Dimens.d12.responsive(),
                  horizontal: Dimens.d12.responsive(),
                ),
                hintText: S.current.createNoteHere,
              ),
              SizedBox(height: Dimens.d40.responsive()),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CommonButton(
                    compact: true,
                    text: S.current.save,
                    onTap: () {
                      widget.onNoteChanged.call(_controller.text);

                      getIt.get<AppNavigator>().pop();
                    },
                  ),
                  SizedBox(width: Dimens.d8.responsive()),
                  CommonButton(
                    compact: true,
                    text: S.current.cancel,
                    backgroundColor: surfaceColor,
                    textColor: blackColor,
                    onTap: () => getIt.get<AppNavigator>().pop(),
                  ),
                ],
              ),
              SizedBox(height: Dimens.d32.responsive()),
            ],
          ),
        ),
      ),
    );
  }
}
