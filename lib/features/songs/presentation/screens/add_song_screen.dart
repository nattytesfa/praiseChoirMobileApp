import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';
import 'package:praise_choir_app/core/widgets/common/custom_text_field.dart';
import 'package:praise_choir_app/core/widgets/common/loading_indicator.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:praise_choir_app/features/songs/data/models/song_model.dart';
import 'package:praise_choir_app/features/songs/presentation/cubit/song_cubit.dart';
import 'package:praise_choir_app/features/songs/presentation/cubit/song_state.dart';

class AddSongScreen extends StatefulWidget {
  const AddSongScreen({super.key});

  @override
  State<AddSongScreen> createState() => _AddSongScreenState();
}

class _AddSongScreenState extends State<AddSongScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _songNumberController = TextEditingController();
  final _lyricsController = TextEditingController();

  String _selectedLanguage = 'amharic';
  final List<String> _selectedTags = [];
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _populateNextSongNumber();
  }

  void _populateNextSongNumber() {
    final state = context.read<SongCubit>().state;
    if (state is SongLoaded) {
      int maxNum = 0;
      for (final song in state.songs) {
        if (song.songNumber != null) {
          final num = int.tryParse(song.songNumber!);
          if (num != null && num > maxNum) {
            maxNum = num;
          }
        }
      }
      _songNumberController.text = (maxNum + 1).toString();
    }
  }

  final List<String> _availableTags = ['new', 'this_round'];
  final List<Map<String, String>> _languages = [
    {'value': 'amharic', 'label': 'amharic'},
    {'value': 'kembatigna', 'label': 'kembatgna'},
  ];

  Future<void> _addSong() async {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthCubit>().state;
      if (authState is! AuthAuthenticated) return;

      final song = SongModel(
        id: 'song_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        lyrics: _lyricsController.text.trim(),
        language: _selectedLanguage,
        tags: _selectedTags,
        audioPath: _audioPath,
        addedBy: authState.user.name,
        dateAdded: DateTime.now(),
        performanceCount: 0,
        versions: [],
        recordingNotes: [],
        songNumber: _songNumberController.text.trim(),
      );

      await context.read<SongCubit>().addSong(song);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _attachAudio() {
    // This would open file picker for audio
    // For now, we'll simulate it
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
        Text('language'.tr(), style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _languages.map((lang) {
            final isSelected = _selectedLanguage == lang['value'];
            return ChoiceChip(
              label: Text(lang['label']!.tr()),
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
        Text('tags'.tr(), style: AppTextStyles.inputLabel),
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
    if (_audioPath == null) {
      return ElevatedButton.icon(
        onPressed: _attachAudio,
        icon: const Icon(Icons.attach_file),
        label: Text('attachAudioRecording'.tr()),
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: AppColors.withValues(AppColors.primary, 0.1),
        ),
      );
    }

    return Card(
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
                    'audioAttached'.tr(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('addNewSong'.tr()),
        actions: [
          BlocBuilder<SongCubit, SongState>(
            builder: (context, state) {
              if (state is SongLoading) {
                return const LoadingIndicator();
              }
              return IconButton(
                icon: const Icon(Icons.save),
                onPressed: _addSong,
                tooltip: 'saveSong'.tr(),
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
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Song Number
                CustomTextField(
                  controller: _songNumberController,
                  labelText: 'songNumber'.tr(),
                  hintText: 'enterSongNumber'.tr(),
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'pleaseEnterSongNumber'.tr();
                    }
                    if (int.tryParse(value) == null) {
                      return 'pleaseEnterValidNumber'.tr();
                    }
                    return null;
                  },
                  label: '',
                ),
                const SizedBox(height: 20),

                // Title
                CustomTextField(
                  controller: _titleController,
                  labelText: 'songTitle'.tr(),
                  hintText: 'enterSongTitle'.tr(),
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'pleaseEnterSongTitle'.tr();
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
                Text('lyrics'.tr(), style: AppTextStyles.inputLabel),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _lyricsController,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: 'enterSongLyrics'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignLabelWithHint: true,
                  ),
                  style: AppTextStyles.bodyLarge,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'pleaseEnterSongLyrics'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addSong,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'saveSong'.tr(),
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
    _songNumberController.dispose();
    _lyricsController.dispose();
    super.dispose();
  }
}
