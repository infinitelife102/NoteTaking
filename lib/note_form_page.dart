import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'models/note_item.dart';
import 'theme.dart';

class NoteFormPage extends StatefulWidget {
  final List<String> existingCategories;
  final NoteItem? initialNote;
  final String? initialCategory;

  const NoteFormPage({Key? key, required this.existingCategories, this.initialNote, this.initialCategory}) : super(key: key);

  @override
  State<NoteFormPage> createState() => _NoteFormPageState();
}

class _NoteFormPageState extends State<NoteFormPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  final List<Uint8List> _mediaData = [];
  final _uuid = const Uuid();

  String _selectedCategory = '';
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final note = widget.initialNote;
    if (note != null) {
      _titleController.text = note.title;
      _contentController.text = note.content;
      _selectedCategory = note.category;
      _mediaData.addAll(note.mediaData);
    } else {
      _selectedCategory = widget.initialCategory ?? (widget.existingCategories.isNotEmpty ? widget.existingCategories.first : 'General');
    }

    _titleFocusNode.addListener(_handleFocusChange);
    _contentFocusNode.addListener(_handleFocusChange);
    _titleController.addListener(_handleTextChange);
    _contentController.addListener(_handleTextChange);
  }

  void _handleFocusChange() {
    _markChanged();
  }

  void _handleTextChange() {
    _markChanged();
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      final bytes = await File(picked.path).readAsBytes();
      setState(() {
        _mediaData.add(bytes);
        _hasChanges = true;
      });
    }
  }

  Future<String?> _promptForCategory() async {
    String? newCategory;
    await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: AppColors.backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: const Text("Create new category", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryfontColor)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: AppColors.primaryfontColor),
            decoration: InputDecoration(
              hintText: "Enter category name",
              hintStyle: TextStyle(color: AppColors.primaryfontColor.withOpacity(0.4)),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.secondaryfontColor),
                borderRadius: BorderRadius.circular(25),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.secondaryfontColor, width: 2),
                borderRadius: BorderRadius.circular(25),
              ),
              filled: true,
              fillColor: AppColors.secondaryfontColor.withOpacity(0.05),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              style: TextButton.styleFrom(foregroundColor: AppColors.primaryfontColor.withOpacity(0.7)),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryfontColor,
                foregroundColor: AppColors.backgroundColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
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
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty && _mediaData.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final note = NoteItem(
      id: widget.initialNote?.id ?? _uuid.v4(),
      title: title,
      content: content,
      category: _selectedCategory.trim(),
      createdAt: widget.initialNote?.createdAt ?? DateTime.now(),
      customFields: Map<String, dynamic>.from(widget.initialNote?.customFields ?? {}),
      mediaData: _mediaData,
    );

    Navigator.pop(context, note);
  }

  void _autoSave() {
    if (_hasChanges) {
      _saveNote();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _titleController,
          builder: (context, value, child) {
            final appBarTitleText = value.text.trim();
            final dynamicTitle = appBarTitleText.isNotEmpty ? appBarTitleText : 'Untitled';
            return AppBar(
              backgroundColor: AppColors.backgroundColor,
              elevation: 0,
              foregroundColor: AppColors.primaryfontColor,
              titleSpacing: 16,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(dynamicTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(_selectedCategory, style: TextStyle(fontSize: 12, color: AppColors.primaryfontColor.withOpacity(0.6))),
                ],
              ),
              actions: [
                PopupMenuButton<String>(
                  initialValue: _selectedCategory,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: AppColors.secondaryfontColor,
                  elevation: 8,
                  icon: const Icon(CupertinoIcons.tag, color: AppColors.primaryfontColor),
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
                            child: Text(cat, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          ),
                        const PopupMenuDivider(),
                        const PopupMenuItem<String>(
                          value: 'New Category',
                          child: Text("➕ New Category", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        ),
                      ],
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(CupertinoIcons.photo_camera, color: AppColors.primaryfontColor),
                  tooltip: "Add Image",
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: AppColors.backgroundColor,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                      builder:
                          (_) => SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(CupertinoIcons.camera, color: AppColors.secondaryfontColor),
                                    title: const Text("Take photo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                    textColor: AppColors.primaryfontColor,
                                    onTap: () {
                                      Navigator.pop(context);
                                      _pickImage(ImageSource.camera);
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  ListTile(
                                    leading: Icon(CupertinoIcons.photo_on_rectangle, color: AppColors.secondaryfontColor),
                                    title: const Text("Choose from gallery", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                    textColor: AppColors.primaryfontColor,
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
                const SizedBox(width: 16),
              ],
            );
          },
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (!didPop) {
            _autoSave();
          }
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                focusNode: _titleFocusNode,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.only(top: 8, bottom: 12),
                ),
                style: const TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: AppColors.primaryfontColor),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                cursorColor: AppColors.primaryfontColor,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => FocusScope.of(context).requestFocus(_contentFocusNode),
                onTap: () {
                  _titleController.selection = TextSelection.collapsed(offset: _titleController.text.length);
                },
              ),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  focusNode: _contentFocusNode,
                  decoration: const InputDecoration(border: InputBorder.none, isCollapsed: true, contentPadding: EdgeInsets.only(top: 4)),
                  style: const TextStyle(fontSize: 16, color: AppColors.primaryfontColor, fontWeight: FontWeight.w500, height: 1.5),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  cursorColor: AppColors.primaryfontColor,
                  scrollPhysics: const BouncingScrollPhysics(),
                  onTap: () {
                    _contentController.selection = TextSelection.collapsed(offset: _contentController.text.length);
                  },
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
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final bytes = _mediaData[index];
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(bytes, height: 100, width: 100, fit: BoxFit.cover),
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
                                  decoration: const BoxDecoration(color: AppColors.primaryfontColor, shape: BoxShape.circle),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(CupertinoIcons.clear, size: 16, color: AppColors.backgroundColor),
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
          ),
        ),
      ),
    );
  }
}
