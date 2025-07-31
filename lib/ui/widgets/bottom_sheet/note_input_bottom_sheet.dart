import 'package:flutter/material.dart';

class NoteInputBottomSheet extends StatelessWidget {
  const NoteInputBottomSheet({super.key, required this.currentNote, required this.onNoteChanged});

  final String currentNote;
  final void Function(String) onNoteChanged;

  @override
  Widget build(BuildContext context) {
    // TODO: Implement the note input bottom sheet UI
    return const Placeholder();
  }
}
