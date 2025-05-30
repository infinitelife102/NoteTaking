import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'models/note_item.dart';
import 'theme.dart';

class NoteFormPage extends StatefulWidget {
  final List<String> existingCategories;
  final NoteItem? initialNote;
  final String? initialCategory;

  const NoteFormPage({
    Key? key,
    required this.existingCategories,
    this.initialNote,
    this.initialCategory,
  }) : super(key: key);

  @override
  State<NoteFormPage> createState() => _NoteFormPageState();
}

class _NoteFormPageState extends State<NoteFormPage> {
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  final List<Uint8List> _mediaData = [];
  final _uuid = const Uuid();

  String _selectedCategory = '';
  bool _autofocus = true;
  bool _showSave = false;

  @override
  void initState() {
    super.initState();
    final note = widget.initialNote;
    if (note != null) {
      _noteController.text = '${note.title}\n${note.content}';
      _selectedCategory = note.category;
      _mediaData.addAll(note.mediaData);
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

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      final bytes = await File(picked.path).readAsBytes();
      setState(() {
        _mediaData.add(bytes);
        _showSave = true;
      });
    }
  }

  String _extractTitle(String text) {
    final lines = text.trim().split('\n');
    return (lines.isNotEmpty && lines.first.trim().isNotEmpty)
        ? lines.first.trim()
        : 'Untitled';
  }

  Future<String?> _promptForCategory() async {
    String? newCategory;
    await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Create new category",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: AppColors.black),
            decoration: InputDecoration(
              hintText: "Enter category name",
              hintStyle: TextStyle(color: AppColors.black.withOpacity(0.4)),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.grey, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppColors.grey.withOpacity(0.05),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.black.withOpacity(0.7),
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.grey,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Add"),
            ),
          ],
        );
      },
    ).then((value) => newCategory = value);
    return newCategory;
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
      customFields: Map<String, dynamic>.from(
        widget.initialNote?.customFields ?? {},
      ),
      mediaData: _mediaData,
    );

    Navigator.pop(context, note);
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
                      final newCat = await _promptForCategory();
                      if (newCat != null && newCat.isNotEmpty) {
                        setState(() => _selectedCategory = newCat);
                      }
                    } else {
                      setState(() => _selectedCategory = value);
                    }
                  },
                  itemBuilder:
                      (_) => [
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
                IconButton(
                  icon: const Icon(
                    Icons.add_photo_alternate_outlined,
                    color: AppColors.black,
                  ),
                  tooltip: "Add Image",
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: AppColors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder:
                          (_) => SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                20,
                                20,
                                30,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(
                                      Icons.photo_camera,
                                      color: AppColors.grey,
                                    ),
                                    title: const Text(
                                      "Take Photo",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    textColor: AppColors.black,
                                    onTap: () {
                                      Navigator.pop(context);
                                      _pickImage(ImageSource.camera);
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  ListTile(
                                    leading: Icon(
                                      Icons.photo_library,
                                      color: AppColors.grey,
                                    ),
                                    title: const Text(
                                      "Choose from Gallery",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    textColor: AppColors.black,
                                    onTap: () {
                                      Navigator.pop(context);
                                      _pickImage(ImageSource.gallery);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                    );
                  },
                ),
                if (!_showSave)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.grey,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() => _showSave = true);
                        _focusNode.requestFocus();
                      },
                      child: const Text(
                        'Edit note',
                        style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                if (_showSave)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.grey,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _saveNote,
                      child: const Text(
                        'Save note',
                        style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                const SizedBox(width: 16),
              ],
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child:
            _showSave
                ? Column(
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
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.black,
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        autofocus: _autofocus,
                        cursorColor: AppColors.black,
                        scrollPhysics: const BouncingScrollPhysics(),
                      ),
                    ),
                    if (_mediaData.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _mediaData.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final bytes = _mediaData[index];
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.memory(
                                      bytes,
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _mediaData.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    const SizedBox(height: 48),
                  ],
                )
                : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _noteController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          hintText: "Start writing...",
                          border: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.black,
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        cursorColor: AppColors.black,
                      ),
                      const SizedBox(height: 4),
                      for (final bytes in _mediaData) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              bytes,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
      ),
    );
  }
}
