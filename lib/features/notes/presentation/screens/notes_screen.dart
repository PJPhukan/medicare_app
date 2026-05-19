import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';
import 'note_editor_screen.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

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
  Color(0xFF1A2332), // default dark
  Color(0xFF0F2A1A), // dark green
  Color(0xFF1A1A2E), // dark blue
  Color(0xFF2A1A1A), // dark red
  Color(0xFF251A2E), // dark purple
  Color(0xFF2A2210), // dark amber
];

// ─── Mock data ────────────────────────────────────────────────────────────────

final _kMockNotes = [
  NoteData(
    id: 'note1',
    title: 'BP Readings — Week 3',
    content: 'Mon: 138/88, Tue: 142/90, Wed: 135/85. Trend improving after reducing sodium. Doctor says keep tracking daily for two more weeks.',
    colour: _kPalette[0],
    updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  NoteData(
    id: 'note2',
    title: 'Metformin Side Effects',
    content: 'Mild nausea the first two days. Doctor said take it after a full meal. Nausea gone by day 4. Blood sugar stabilising around 108 mg/dL.',
    colour: _kPalette[1],
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  NoteData(
    id: 'note3',
    title: 'Questions for Next Appointment',
    content: '1. Can I reduce Amlodipine dose?\n2. Request physio referral for knee.\n3. Ask about HbA1c target range.\n4. Diet recommendations update.',
    colour: _kPalette[2],
    updatedAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  NoteData(
    id: 'note4',
    title: 'Knee Exercise Log',
    content: 'Dr. Vikram\'s programme: straight leg raises (3×15), wall squats (2×30s), calf raises (3×20). Week 2 — pain reduced from 7/10 to 4/10.',
    colour: _kPalette[3],
    updatedAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  NoteData(
    id: 'note5',
    title: 'Diet Changes',
    content: 'No more processed salt. More leafy greens and oats. Reduce red meat to once a week. Drink 2L water daily. Limit alcohol to zero for now.',
    colour: _kPalette[4],
    updatedAt: DateTime.now().subtract(const Duration(days: 7)),
  ),
  NoteData(
    id: 'note6',
    title: 'Insurance Claims',
    content: 'Claim #MF-2024-882 submitted 4 Feb. Waiting on approval. Call insurer if no response by 20 Feb. Keep all pharmacy receipts for reimbursement.',
    colour: _kPalette[5],
    updatedAt: DateTime.now().subtract(const Duration(days: 14)),
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _searchCtrl = TextEditingController();
  final List<NoteData> _notes = List.from(_kMockNotes);
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(
      () => setState(() => _query = _searchCtrl.text.trim().toLowerCase()),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<NoteData> get _filtered {
    if (_query.isEmpty) return _notes;
    return _notes.where((n) =>
      n.title.toLowerCase().contains(_query) ||
      n.content.toLowerCase().contains(_query),
    ).toList();
  }

  void _openNote(NoteData note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)),
    );
    setState(() {}); // refresh after edit
  }

  void _createNote() async {
    final newNote = NoteData(
      id: 'note_${DateTime.now().millisecondsSinceEpoch}',
      title: '',
      content: '',
      colour: _kPalette[0],
      updatedAt: DateTime.now(),
    );
    _notes.insert(0, newNote);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorScreen(note: newNote)),
    );
    setState(() {
      // if left blank, remove it
      if (newNote.title.isEmpty && newNote.content.isEmpty) {
        _notes.remove(newNote);
      }
    });
  }

  void _confirmDelete(NoteData note) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardBg,
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
        title: Text(AppStrings.delete, style: AppTypography.h3),
        content: Text(
          AppStrings.deleteNoteConfirm,
          style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel,
                style: AppTypography.buttonMd.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.delete,
                style: AppTypography.buttonMd.copyWith(color: AppColors.red)),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        setState(() => _notes.remove(note));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.noteDeleted, style: AppTypography.bodySm),
            backgroundColor: context.inputBg,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
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
                title: Text(AppStrings.myNotes, style: AppTypography.h3),
              ),
            ),

            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: _SearchBar(controller: _searchCtrl),
              ),
            ),

            // Notes grid or empty state
            filtered.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.sticky_note_2_outlined,
                              size: 52, color: AppColors.textHint),
                          const SizedBox(height: 16),
                          Text(
                            _query.isNotEmpty
                                ? AppStrings.nothingFound
                                : AppStrings.noNotes,
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
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
                          onLongPress: () => _confirmDelete(filtered[i]),
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

// ─── Search bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.inputBg,
        borderRadius: AppBorderRadius.lgAll,
        border: Border.all(color: context.borderCol),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 14),
            child: Icon(Icons.search_rounded, color: AppColors.textHint, size: 18),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTypography.bodyMd.copyWith(color: context.primaryText),
              decoration: InputDecoration(
                hintText: AppStrings.searchNotes,
                hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textHint),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (_, v, __) => v.text.isNotEmpty
                ? GestureDetector(
                    onTap: controller.clear,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.close_rounded, size: 16, color: AppColors.textHint),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─── Note card ────────────────────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  final NoteData note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _NoteCard({
    required this.note,
    required this.onTap,
    required this.onLongPress,
  });

  String _fmtDate(DateTime dt) {
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
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: note.colour,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: context.borderCol),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                note.content.isEmpty ? AppStrings.tapToEdit : note.content,
                style: AppTypography.bodySm.copyWith(
                  color: note.content.isEmpty
                      ? AppColors.textHint
                      : AppColors.textSecondary,
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
                Text(
                  _fmtDate(note.updatedAt),
                  style: AppTypography.bodyXs,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
