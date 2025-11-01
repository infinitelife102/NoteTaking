import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/note_item.dart';

class NoteTile extends StatelessWidget {
  final NoteItem note;

  const NoteTile({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat.yMd().add_Hm().format(note.createdAt);
    final hasMedia = note.mediaData.isNotEmpty;

    return Card(
      color: hasMedia ? Colors.transparent : theme.colorScheme.surface,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      clipBehavior: hasMedia ? Clip.antiAlias : Clip.none,
      child:
          hasMedia
              ? Stack(
                children: [
                  Positioned.fill(
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Image.memory(note.mediaData.first, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned.fill(child: Container(color: theme.colorScheme.surface.withOpacity(0.7))),
                  _buildListTile(dateStr, theme),
                ],
              )
              : _buildListTile(dateStr, theme),
    );
  }

  Widget _buildListTile(String dateStr, ThemeData theme) {
    final textColor = theme.colorScheme.onBackground;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      title: Text(note.title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor)),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(note.category, style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.7))),
          const SizedBox(height: 4),
          Text(dateStr, style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.6))),
        ],
      ),
    );
  }
}
