import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'models/note_item.dart';

class NoteService {
  static const String boxName = 'notesBox';
  static const String secureKeyName = 'hiveEncryptionKey';

  final _noteController = StreamController<List<NoteItem>>.broadcast(sync: true);
  late Box<NoteItem> _box;
  final _secureStorage = const FlutterSecureStorage();

  Stream<List<NoteItem>> get notesStream => _noteController.stream;

  Future<void> init() async {
    final encryptionKey = await _getOrCreateEncryptionKey();
    _box = await Hive.openBox<NoteItem>(boxName, encryptionCipher: HiveAesCipher(encryptionKey));
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
    final trashed = NoteItem(
      id: note.id,
      title: note.title,
      content: note.content,
      category: 'trashed',
      createdAt: note.createdAt,
      customFields: {...note.customFields, 'previousCategory': note.category},
      mediaData: List<Uint8List>.from(note.mediaData),
    );
    _box.put(trashed.id, trashed);
    _noteController.add(_box.values.toList());
  }

  void restoreFromTrash(NoteItem note) {
    final prevCat = note.customFields['previousCategory'] as String? ?? 'All';
    final cleanedFields = {...note.customFields}..remove('previousCategory');

    final restored = NoteItem(
      id: note.id,
      title: note.title,
      content: note.content,
      category: prevCat,
      createdAt: note.createdAt,
      customFields: cleanedFields,
      mediaData: List<Uint8List>.from(note.mediaData),
    );
    _box.put(restored.id, restored);
    _noteController.add(_box.values.toList());
  }

  void deletePermanently(String id) {
    _box.delete(id);
    _noteController.add(_box.values.toList());
  }

  List<NoteItem> getAllNotes() => _box.values.toList();

  void dispose() {
    _noteController.close();
    _box.close();
  }
}
