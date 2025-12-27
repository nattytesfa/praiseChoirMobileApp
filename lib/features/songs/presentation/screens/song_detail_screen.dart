import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:praise_choir_app/features/songs/data/models/song_model.dart';
import 'package:praise_choir_app/features/songs/presentation/cubit/song_cubit.dart';
import 'package:praise_choir_app/features/songs/presentation/cubit/song_state.dart';
import 'package:praise_choir_app/features/songs/presentation/screens/edit_song_screen.dart';
import 'package:praise_choir_app/features/songs/presentation/widgets/audio_player_widget.dart';
import 'package:praise_choir_app/features/songs/presentation/widgets/lyrics_fullscreen.dart';
import 'package:praise_choir_app/features/songs/presentation/widgets/version_selector.dart';

class SongDetailScreen extends StatefulWidget {
  final SongModel song;

  const SongDetailScreen({super.key, required this.song});

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _tabs = [
    {'title': 'Lyrics', 'icon': Icons.music_note},
    {'title': 'Audio', 'icon': Icons.audio_file},
    {'title': 'Versions', 'icon': Icons.layers},
  ];

  void _markAsPerformed() {
    context.read<SongCubit>().markSongPerformed(widget.song.id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Marked as performed')));
  }

  void _markAsPracticed() {
    context.read<SongCubit>().markSongPracticed(widget.song.id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Marked as practiced')));
  }

  void _openFullscreenLyrics() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: SafeArea(
            child: LyricsFullscreen(
              lyrics: widget.song.lyrics,
              onFullscreen: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
    ).then((_) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    });
  }

  void _editSong() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSongScreen(song: widget.song),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.song.title,
            style: AppTextStyles.titleLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      actions: [
        // Fullscreen lyrics
        IconButton(
          icon: const Icon(Icons.fullscreen),
          onPressed: _openFullscreenLyrics,
          tooltip: 'Fullscreen Lyrics',
        ),

        // Edit song (only for leaders/atigni)
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            if (authState is AuthAuthenticated) {
              final user = authState.user;
              if (user.role == 'admin' || user.role == 'songwriter') {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _editSong,
                  tooltip: 'Edit Song',
                );
              }
            }
            return const SizedBox.shrink();
          },
        ),

        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'performed':
                _markAsPerformed();
                break;
              case 'practiced':
                _markAsPracticed();
                break;
              case 'share':
                // Share song
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'performed',
              child: ListTile(
                leading: Icon(Icons.star),
                title: Text('Mark as Performed'),
              ),
            ),
            const PopupMenuItem(
              value: 'practiced',
              child: ListTile(
                leading: Icon(Icons.self_improvement),
                title: Text('Mark as Practiced'),
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'share',
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text('Share Song'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSongHeader() {
    return BlocBuilder<SongCubit, SongState>(
      builder: (context, state) {
        SongModel currentSong = widget.song;
        if (state is SongLoaded) {
          try {
            currentSong = state.songs.firstWhere((s) => s.id == widget.song.id);
          } catch (_) {}
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistics
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      Icons.favorite,
                      currentSong.likeCount.toString(),
                      'Likes',
                    ),
                    _buildStatItem(
                      Icons.calendar_today,
                      _getLastUsedText(currentSong),
                      'Last Used',
                    ),
                    _buildStatItem(
                      Icons.person,
                      currentSong.addedBy,
                      'Added By',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.withValues(Colors.black, 0.1),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: _tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = _currentPage == index;

          return Expanded(
            child: InkWell(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 20,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tab['title'] as String,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContentPages() {
    return Expanded(
      child: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: [
          // Lyrics Tab
          LyricsFullscreen(
            lyrics: widget.song.lyrics,
            onFullscreen: _openFullscreenLyrics,
          ),

          // Audio Tab
          widget.song.audioPath != null
              ? AudioPlayerWidget(
                  audioPath: widget.song.audioPath!,
                  title: widget.song.title,
                )
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.audio_file,
                        size: 64,
                        color: AppColors.textDisabled,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No audio recording available',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),

          // Versions Tab
          BlocBuilder<SongCubit, SongState>(
            builder: (context, state) {
              SongModel currentSong = widget.song;
              if (state is SongLoaded) {
                try {
                  currentSong = state.songs.firstWhere(
                    (s) => s.id == widget.song.id,
                  );
                } catch (_) {}
              }
              return VersionSelector(
                song: currentSong,
                onVersionAdded: (version) {
                  context.read<SongCubit>().addSongVersion(
                    widget.song.id,
                    version,
                  );
                },
                onVersionDeleted: (versionId) {
                  context.read<SongCubit>().deleteSongVersion(
                    widget.song.id,
                    versionId,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  String _getLastUsedText(SongModel song) {
    final lastUsed = song.lastPerformed ?? song.lastPracticed;
    if (lastUsed == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(lastUsed);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    }
    return '${(difference.inDays / 30).floor()}mo ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Song Header
          _buildSongHeader(),

          // Tab Bar
          _buildTabBar(),

          // Content Pages
          _buildContentPages(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
