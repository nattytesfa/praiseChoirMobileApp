import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';
import 'package:praise_choir_app/core/widgets/common/empty_state.dart';
import 'package:praise_choir_app/core/widgets/input/search_bar.dart'
    as app_search;
import 'package:praise_choir_app/features/songs/data/models/song_model.dart';
import 'package:praise_choir_app/features/songs/presentation/cubit/song_cubit.dart';
import 'package:praise_choir_app/features/songs/presentation/cubit/song_state.dart';
import 'package:praise_choir_app/features/songs/presentation/screens/lyrics_display.dart';
import 'package:praise_choir_app/features/songs/presentation/widgets/song_list_item.dart';

class SongSearchScreen extends StatefulWidget {
  const SongSearchScreen({super.key});

  @override
  State<SongSearchScreen> createState() => _SongSearchScreenState();
}

class _SongSearchScreenState extends State<SongSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final Box _settingsBox = Hive.box('settings');

  List<String> _recentSearches = [];
  String _currentQuery = '';
  String _selectedFilter = 'all';
  String _selectedLanguage = 'all';

  final List<Map<String, String>> _filters = [
    {'value': 'all', 'label': 'allSongs'},
    {'value': 'with_audio', 'label': 'withAudio'},
    {'value': 'favorites', 'label': 'favorites'},
    {'value': 'new', 'label': 'newSongs'},
  ];

  final List<Map<String, String>> _languages = [
    {'value': 'all', 'label': 'allLanguages'},
    {'value': 'amharic', 'label': 'amharic'},
    {'value': 'kembatigna', 'label': 'kembatgna'},
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _searchFocusNode.requestFocus();
  }

  void _loadRecentSearches() {
    final searches = _settingsBox.get(
      'recent_searches',
      defaultValue: <String>[],
    );
    if (searches is List) {
      setState(() {
        _recentSearches = searches.cast<String>().toList();
      });
    }
  }

  void _saveRecentSearch(String query) {
    if (query.trim().isEmpty) return;

    final searches = List<String>.from(_recentSearches);
    searches.remove(query); // Remove if exists to move to top
    searches.insert(0, query); // Add to top

    if (searches.length > 10) {
      searches.removeLast(); // Keep only last 10
    }

    _settingsBox.put('recent_searches', searches);
    setState(() {
      _recentSearches = searches;
    });
  }

  void _onSearch(String query) {
    _saveRecentSearch(query);
    setState(() {
      _currentQuery = query;
    });
    context.read<SongCubit>().searchSongs(query);
  }

  void _onClearSearch() {
    setState(() {
      _currentQuery = '';
    });
    context.read<SongCubit>().loadSongs();
  }

  void _onFilterChanged(String? filter) {
    if (filter != null) {
      setState(() {
        _selectedFilter = filter;
      });
      _applyFilters();
    }
  }

  void _onLanguageChanged(String? language) {
    if (language != null) {
      setState(() {
        _selectedLanguage = language;
      });
      _applyFilters();
    }
  }

  void _applyFilters() {
    if (_currentQuery.isNotEmpty) {
      context.read<SongCubit>().searchSongs(_currentQuery);
    } else {
      context.read<SongCubit>().loadSongs();
    }
  }

  List<SongModel> _filterResults(List<SongModel> results) {
    // 1. Dedup by ID first
    final uniqueById = {for (var s in results) s.id: s}.values.toList();

    // 2. Dedup by Title (keeping the "best" version)
    final Map<String, SongModel> uniqueByTitle = {};

    for (var song in uniqueById) {
      final title = song.title.trim().toLowerCase();

      if (!uniqueByTitle.containsKey(title)) {
        uniqueByTitle[title] = song;
      } else {
        final existing = uniqueByTitle[title]!;
        // Logic to decide which one to keep
        bool existingIsFav = existing.tags.contains('favorite');
        bool currentIsFav = song.tags.contains('favorite');

        if (!existingIsFav && currentIsFav) {
          uniqueByTitle[title] = song; // Replace with favorite
        } else if (existingIsFav == currentIsFav) {
          // If both are fav or both not fav, check audio
          if (existing.audioPath == null && song.audioPath != null) {
            uniqueByTitle[title] = song;
          }
        }
      }
    }

    var filtered = uniqueByTitle.values.toList();

    // Apply language filter
    if (_selectedLanguage != 'all') {
      filtered = filtered
          .where((song) => song.language == _selectedLanguage)
          .toList();
    }

    // Apply content filter
    switch (_selectedFilter) {
      case 'with_audio':
        filtered = filtered.where((song) => song.audioPath != null).toList();
        break;
      case 'favorites':
        filtered = filtered
            .where((song) => song.tags.contains('favorite'))
            .toList();
        break;
      case 'old':
        filtered = filtered.where((song) => song.tags.contains('old')).toList();
        break;
      case 'new':
        filtered = filtered.where((song) => song.tags.contains('new')).toList();
        break;
    }

    return filtered;
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Search Bar
          app_search.SearchBar(
            hintText: 'searchSongsHint'.tr(),
            onSearch: _onSearch,
            onClear: _onClearSearch,
          ),
          const SizedBox(height: 16),

          // Filters
          Row(
            children: [
              // Language Filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedLanguage,
                  items: _languages.map((lang) {
                    return DropdownMenuItem(
                      value: lang['value'],
                      child: Text(lang['label']!.tr()),
                    );
                  }).toList(),
                  onChanged: _onLanguageChanged,
                  decoration: InputDecoration(
                    labelText: 'language'.tr(),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  isExpanded: true,
                ),
              ),
              const SizedBox(width: 12),

              // Content Filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedFilter,
                  items: _filters.map((filter) {
                    return DropdownMenuItem(
                      value: filter['value'],
                      child: Text(filter['label']!.tr()),
                    );
                  }).toList(),
                  onChanged: _onFilterChanged,
                  decoration: InputDecoration(
                    labelText: 'filter'.tr(),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  isExpanded: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<SongModel> results) {
    final filteredResults = _filterResults(results);

    if (filteredResults.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: filteredResults.length,
      itemBuilder: (context, index) {
        final song = filteredResults[index];
        return SongListItem(
          song: song,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LyricsDisplay(
                  title: song.title,
                  lyrics: song.lyrics,
                  language: song.language,
                ),
              ),
            );
          },
          onPerformed: () {
            context.read<SongCubit>().markSongPerformed(song.id);
          },
          onPracticed: () {
            context.read<SongCubit>().markSongPracticed(song.id);
          },
          onDelete: () {
            context.read<SongCubit>().deleteSong(song.id);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    if (_currentQuery.isNotEmpty) {
      return EmptyState(
        message: '${'noSongsFoundFor'.tr()} "$_currentQuery"',
        subtitle: 'tryDifferentSearchTerms'.tr(),
        icon: Icons.search_off,
        title: '',
      );
    }

    return EmptyState(
      message: 'noSongsFound'.tr(),
      subtitle: 'tryAdjustingFilters'.tr(),
      icon: Icons.music_off,
      title: '',
    );
  }

  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('recentSearches'.tr(), style: AppTextStyles.titleMedium),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            children: _recentSearches.map((search) {
              return ActionChip(
                label: Text(search),
                onPressed: () {
                  _searchController.text = search;
                  _onSearch(search);
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('searchSongs'.tr())),
      body: Column(
        children: [
          // Search Header with Filters
          _buildSearchHeader(),
          const SizedBox(height: 14),
          Text('recentSearches'.tr(), style: AppTextStyles.titleMedium),
          const SizedBox(height: 14),

          // Results
          Expanded(
            child: BlocBuilder<SongCubit, SongState>(
              builder: (context, state) {
                if (state is SongLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is SongError) {
                  return Center(child: Text(state.message));
                }

                if (state is SongSearchResults) {
                  return _buildSearchResults(state.results);
                }

                if (state is SongLoaded && _currentQuery.isEmpty) {
                  // Show recent searches and quick filters when no search is active
                  return ListView(children: [_buildRecentSearches()]);
                }

                if (state is SongLoaded) {
                  return _buildSearchResults(state.songs);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
