import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';
import 'package:praise_choir_app/core/widgets/common/custom_text_field.dart';
import 'package:praise_choir_app/core/widgets/common/loading_indicator.dart';
import 'package:praise_choir_app/features/songs/data/models/song_model.dart';
import 'package:praise_choir_app/features/songs/presentation/cubit/song_cubit.dart';
import 'package:praise_choir_app/features/songs/presentation/cubit/song_state.dart';

class EditSongScreen extends StatefulWidget {
  final SongModel song;

  const EditSongScreen({super.key, required this.song});

  @override
  State<EditSongScreen> createState() => _EditSongScreenState();
}

class _EditSongScreenState extends State<EditSongScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _lyricsController = TextEditingController();

  late String _selectedLanguage;
  late List<String> _selectedTags;
  String? _audioPath;

  final List<String> _availableTags = ['old', 'new', 'favorite', 'this_round'];
  final List<Map<String, String>> _languages = [
    {'value': 'amharic', 'label': 'Amharic'},
    {'value': 'kembatigna', 'label': 'Kembatigna'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _titleController.text = widget.song.title;
    _lyricsController.text = widget.song.lyrics;
    _selectedLanguage = widget.song.language;
    _selectedTags = List.from(widget.song.tags);
    _audioPath = widget.song.audioPath;
  }

  void _updateSong() {
    if (_formKey.currentState!.validate()) {
      final updatedSong = widget.song.copyWith(
        title: _titleController.text.trim(),
        lyrics: _lyricsController.text.trim(),
        language: _selectedLanguage,
        tags: _selectedTags,
        audioPath: _audioPath,
      );

      context.read<SongCubit>().updateSong(updatedSong);
    }
  }

  void _attachAudio() {
    // This would open file picker for audio
    setState(() {
      _audioPath = '/path/to/audio/file.m4a';
    });
  }

  void _removeAudio() {
    setState(() {
      _audioPath = null;
    });
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  Widget _buildLanguageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Language', style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _languages.map((lang) {
            final isSelected = _selectedLanguage == lang['value'];
            return ChoiceChip(
              label: Text(lang['label']!),
              selected: isSelected,
              onSelected: (_) =>
                  setState(() => _selectedLanguage = lang['value']!),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTagSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tags', style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _availableTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return FilterChip(
              label: Text(_getTagDisplayName(tag)),
              selected: isSelected,
              onSelected: (_) => _toggleTag(tag),
              selectedColor: _getTagColor(tag),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAudioAttachment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Audio Recording', style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),

        if (_audioPath == null)
          ElevatedButton.icon(
            onPressed: _attachAudio,
            icon: const Icon(Icons.attach_file),
            label: const Text('Attach Audio Recording'),
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: AppColors.withValues(AppColors.primary, 0.1),
            ),
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.audio_file, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Audio attached',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _audioPath!.split('/').last,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: _removeAudio,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.play_arrow,
                      color: AppColors.primary,
                    ),
                    onPressed: () {
                      // Play audio
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSongInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Song Information', style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.person,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Added by: ${widget.song.addedBy}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Added: ${_formatDate(widget.song.dateAdded)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.music_note,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Performances: ${widget.song.performanceCount}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTagDisplayName(String tag) {
    switch (tag) {
      case 'old':
        return 'Old Song';
      case 'new':
        return 'New Song';
      case 'favorite':
        return 'Favorite';
      case 'this_round':
        return 'This Round';
      default:
        return tag;
    }
  }

  Color _getTagColor(String tag) {
    switch (tag) {
      case 'old':
        return AppColors.warning;
      case 'new':
        return AppColors.success;
      case 'favorite':
        return AppColors.error;
      case 'this_round':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Song'),
        actions: [
          BlocBuilder<SongCubit, SongState>(
            builder: (context, state) {
              if (state is SongLoading) {
                return const LoadingIndicator();
              }
              return IconButton(
                icon: const Icon(Icons.save),
                onPressed: _updateSong,
                tooltip: 'Save Changes',
              );
            },
          ),
        ],
      ),
      body: BlocListener<SongCubit, SongState>(
        listener: (context, state) {
          if (state is SongError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is SongLoaded) {
            Navigator.pop(context);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Song Info
                _buildSongInfo(),
                const SizedBox(height: 20),

                // Title
                CustomTextField(
                  controller: _titleController,
                  labelText: 'Song Title',
                  hintText: 'Enter song title',
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a song title';
                    }
                    return null;
                  },
                  label: '',
                ),
                const SizedBox(height: 20),

                // Language
                _buildLanguageSelector(),
                const SizedBox(height: 20),

                // Tags
                _buildTagSelector(),
                const SizedBox(height: 20),

                // Audio Attachment
                _buildAudioAttachment(),
                const SizedBox(height: 20),

                // Lyrics
                Text('Lyrics', style: AppTextStyles.inputLabel),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _lyricsController,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: 'Enter song lyrics...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignLabelWithHint: true,
                  ),
                  style: AppTextStyles.bodyLarge,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter song lyrics';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _updateSong,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Update Song',
                      style: AppTextStyles.buttonLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _lyricsController.dispose();
    super.dispose();
  }
}
