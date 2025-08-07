import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'note_form_page.dart';
import 'note_tile.dart';
import 'models/note_item.dart';
import 'note_service.dart';
import 'trash_page.dart';
import 'theme.dart';

class NoteListPage extends StatefulWidget {
  final NoteService noteService;

  const NoteListPage({Key? key, required this.noteService}) : super(key: key);

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String _selectedCategory = 'All';
  List<NoteItem> _allNotes = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSelectedCategory();
    _loadNotes();
    widget.noteService.notesStream.listen((notes) {
      setState(() {
        _allNotes = notes.where((n) => n.category != 'trashed').toList();
      });
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  Future<void> _loadSelectedCategory() async {
    final stored = await _secureStorage.read(key: 'selectedCategory');
    if (mounted) {
      setState(() {
        _selectedCategory = stored ?? 'All';
      });
    }
  }

  Future<void> _saveSelectedCategory(String category) async {
    await _secureStorage.write(key: 'selectedCategory', value: category);
  }

  void _loadNotes() {
    final notes = widget.noteService.getAllNotes();
    setState(() {
      _allNotes = notes.where((n) => n.category != 'trashed').toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _getAllCategories() {
    final cats =
        _allNotes.map((n) => n.category).toSet().toList()
          ..remove('trashed')
          ..remove('All')
          ..sort();
    return cats;
  }

  List<PopupMenuEntry<String>> _buildCategoryItems() {
    var cats = ['All', ..._getAllCategories()];
    cats = LinkedHashSet<String>.from(cats).toList();

    return cats.map((cat) {
      return PopupMenuItem<String>(value: cat, child: Text(cat, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final byCategory = _selectedCategory == 'All' ? _allNotes : _allNotes.where((note) => note.category == _selectedCategory);

    final filteredNotes =
        byCategory.where((note) {
            final q = _searchQuery.toLowerCase();
            return note.title.toLowerCase().contains(q) || note.content.toLowerCase().contains(q);
          }).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryfontColor),
        title: PopupMenuButton<String>(
          initialValue: _selectedCategory,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: AppColors.backgroundColor,
          elevation: 8,
          tooltip: 'Select Category',
          onSelected: (value) {
            setState(() {
              _selectedCategory = value;
            });
            _saveSelectedCategory(value);
          },
          itemBuilder: (context) => _buildCategoryItems(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _selectedCategory == 'All' ? 'All Notes' : _selectedCategory,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryfontColor),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, color: AppColors.primaryfontColor),
            ],
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: AppColors.secondaryfontColor,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final newNote = await Navigator.push<NoteItem>(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => NoteFormPage(
                        existingCategories: _getAllCategories(),
                        initialCategory: _selectedCategory != 'All' ? _selectedCategory : null,
                      ),
                ),
              );
              if (newNote != null) {
                widget.noteService.addNote(newNote);
                setState(() => _selectedCategory = 'All');
                _saveSelectedCategory('All');
              }
            },
            child: const Text('New note', style: TextStyle(color: AppColors.backgroundColor, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search notes...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.primaryfontColor),
                      filled: true,
                      fillColor: AppColors.secondaryfontColor.withOpacity(0.05),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.secondaryfontColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.secondaryfontColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.secondaryfontColor, width: 2),
                      ),
                    ),
                    style: const TextStyle(color: AppColors.primaryfontColor),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.primaryfontColor,
                  iconSize: 24.0,
                  padding: const EdgeInsets.all(0),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  splashRadius: 20,
                  tooltip: 'Open Trash',
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrashPage(noteService: widget.noteService))),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                filteredNotes.isEmpty
                    ? Center(child: Text("No notes found.", style: TextStyle(color: AppColors.primaryfontColor.withOpacity(0.45))))
                    : ListView.builder(
                      padding: const EdgeInsets.only(top: 0, bottom: 80),
                      itemCount: filteredNotes.length,
                      itemBuilder: (context, index) {
                        final note = filteredNotes[index];
                        return Dismissible(
                          key: Key(note.id),
                          direction: DismissDirection.endToStart,
                          background: Container(),
                          secondaryBackground: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            color: AppColors.warningColor,
                            child: const Icon(Icons.delete, color: AppColors.backgroundColor),
                          ),
                          movementDuration: const Duration(milliseconds: 250),
                          resizeDuration: const Duration(milliseconds: 200),
                          confirmDismiss: (_) async {
                            return await showDialog<bool>(
                              context: context,
                              builder:
                                  (ctx) => AlertDialog(
                                    backgroundColor: AppColors.backgroundColor,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    title: const Text(
                                      "Move to trash?",
                                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryfontColor),
                                    ),
                                    content: const Text(
                                      "This note will be moved to trash.",
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
                                        child: const Text("Trash"),
                                      ),
                                    ],
                                  ),
                            );
                          },
                          onDismissed: (_) {
                            widget.noteService.moveToTrash(note);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: const [
                                    Icon(Icons.delete_outline, color: AppColors.backgroundColor),
                                    SizedBox(width: 12),
                                    Expanded(child: Text("Note moved to trash")),
                                  ],
                                ),
                                backgroundColor: AppColors.secondaryfontColor,
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: GestureDetector(
                            onTap: () async {
                              final updatedNote = await Navigator.push<NoteItem>(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => NoteFormPage(
                                        existingCategories: _getAllCategories(),
                                        initialNote: note,
                                        initialCategory: note.category != 'All' ? note.category : null,
                                      ),
                                ),
                              );
                              if (updatedNote != null) {
                                widget.noteService.updateNote(updatedNote);
                              }
                            },
                            child: NoteTile(note: note),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
