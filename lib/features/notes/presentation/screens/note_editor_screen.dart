import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';
import 'notes_screen.dart';

// ─── Note colour palette ──────────────────────────────────────────────────────

const _kPalette = [
  Color(0xFF1A2332),
  Color(0xFF0F2A1A),
  Color(0xFF1A1A2E),
  Color(0xFF2A1A1A),
  Color(0xFF251A2E),
  Color(0xFF2A2210),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class NoteEditorScreen extends StatefulWidget {
  final NoteData note;

  const NoteEditorScreen({super.key, required this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  late Color _selectedColour;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note.title);
    _contentCtrl = TextEditingController(text: widget.note.content);
    _selectedColour = widget.note.colour;

    _titleCtrl.addListener(_markDirty);
    _contentCtrl.addListener(_markDirty);
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _save() {
    widget.note.title = _titleCtrl.text.trim();
    widget.note.content = _contentCtrl.text.trim();
    widget.note.colour = _selectedColour;
    widget.note.updatedAt = DateTime.now();
    setState(() => _dirty = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.noteSaved, style: AppTypography.bodySm),
        backgroundColor: context.inputBg,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _onBack() {
    widget.note.title = _titleCtrl.text.trim();
    widget.note.content = _contentCtrl.text.trim();
    widget.note.colour = _selectedColour;
    widget.note.updatedAt = DateTime.now();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: _selectedColour,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: _selectedColour,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
            onTap: _onBack,
            child: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.arrow_back_rounded, color: context.primaryText),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: _dirty ? _save : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  AppStrings.save,
                  style: AppTypography.buttonMd.copyWith(
                    color: _dirty ? AppColors.teal : AppColors.textHint,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleCtrl,
                      style: AppTypography.h2.copyWith(color: context.primaryText),
                      decoration: InputDecoration(
                        hintText: AppStrings.untitledNote,
                        hintStyle: AppTypography.h2.copyWith(color: AppColors.textHint),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 4),
                    Container(height: 1, color: context.borderCol),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _contentCtrl,
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.65,
                      ),
                      decoration: InputDecoration(
                        hintText: AppStrings.tapToEdit,
                        hintStyle: AppTypography.bodyLg.copyWith(color: AppColors.textHint),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                    ),
                  ],
                ),
              ),
            ),

            // Colour picker toolbar
            Container(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottom),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: context.borderCol)),
                color: context.cardBg,
              ),
              child: Row(
                children: [
                  Text(
                    AppStrings.noteColourLabel,
                    style: AppTypography.labelSm.copyWith(color: AppColors.textHint),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _kPalette.map((c) {
                          final selected = c == _selectedColour;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _selectedColour = c;
                              _dirty = true;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.only(right: 8),
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected ? AppColors.teal : context.borderCol,
                                  width: selected ? 2.5 : 1,
                                ),
                              ),
                              child: selected
                                  ? const Icon(Icons.check_rounded,
                                      size: 14, color: AppColors.teal)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
