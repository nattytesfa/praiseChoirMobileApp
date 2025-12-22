
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';
import 'package:praise_choir_app/core/widgets/common/custom_text_field.dart';
import 'package:praise_choir_app/core/widgets/common/empty_state.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:praise_choir_app/features/songs/data/models/recording_note_model.dart';
import 'package:praise_choir_app/features/songs/data/models/song_model.dart' hide RecordingNote;

class RecordingNotes extends StatefulWidget {
  final SongModel song;
  final Function(RecordingNote) onNoteAdded;

  const RecordingNotes({
    super.key,
    required this.song,
    required this.onNoteAdded,
  });

  @override
  State<RecordingNotes> createState() => _RecordingNotesState();
}

class _RecordingNotesState extends State<RecordingNotes> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _timestampController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _addNote() {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthCubit>().state;
      if (authState is! AuthAuthenticated) return;

      final note = RecordingNote(
        id: 'note_${DateTime.now().millisecondsSinceEpoch}',
        note: _noteController.text.trim(),
        addedBy: authState.user.id,
        createdAt: DateTime.now(),
        timestamp: _timestampController.text.trim().isNotEmpty
            ? _timestampController.text.trim()
            : null,
      );

      widget.onNoteAdded(note);

      // Clear form
      _noteController.clear();
      _timestampController.clear();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Note added successfully')));
    }
  }

  Widget _buildAddNoteForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Recording Note', style: AppTextStyles.titleMedium),
              const SizedBox(height: 16),

              // Timestamp (optional)
              CustomTextField(
                controller: _timestampController,
                labelText: 'Timestamp (optional)',
                hintText: 'e.g., 1:30, 2:15',
                keyboardType: TextInputType.text,
                label: '',
              ),
              const SizedBox(height: 16),

              // Note
              TextFormField(
                controller: _noteController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Note *',
                  hintText: 'Enter your note about this recording...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                style: AppTextStyles.bodyMedium,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a note';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Add Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addNote,
                  child: const Text('Add Note'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteItem(RecordingNote note) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with timestamp and author
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (note.hasTimestamp)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      note.timestamp!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  const Text('General Note', style: AppTextStyles.caption),

                Text(_formatDate(note.createdAt), style: AppTextStyles.caption),
              ],
            ),
            const SizedBox(height: 8),

            // Note content
            Text(note.note, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 8),

            // Author
            Text(
              'Added by: ${note.addedBy}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesList() {
    if (widget.song.recordingNotes.isEmpty) {
      return const EmptyState(
        message: 'No recording notes yet',
        subtitle: 'Add the first note to help with practice and performance',
        icon: Icons.note_add,
        title: '',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Recording Notes (${widget.song.recordingNotes.length})',
            style: AppTextStyles.titleMedium,
          ),
        ),
        ...widget.song.recordingNotes.map(
          (note) => _buildNoteItem(note as RecordingNote),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Add Note Form
          _buildAddNoteForm(),
          const SizedBox(height: 24),

          // Notes List
          _buildNotesList(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    _timestampController.dispose();
    super.dispose();
  }
}
