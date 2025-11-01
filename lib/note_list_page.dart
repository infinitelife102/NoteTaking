import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'note_form_page.dart';
import 'note_tile.dart';
import 'models/note_item.dart';
import 'note_service.dart';
import 'trash_page.dart';
import 'theme_provider.dart';

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
  bool _isSearching = false;

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
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
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
                decoration: BoxDecoration(color: theme.colorScheme.onSurface.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
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
                      color: theme.colorScheme.onSurface,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: theme.colorScheme.surface, width: 2) : null,
                    ),
                  ),
                  title: Text(
                    category,
                    style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: theme.colorScheme.onSurface.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      '$noteCount',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500),
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: theme.colorScheme.onSurface.withOpacity(0.05),
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

  void _showThemeBottomSheet() {
    final theme = Theme.of(context);
    Provider.of<ThemeProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                decoration: BoxDecoration(color: theme.colorScheme.onSurface.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Theme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              ),

              Consumer<ThemeProvider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      for (AppThemeMode themeMode in AppThemeMode.values) ...[
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                          leading: Icon(_getThemeIcon(themeMode), color: theme.colorScheme.onSurface),
                          title: Text(
                            _getThemeDisplayName(themeMode),
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: provider.themeMode == themeMode ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          trailing: provider.themeMode == themeMode ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
                          selected: provider.themeMode == themeMode,
                          selectedTileColor: theme.colorScheme.onSurface.withOpacity(0.05),
                          onTap: () {
                            provider.setThemeMode(themeMode);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 40),
            ],
          ),
        );
      },
    );
  }

  IconData _getThemeIcon(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  String _getThemeDisplayName(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }

  Widget _buildSimpleNotesList(List<NoteItem> filteredNotes) {
    final theme = Theme.of(context);
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 0, right: 0, top: 8, bottom: 160),
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
              decoration: BoxDecoration(color: theme.colorScheme.error, borderRadius: BorderRadius.circular(25)),
              child: Icon(CupertinoIcons.delete, color: theme.colorScheme.onError),
            ),
            movementDuration: const Duration(milliseconds: 250),
            resizeDuration: const Duration(milliseconds: 200),
            confirmDismiss: (_) async {
              return await showModalBottomSheet<bool>(
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
                            'Move to trash?',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'This note will be moved to trash.',
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
                                  child: const Text("Trash", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search notes...',
                    hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 16),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.4), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 18),
                  cursorColor: theme.colorScheme.onSurface,
                )
                : GestureDetector(
                  onTap: () {
                    _showThemeBottomSheet();
                  },
                  child: Text('Wisdom', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                ),
        centerTitle: false,
        leading:
            _isSearching
                ? IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                    });
                  },
                )
                : null,
        actions: [
          if (!_isSearching) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Text(
                  '${filteredNotes.length} ${filteredNotes.length == 1 ? 'note' : 'notes'}',
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          ] else ...[
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                },
              ),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: Stack(
        children: [
          filteredNotes.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _searchQuery.isNotEmpty ? CupertinoIcons.search : CupertinoIcons.doc_text,
                      size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isNotEmpty ? "No notes found for '$_searchQuery'" : "No notes yet",
                      style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _searchQuery.isNotEmpty ? "Try different keywords" : "Tap + to create your first note",
                      style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 14),
                    ),
                  ],
                ),
              )
              : _buildSimpleNotesList(filteredNotes),

          if (!_isSearching)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 140,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.scaffoldBackgroundColor.withOpacity(0.0),
                      theme.scaffoldBackgroundColor.withOpacity(0.3),
                      theme.scaffoldBackgroundColor.withOpacity(0.7),
                      theme.scaffoldBackgroundColor.withOpacity(0.9),
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
              ),
            ),

          if (!_isSearching)
            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(25)),
                    child: IconButton(
                      onPressed:
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrashPage(noteService: widget.noteService))),
                      icon: Icon(CupertinoIcons.delete, color: theme.colorScheme.onPrimary),
                      iconSize: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: _showCategoryBottomSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(25)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(color: theme.colorScheme.onPrimary, shape: BoxShape.circle),
                            ),
                            Expanded(
                              child: Text(
                                _selectedCategory == 'All' ? 'All Notes' : _selectedCategory,
                                style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onPrimary, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(CupertinoIcons.chevron_up, color: theme.colorScheme.onPrimary, size: 18),
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
                      decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(25)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.add, color: theme.colorScheme.onPrimary, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'New note',
                            style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onPrimary, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
