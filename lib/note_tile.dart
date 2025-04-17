import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/note_item.dart';
import 'theme.dart';

class NoteTile extends StatelessWidget {
  final NoteItem note;

  const NoteTile({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat.yMd().add_Hm().format(note.createdAt);

    return Card(
      color: AppColors.grey850,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        title: Text(
          note.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            note.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.white),
          ),
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              note.category,
              style: const TextStyle(fontSize: 12, color: AppColors.white),
            ),
            const SizedBox(height: 4),
            Text(
              dateStr,
              style: const TextStyle(fontSize: 10, color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}
