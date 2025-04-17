import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'models/note_item.dart';
import 'theme.dart';

class NoteFormPage extends StatefulWidget {
  final List<String> existingCategories;
  final NoteItem? initialNote;
  final String? initialCategory;

  const NoteFormPage({
    super.key,
    required this.existingCategories,
    this.initialNote,
    this.initialCategory,
  });

  @override
  State<NoteFormPage> createState() => _NoteFormPageState();
}

class _NoteFormPageState extends State<NoteFormPage> {
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _selectedCategory = '';
  bool _autofocus = true;
  bool _showSave = false;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    final note = widget.initialNote;
    if (note != null) {
      _noteController.text = '${note.title}\n${note.content}';
      _selectedCategory = note.category;
      _autofocus = false;
      _showSave = false;
    } else {
      _selectedCategory =
          widget.initialCategory ??
          (widget.existingCategories.isNotEmpty
              ? widget.existingCategories.first
              : 'General');
      _autofocus = true;
      _showSave = true;
    }

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && !_showSave) {
        setState(() => _showSave = true);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _extractTitle(String text) {
    final lines = text.trim().split('\n');
    return (lines.isNotEmpty && lines.first.trim().isNotEmpty)
        ? lines.first.trim()
        : 'Untitled';
  }

  void _saveNote() {
    final lines = _noteController.text.trim().split('\n');
    final title = lines.isNotEmpty ? lines.first.trim() : '';
    final content = lines.length > 1 ? lines.sublist(1).join('\n').trim() : '';

    final note = NoteItem(
      id: widget.initialNote?.id ?? _uuid.v4(),
      title: title,
      content: content,
      category: _selectedCategory.trim(),
      createdAt: widget.initialNote?.createdAt ?? DateTime.now(),
      customFields: Map<String, String>.from(
        widget.initialNote?.customFields ?? {},
      ),
    );

    Navigator.pop(context, note);
  }

  Future<String?> _promptForCategory() async {
    String? newCategory;
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final controller = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Create New Category"),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: "Enter category name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Add"),
              onPressed: () => Navigator.pop(context, controller.text.trim()),
            ),
          ],
        );
      },
    ).then((value) => newCategory = value);
    return newCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _noteController,
          builder: (context, value, child) {
            final dynamicTitle = _extractTitle(value.text);
            return AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              foregroundColor: AppColors.black,
              titleSpacing: 16,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dynamicTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _selectedCategory,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              actions: [
                PopupMenuButton<String>(
                  initialValue: _selectedCategory,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: AppColors.white,
                  elevation: 8,
                  icon: const Icon(
                    Icons.category_outlined,
                    color: AppColors.black,
                  ),
                  tooltip: "Select Category",
                  onSelected: (value) async {
                    if (value == 'New Category') {
                      final newCategory = await _promptForCategory();
                      if (newCategory != null &&
                          newCategory.trim().isNotEmpty) {
                        setState(() => _selectedCategory = newCategory.trim());
                      }
                    } else {
                      setState(() => _selectedCategory = value);
                    }
                  },
                  itemBuilder:
                      (context) => <PopupMenuEntry<String>>[
                        for (final cat in widget.existingCategories)
                          PopupMenuItem<String>(
                            value: cat,
                            child: Text(
                              cat,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        const PopupMenuDivider(),
                        const PopupMenuItem<String>(
                          value: 'New Category',
                          child: Text(
                            "➕ New Category",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                ),
                const SizedBox(width: 8),
              ],
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _noteController,
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  hintText: "Start writing...",
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 16, color: AppColors.black),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                autofocus: _autofocus,
                cursorColor: AppColors.black,
                scrollPhysics: const BouncingScrollPhysics(),
              ),
            ),
            const SizedBox(height: 12),
            if (_showSave)
              Padding(
                padding: const EdgeInsets.only(bottom: 48),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveNote,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: AppColors.grey850,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                    ),
                    child: const Text(
                      "Save Note",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
