import 'package:flutter/material.dart';

import '../models/note.dart';

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({
    super.key,
    this.initialNote,
  });

  final Note? initialNote;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _isSaving = false;

  bool get _isNew => widget.initialNote == null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialNote?.title ?? '');
    _contentController = TextEditingController(
      text: widget.initialNote?.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _autoSaveAndPop() async {
    if (_isSaving) {
      return;
    }
    _isSaving = true;

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      if (mounted) {
        Navigator.of(context).pop<Note?>(null);
      }
      return;
    }

    final now = DateTime.now();
    final note = (_isNew
            ? Note(
                id: now.microsecondsSinceEpoch.toString(),
                title: title,
                content: content,
                createdAt: now,
                updatedAt: now,
              )
            : widget.initialNote!.copyWith(
                title: title,
                content: content,
                updatedAt: now,
              ))
        .copyWith();

    if (mounted) {
      Navigator.of(context).pop<Note>(note);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        await _autoSaveAndPop();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _autoSaveAndPop,
          ),
          title: Text(_isNew ? 'Tạo ghi chú' : 'Chỉnh sửa ghi chú'),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                decoration: const InputDecoration(
                  hintText: 'Tiêu đề',
                  border: InputBorder.none,
                ),
              ),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: 'Nhập nội dung ghi chú...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
