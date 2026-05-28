import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/note_entity.dart';
import '../providers/notes_provider.dart';
import 'note_editor_screen.dart';

// ─── Mutable view-model used by NoteEditorScreen ─────────────────────────────

class NoteData {
  final String id;
  String title;
  String content;
  Color colour;
  DateTime updatedAt;

  NoteData({
    required this.id,
    required this.title,
    required this.content,
    required this.colour,
    required this.updatedAt,
  });
}

// ─── Palette of note background colours ──────────────────────────────────────

const _kPalette = [
  Color(0xFF1A2332),
  Color(0xFF0F2A1A),
  Color(0xFF1A1A2E),
  Color(0xFF2A1A1A),
  Color(0xFF251A2E),
  Color(0xFF2A2210),
];

// ─── Color conversion helpers ─────────────────────────────────────────────────

Color _hexToColor(String? hex) {
  if (hex == null || hex.isEmpty) return _kPalette[0];
  final h = hex.startsWith('#') ? hex.substring(1) : hex;
  if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
  return _kPalette[0];
}

String _colorToHex(Color color) {
  final hex = color.toARGB32().toRadixString(16).padLeft(8, '0');
  return '#${hex.substring(2).toUpperCase()}';
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  String _query = '';

  List<NoteEntity> _filter(List<NoteEntity> notes) {
    if (_query.isEmpty) return notes;
    return notes
        .where((n) =>
            n.title.toLowerCase().contains(_query) ||
            n.body.toLowerCase().contains(_query))
        .toList();
  }

  Future<void> _openNote(NoteEntity entity) async {
    final nd = NoteData(
      id: entity.id,
      title: entity.title,
      content: entity.body,
      colour: _hexToColor(entity.color),
      updatedAt: DateTime.tryParse(entity.updatedAt ?? entity.createdAt) ?? DateTime.now(),
    );
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorScreen(note: nd)),
    );
    if (!mounted) return;
    await ref.read(notesProvider.notifier).updateNote(
          id: entity.id,
          title: nd.title,
          body: nd.content,
          color: _colorToHex(nd.colour),
        );
  }

  Future<void> _createNote() async {
    final nd = NoteData(
      id: '',
      title: '',
      content: '',
      colour: _kPalette[0],
      updatedAt: DateTime.now(),
    );
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorScreen(note: nd)),
    );
    if (!mounted) return;
    if (nd.title.isEmpty && nd.content.isEmpty) return;
    await ref.read(notesProvider.notifier).createNote(
          title: nd.title,
          body: nd.content,
          color: _colorToHex(nd.colour),
        );
  }

  Future<void> _confirmDelete(String noteId) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: AppStrings.delete,
      message: AppStrings.deleteNoteConfirm,
      confirmLabel: AppStrings.delete,
      isDanger: true,
    );
    if (confirmed != true || !mounted) return;
    ref.read(notesProvider.notifier).deleteNote(noteId);
    AppSnackbar.success(context, AppStrings.noteDeleted);
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(notesProvider);
    final filtered = _filter(st.notes);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: context.bg,
              surfaceTintColor: Colors.transparent,
              expandedHeight: 96,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
                title: AppText.h3(AppStrings.myNotes),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: AppSearchTextInput(
                  hint: AppStrings.searchNotes,
                  onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                ),
              ),
            ),
            if (st.isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal),
                ),
              )
            else if (filtered.isEmpty)
              SliverFillRemaining(
                child: AppEmptyState(
                  icon: Icons.sticky_note_2_outlined,
                  title: _query.isNotEmpty ? AppStrings.nothingFound : AppStrings.noNotes,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.88,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _NoteCard(
                      note: filtered[i],
                      onTap: () => _openNote(filtered[i]),
                      onLongPress: () => _confirmDelete(filtered[i].id),
                    ),
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _createNote,
          backgroundColor: AppColors.teal,
          foregroundColor: context.bg,
          child: const Icon(Icons.add_rounded, size: 26),
        ),
      ),
    );
  }
}

// ─── Note card ────────────────────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  final NoteEntity note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _NoteCard({
    required this.note,
    required this.onTap,
    required this.onLongPress,
  });

  String _fmtDate(String isoStr) {
    final dt = DateTime.tryParse(isoStr);
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return AppStrings.yesterdayLabel;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final title = note.title.isEmpty ? AppStrings.untitledNote : note.title;
    final colour = _hexToColor(note.color);
    final dateStr = _fmtDate(note.updatedAt ?? note.createdAt);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colour,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: context.borderCol),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.labelMd(
              title,
              fontWeight: FontWeight.w700,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                note.body.isEmpty ? AppStrings.tapToEdit : note.body,
                style: TextStyle(
                  fontSize: 12,
                  color: note.body.isEmpty ? AppColors.textHint : AppColors.textSecondary,
                  height: 1.5,
                ),
                maxLines: 5,
                overflow: TextOverflow.fade,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 10, color: AppColors.textHint),
                const SizedBox(width: 4),
                AppText.bodyXs(dateStr, color: AppColors.textHint),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
