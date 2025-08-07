import 'dart:ui';
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
    final hasMedia = note.mediaData.isNotEmpty;

    return Card(
      color: hasMedia ? Colors.transparent : AppColors.secondaryfontColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  Positioned.fill(child: Container(color: AppColors.secondaryfontColor.withOpacity(0.6))),
                  _buildListTile(dateStr),
                ],
              )
              : _buildListTile(dateStr),
    );
  }

  Widget _buildListTile(String dateStr) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.backgroundColor)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.backgroundColor)),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(note.category, style: const TextStyle(fontSize: 12, color: AppColors.backgroundColor)),
          const SizedBox(height: 4),
          Text(dateStr, style: const TextStyle(fontSize: 10, color: AppColors.backgroundColor)),
        ],
      ),
    );
  }
}
