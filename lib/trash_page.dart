import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'note_service.dart';
import 'note_tile.dart';

class TrashPage extends StatelessWidget {
  final NoteService noteService;

  const TrashPage({super.key, required this.noteService});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trashedNotes =
        noteService.getAllNotes().where((note) => note.category == 'trashed').toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text("Trash", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: false,
      ),
      body:
          trashedNotes.isEmpty
              ? Center(child: Text("Trash is empty.", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))))
              : ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: trashedNotes.length,
                itemBuilder: (context, index) {
                  final note = trashedNotes[index];
                  return Dismissible(
                    key: Key(note.id),
                    direction: DismissDirection.horizontal,
                    background: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(25)),
                      child: Icon(CupertinoIcons.refresh_circled, color: theme.colorScheme.onPrimary),
                    ),
                    secondaryBackground: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: theme.colorScheme.error, borderRadius: BorderRadius.circular(25)),
                      child: Icon(CupertinoIcons.delete_solid, color: theme.colorScheme.onError),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        noteService.restoreFromTrash(note);
                        return true;
                      } else if (direction == DismissDirection.endToStart) {
                        final confirm = await showModalBottomSheet<bool>(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (ctx) {
                            return Container(
                              decoration: BoxDecoration(
                                color: theme.scaffoldBackgroundColor,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 4,
                                    margin: const EdgeInsets.only(top: 12),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Text(
                                      'Delete permanently?',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Text(
                                      'This note will be deleted forever.',
                                      style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextButton(
                                            onPressed: () => Navigator.pop(ctx, false),
                                            style: TextButton.styleFrom(
                                              foregroundColor: theme.colorScheme.onSurface.withOpacity(0.7),
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(25),
                                                side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.2)),
                                              ),
                                            ),
                                            child: const Text("Cancel", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => Navigator.pop(ctx, true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: theme.colorScheme.primary,
                                              foregroundColor: theme.colorScheme.onPrimary,
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                            ),
                                            child: const Text("Delete", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 20),
                                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 40),
                                ],
                              ),
                            );
                          },
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
