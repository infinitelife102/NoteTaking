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

class _NoteListPageState extends State<NoteListPage> with TickerProviderStateMixin {
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

  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
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
                decoration: BoxDecoration(color: AppColors.secondaryfontColor.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryfontColor)),
              ),

              ...['All', ..._getAllCategories()].map((category) {
                final isSelected = _selectedCategory == category;
                final noteCount = category == 'All' ? _allNotes.length : _allNotes.where((n) => n.category == category).length;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  leading: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryfontColor,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                    ),
                  ),
                  title: Text(
                    category,
                    style: TextStyle(color: AppColors.primaryfontColor, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryfontColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$noteCount',
                      style: TextStyle(fontSize: 12, color: AppColors.secondaryfontColor, fontWeight: FontWeight.w500),
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: AppColors.secondaryfontColor.withOpacity(0.05),
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                    _saveSelectedCategory(category);
                    Navigator.pop(context);
                  },
                );
              }).toList(),

              const SizedBox(height: 20),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryfontColor,
        borderRadius: BorderRadius.zero,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                hintStyle: TextStyle(color: AppColors.backgroundColor.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.search, color: AppColors.backgroundColor),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.close),
                          color: AppColors.backgroundColor,
                          onPressed: () => _searchController.clear(),
                        )
                        : null,
                filled: true,
                fillColor: AppColors.backgroundColor.withOpacity(0.1),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: AppColors.backgroundColor.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: AppColors.backgroundColor, width: 2),
                ),
              ),
              style: const TextStyle(color: AppColors.backgroundColor),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration: BoxDecoration(color: AppColors.backgroundColor.withOpacity(0.15), borderRadius: BorderRadius.circular(25)),
                  child: IconButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrashPage(noteService: widget.noteService))),
                    icon: const Icon(Icons.delete_outline, color: AppColors.backgroundColor),
                    iconSize: 24,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: _showCategoryBottomSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: AppColors.backgroundColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(color: AppColors.backgroundColor, shape: BoxShape.circle),
                          ),
                          Expanded(
                            child: Text(
                              _selectedCategory == 'All' ? 'All Notes' : _selectedCategory,
                              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.backgroundColor, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_up, color: AppColors.backgroundColor, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                GestureDetector(
                  onTap: () async {
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
                      setState(() {
                        _selectedCategory = 'All';
                      });
                      _saveSelectedCategory('All');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(color: AppColors.backgroundColor, borderRadius: BorderRadius.circular(25)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: AppColors.secondaryfontColor, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'New note',
                          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.secondaryfontColor, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 40),
        ],
      ),
    );
  }

  Widget _buildSimpleNotesList(List<NoteItem> filteredNotes) {
    return Container(
      color: AppColors.backgroundColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
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
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.warningColor, borderRadius: BorderRadius.circular(12)),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      title: const Text("Move to trash?", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryfontColor)),
                      content: const Text("This note will be moved to trash.", style: TextStyle(color: AppColors.primaryfontColor)),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          child: const Text("Trash"),
                        ),
                      ],
                    ),
              );
            },
            onDismissed: (_) {
              widget.noteService.moveToTrash(note);
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
    );
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
        scrolledUnderElevation: 0,
        title: Text('Wisdom', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryfontColor, fontSize: 24)),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${filteredNotes.length} ${filteredNotes.length == 1 ? 'note' : 'notes'}',
                style: TextStyle(color: AppColors.primaryfontColor.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                filteredNotes.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchQuery.isNotEmpty ? Icons.search_off : Icons.note_add_outlined,
                            size: 64,
                            color: AppColors.primaryfontColor.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty ? "No notes found for '$_searchQuery'" : "No notes yet",
                            style: TextStyle(color: AppColors.primaryfontColor.withOpacity(0.6), fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isNotEmpty ? "Try different keywords" : "Tap + to create your first note",
                            style: TextStyle(color: AppColors.primaryfontColor.withOpacity(0.4), fontSize: 14),
                          ),
                        ],
                      ),
                    )
                    : _buildSimpleNotesList(filteredNotes),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }
}
