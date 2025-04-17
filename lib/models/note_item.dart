import 'package:hive/hive.dart';

part 'note_item.g.dart';

@HiveType(typeId: 0)
class NoteItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final Map<String, dynamic> customFields;

  NoteItem({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.createdAt,
    required this.customFields,
  });
}
