import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../models/note.dart';
import '../services/note_storage_service.dart';
import '../widgets/empty_notes_state.dart';
import '../widgets/note_card.dart';
import '../widgets/note_search_bar.dart';
import 'note_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _appBarTitle = 'Smart Note - Đặng Phương Hải - 2351060439';

  final NoteStorageService _storageService = NoteStorageService();
  final List<Note> _notes = [];
  bool _isLoading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await _storageService.loadNotes();
    if (!mounted) {
      return;
    }
    setState(() {
      _notes
        ..clear()
        ..addAll(notes);
      _isLoading = false;
    });
  }

  Future<void> _upsertAndSave(Note note) async {
    final index = _notes.indexWhere((item) => item.id == note.id);
    if (index >= 0) {
      _notes[index] = note;
    } else {
      _notes.add(note);
    }
    _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    await _storageService.saveNotes(_notes);
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _openEditor({Note? note}) async {
    final result = await Navigator.of(context).push<Note?>(
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(initialNote: note),
      ),
    );

    if (result == null) {
      return;
    }

    await _upsertAndSave(result);
  }

  Future<bool> _confirmDelete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa ghi chú này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _deleteNote(Note note) async {
    _notes.removeWhere((item) => item.id == note.id);
    await _storageService.saveNotes(_notes);
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  List<Note> get _filteredNotes {
    final keyword = _query.trim().toLowerCase();
    if (keyword.isEmpty) {
      return _notes;
    }
    return _notes
        .where((note) => note.title.toLowerCase().contains(keyword))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final visibleNotes = _filteredNotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text(_appBarTitle),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          NoteSearchBar(
            onChanged: (value) {
              setState(() {
                _query = value;
              });
            },
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : visibleNotes.isEmpty
                    ? const EmptyNotesState()
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                        child: MasonryGridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          itemCount: visibleNotes.length,
                          itemBuilder: (context, index) {
                            final note = visibleNotes[index];
                            return Dismissible(
                              key: ValueKey(note.id),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (_) => _confirmDelete(),
                              onDismissed: (_) => _deleteNote(note),
                              background: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              child: NoteCard(
                                note: note,
                                onTap: () => _openEditor(note: note),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
