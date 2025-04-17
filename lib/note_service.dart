import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'models/note_item.dart';

class NoteService {
  static const String boxName = 'notesBox';
  static const String secureKeyName = 'hiveEncryptionKey';

  final _noteController = StreamController<List<NoteItem>>.broadcast(
    sync: true,
  );
  late Box<NoteItem> _box;

  Stream<List<NoteItem>> get notesStream => _noteController.stream;

  final _secureStorage = const FlutterSecureStorage();

  Future<void> init() async {
    final encryptionKey = await _getOrCreateEncryptionKey();

    _box = await Hive.openBox<NoteItem>(
      boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );

    await cleanOldTrash();
    _noteController.add(_box.values.toList());
  }

  Future<List<int>> _getOrCreateEncryptionKey() async {
    String? encodedKey = await _secureStorage.read(key: secureKeyName);

    if (encodedKey == null) {
      final newKey = Hive.generateSecureKey();
      encodedKey = base64UrlEncode(newKey);
      await _secureStorage.write(key: secureKeyName, value: encodedKey);
    }

    return base64Url.decode(encodedKey);
  }

  void addNote(NoteItem note) {
    _box.put(note.id, note);
    _noteController.add(_box.values.toList());
  }

  void updateNote(NoteItem updatedNote) {
    _box.put(updatedNote.id, updatedNote);
    _noteController.add(_box.values.toList());
  }

  void moveToTrash(NoteItem note) {
    final trashedNote = NoteItem(
      id: note.id,
      title: note.title,
      content: note.content,
      category: 'trashed',
      createdAt: note.createdAt,
      customFields: {...note.customFields, 'previousCategory': note.category},
    );
    _box.put(trashedNote.id, trashedNote);
    _noteController.add(_box.values.toList());
  }

  void restoreFromTrash(NoteItem note) {
    final previousCategory =
        note.customFields['previousCategory'] ?? 'Restored';

    final cleanedFields = {...note.customFields}..remove('previousCategory');

    final restoredNote = NoteItem(
      id: note.id,
      title: note.title,
      content: note.content,
      category: previousCategory,
      createdAt: note.createdAt,
      customFields: cleanedFields,
    );

    _box.put(restoredNote.id, restoredNote);
    _noteController.add(_box.values.toList());
  }

  void deletePermanently(String id) {
    _box.delete(id);
    _noteController.add(_box.values.toList());
  }

  Future<void> cleanOldTrash() async {
    final now = DateTime.now();
    final toDelete =
        _box.values.where((note) {
          return note.category == 'trashed' &&
              now.difference(note.createdAt).inDays >= 30;
        }).toList();

    for (final note in toDelete) {
      await _box.delete(note.id);
    }

    _noteController.add(_box.values.toList());
  }

  List<NoteItem> getAllNotes() => _box.values.toList();

  void dispose() {
    _noteController.close();
    _box.close();
  }
}
