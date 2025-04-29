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
        noteService
            .getAllNotes()
            .where((note) => note.category == 'trashed')
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.black),
        title: const Text(
          "Trash",
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.black),
        ),
      ),
      body:
          trashedNotes.isEmpty
              ? Center(
                child: Text(
                  "Trash is empty.",
                  style: TextStyle(color: AppColors.black.withOpacity(0.45)),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: trashedNotes.length,
                itemBuilder: (context, index) {
                  final note = trashedNotes[index];
                  return Dismissible(
                    key: Key(note.id),
                    direction: DismissDirection.horizontal,
                    background: Container(
                      color: AppColors.green,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.restore, color: AppColors.white),
                    ),
                    secondaryBackground: Container(
                      color: AppColors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(
                        Icons.delete_forever,
                        color: AppColors.white,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        noteService.restoreFromTrash(note);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: const [
                                Icon(Icons.restore, color: AppColors.white),
                                SizedBox(width: 12),
                                Expanded(child: Text("Note restored")),
                              ],
                            ),
                            backgroundColor: AppColors.green,
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        return true;
                      } else if (direction == DismissDirection.endToStart) {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (ctx) => AlertDialog(
                                backgroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: const Text(
                                  "Delete permanently?",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black,
                                  ),
                                ),
                                content: const Text(
                                  "This note will be deleted forever.",
                                  style: TextStyle(color: AppColors.black),
                                ),
                                actionsPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.black
                                          .withOpacity(0.7),
                                    ),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.red,
                                      foregroundColor: AppColors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                        );
                        if (confirm == true) {
                          noteService.deletePermanently(note.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: const [
                                  Icon(
                                    Icons.delete_forever,
                                    color: AppColors.white,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text("Note deleted permanently"),
                                  ),
                                ],
                              ),
                              backgroundColor: AppColors.red,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
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
