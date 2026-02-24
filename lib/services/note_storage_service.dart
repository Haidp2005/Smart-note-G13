import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';

class NoteStorageService {
  static const String _notesKey = 'smart_notes';

  Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_notesKey);

    if (raw == null || raw.isEmpty) {
      return [];
    }

    final List<dynamic> jsonList = jsonDecode(raw) as List<dynamic>;
    final notes = jsonList
        .map((item) => Note.fromMap(item as Map<String, dynamic>))
        .toList();

    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(notes.map((note) => note.toMap()).toList());
    await prefs.setString(_notesKey, encoded);
  }
}
