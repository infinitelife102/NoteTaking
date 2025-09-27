import 'package:flutter/material.dart';
import 'note_service.dart';
import 'note_tile.dart';
import 'theme.dart';

class TrashPage extends StatelessWidget {
  final NoteService noteService;

  const TrashPage({super.key, required this.noteService});

  @override
  Widget build(BuildContext context) {
    final trashedNotes =
        noteService.getAllNotes().where((note) => note.category == 'trashed').toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryfontColor),
        title: const Text("Trash", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryfontColor)),
      ),
      body:
          trashedNotes.isEmpty
              ? Center(child: Text("Trash is empty.", style: TextStyle(color: AppColors.primaryfontColor.withOpacity(0.45))))
              : ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: trashedNotes.length,
                itemBuilder: (context, index) {
                  final note = trashedNotes[index];
                  return Dismissible(
                    key: Key(note.id),
                    direction: DismissDirection.horizontal,
                    background: Container(
                      color: AppColors.successColor,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.restore, color: AppColors.backgroundColor),
                    ),
                    secondaryBackground: Container(
                      color: AppColors.warningColor,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete_forever, color: AppColors.backgroundColor),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        noteService.restoreFromTrash(note);

                        return true;
                      } else if (direction == DismissDirection.endToStart) {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (ctx) => AlertDialog(
                                backgroundColor: AppColors.backgroundColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: const Text(
                                  "Delete permanently?",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryfontColor),
                                ),
                                content: const Text(
                                  "This note will be deleted forever.",
                                  style: TextStyle(color: AppColors.primaryfontColor),
                                ),
                                actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    style: TextButton.styleFrom(foregroundColor: AppColors.primaryfontColor.withOpacity(0.7)),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.warningColor,
                                      foregroundColor: AppColors.backgroundColor,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                        );
                        if (confirm == true) {
                          noteService.deletePermanently(note.id);

                          return true;
                        }
                      }
                      return false;
                    },
                    child: NoteTile(note: note),
                  );
                },
              ),
    );
  }
}
