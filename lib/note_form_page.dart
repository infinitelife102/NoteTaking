import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'models/note_item.dart';

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
  bool _isInEditMode = false;

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
      _isInEditMode = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _titleFocusNode.requestFocus();
      });
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
    final theme = Theme.of(context);
    String? newCategory;
    await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final controller = TextEditingController();
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
                child: Text(
                  'Create new category',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: "Enter category name",
                    hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      Navigator.pop(ctx, value.trim());
                    }
                  },
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx, null),
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
                        onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: const Text("Add", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
    ).then((value) => newCategory = value);
    return newCategory;
  }

  void _showCategorySelectionBottomSheet() {
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
                child: Text(
                  'Select Category',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                ),
              ),

              ...widget.existingCategories.map((category) {
                final isSelected = _selectedCategory == category;
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
                  trailing: isSelected ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
                  selected: isSelected,
                  selectedTileColor: theme.colorScheme.onSurface.withOpacity(0.05),
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),

              if (widget.existingCategories.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  height: 1,
                  color: theme.colorScheme.onSurface.withOpacity(0.1),
                ),

              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                leading: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                  child: Icon(Icons.add, color: theme.colorScheme.onPrimary, size: 12),
                ),
                title: Text('Create new category', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
                onTap: () async {
                  Navigator.pop(context);
                  final newCat = await _promptForCategory();
                  if (newCat != null && newCat.isNotEmpty) {
                    setState(() => _selectedCategory = newCat);
                  }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _titleController,
          builder: (context, value, child) {
            final appBarTitleText = value.text.trim();
            final dynamicTitle = appBarTitleText.isNotEmpty ? appBarTitleText : 'Untitled';
            return AppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
              titleSpacing: 16,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(dynamicTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(_selectedCategory, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(CupertinoIcons.tag, color: theme.colorScheme.onSurface),
                  tooltip: "Select Category",
                  onPressed: _showCategorySelectionBottomSheet,
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(CupertinoIcons.photo_camera, color: theme.colorScheme.onSurface),
                  tooltip: "Add Image",
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: theme.scaffoldBackgroundColor,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                      builder:
                          (_) => SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(CupertinoIcons.camera, color: theme.colorScheme.onSurface),
                                    title: const Text("Take photo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                    textColor: theme.colorScheme.onSurface,
                                    onTap: () {
                                      Navigator.pop(context);
                                      _pickImage(ImageSource.camera);
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  ListTile(
                                    leading: Icon(CupertinoIcons.photo_on_rectangle, color: theme.colorScheme.onSurface),
                                    title: const Text("Choose from gallery", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                    textColor: theme.colorScheme.onSurface,
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
                _isInEditMode
                    ? Container(
                      decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(25)),
                      child: IconButton(
                        icon: Icon(CupertinoIcons.checkmark_alt, color: theme.colorScheme.onPrimary),
                        tooltip: "Save note",
                        onPressed: _saveNote,
                      ),
                    )
                    : Container(
                      decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(25)),
                      child: IconButton(
                        icon: Icon(CupertinoIcons.pencil, color: theme.colorScheme.onPrimary),
                        tooltip: "Edit note",
                        onPressed: () {
                          setState(() {
                            _isInEditMode = true;
                          });

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final hasContent = _contentController.text.trim().isNotEmpty;
                            if (hasContent) {
                              _contentFocusNode.requestFocus();
                              _contentController.selection = TextSelection.collapsed(offset: _contentController.text.length);
                            } else {
                              _titleFocusNode.requestFocus();
                              _titleController.selection = TextSelection.collapsed(offset: _titleController.text.length);
                            }
                          });
                        },
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      focusNode: _titleFocusNode,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: const EdgeInsets.only(top: 8, bottom: 16),
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor,
                      ),
                      style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      cursorColor: theme.colorScheme.onBackground,
                      textInputAction: TextInputAction.next,
                      scrollPhysics: const NeverScrollableScrollPhysics(),
                      onSubmitted: (_) => FocusScope.of(context).requestFocus(_contentFocusNode),
                      onTap: () {
                        setState(() {
                          _isInEditMode = true;
                        });
                        _titleController.selection = TextSelection.collapsed(offset: _titleController.text.length);
                      },
                    ),
                    TextField(
                      controller: _contentController,
                      focusNode: _contentFocusNode,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: const EdgeInsets.only(top: 4),
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor,
                      ),
                      style: TextStyle(fontSize: 16, color: theme.colorScheme.onBackground, fontWeight: FontWeight.w500, height: 1.5),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      cursorColor: theme.colorScheme.onBackground,
                      scrollPhysics: const NeverScrollableScrollPhysics(),
                      onTap: () {
                        setState(() {
                          _isInEditMode = true;
                        });
                        _contentController.selection = TextSelection.collapsed(offset: _contentController.text.length);
                      },
                    ),
                    if (_mediaData.isNotEmpty && !_isInEditMode) _buildImageSection(theme),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
            if (_mediaData.isNotEmpty && _isInEditMode) _buildImageSection(theme),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(ThemeData theme) {
    if (_isInEditMode) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _mediaData.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final bytes = _mediaData[index];
              return _buildCompactImageTile(bytes, index, theme);
            },
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: _mediaData.length,
          itemBuilder: (context, index) {
            final bytes = _mediaData[index];
            return ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(bytes, fit: BoxFit.cover));
          },
        ),
      );
    }
  }

  Widget _buildCompactImageTile(Uint8List bytes, int index, ThemeData theme) {
    return Stack(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(bytes, height: 80, width: 80, fit: BoxFit.cover)),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _mediaData.removeAt(index);
                _hasChanges = true;
              });
            },
            child: Container(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
              padding: const EdgeInsets.all(4),
              child: Icon(CupertinoIcons.clear, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
