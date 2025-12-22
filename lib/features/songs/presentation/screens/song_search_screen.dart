import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';
import 'package:praise_choir_app/core/widgets/common/empty_state.dart';
import 'package:praise_choir_app/core/widgets/input/search_bar.dart' as app_search;
import 'package:praise_choir_app/features/songs/data/models/song_model.dart';
import 'package:praise_choir_app/features/songs/presentation/cubit/song_cubit.dart';
import 'package:praise_choir_app/features/songs/presentation/cubit/song_state.dart';
import 'package:praise_choir_app/features/songs/presentation/screens/song_detail_screen.dart';
import 'package:praise_choir_app/features/songs/presentation/widgets/song_list_item.dart';

class SongSearchScreen extends StatefulWidget {
  const SongSearchScreen({super.key});

  @override
  State<SongSearchScreen> createState() => _SongSearchScreenState();
}

class _SongSearchScreenState extends State<SongSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _currentQuery = '';
  String _selectedFilter = 'all';
  String _selectedLanguage = 'all';

  final List<Map<String, String>> _filters = [
    {'value': 'all', 'label': 'All Songs'},
    {'value': 'with_audio', 'label': 'With Audio'},
    {'value': 'favorites', 'label': 'Favorites'},
    {'value': 'old', 'label': 'Old Songs'},
    {'value': 'new', 'label': 'New Songs'},
  ];

  final List<Map<String, String>> _languages = [
    {'value': 'all', 'label': 'All Languages'},
    {'value': 'amharic', 'label': 'Amharic'},
    {'value': 'kembatigna', 'label': 'Kembatigna'},
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
  }

  void _onSearch(String query) {
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
    var filtered = results;

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
            hintText: 'Search songs by title or lyrics...',
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
                      child: Text(lang['label']!),
                    );
                  }).toList(),
                  onChanged: _onLanguageChanged,
                  decoration: const InputDecoration(
                    labelText: 'Language',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
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
                      child: Text(filter['label']!),
                    );
                  }).toList(),
                  onChanged: _onFilterChanged,
                  decoration: const InputDecoration(
                    labelText: 'Filter',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
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
                builder: (context) => SongDetailScreen(song: song),
              ),
            );
          },
          onPerformed: () {
            context.read<SongCubit>().markSongPerformed(song.id);
          },
          onPracticed: () {
            context.read<SongCubit>().markSongPracticed(song.id);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    if (_currentQuery.isNotEmpty) {
      return EmptyState(
        message: 'No songs found for "$_currentQuery"',
        subtitle: 'Try different search terms or filters',
        icon: Icons.search_off,
        title: '',
      );
    }

    return const EmptyState(
      message: 'No songs found',
      subtitle: 'Try adjusting your filters',
      icon: Icons.music_off,
      title: '',
    );
  }

  Widget _buildRecentSearches() {
    // In a real app, you would load recent searches from storage
    final recentSearches = ['worship', 'praise', 'traditional'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Recent Searches', style: AppTextStyles.titleMedium),
        ),
        Wrap(
          spacing: 8,
          children: recentSearches.map((search) {
            return ActionChip(
              label: Text(search),
              onPressed: () {
                _searchController.text = search;
                _onSearch(search);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickFilters() {
    final quickFilters = [
      {'icon': Icons.favorite, 'label': 'Favorites', 'filter': 'favorites'},
      {'icon': Icons.history, 'label': 'Old Songs', 'filter': 'old'},
      {'icon': Icons.new_releases, 'label': 'New Songs', 'filter': 'new'},
      {'icon': Icons.audio_file, 'label': 'With Audio', 'filter': 'with_audio'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Quick Filters', style: AppTextStyles.titleMedium),
        ),
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: quickFilters.map((filter) {
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    IconButton(
                      icon: Icon(filter['icon'] as IconData),
                      onPressed: () {
                        _onFilterChanged(filter['filter'] as String?);
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary.withValues(),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      filter['label'] as String,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
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
      appBar: AppBar(title: const Text('Search Songs')),
      body: Column(
        children: [
          // Search Header with Filters
          _buildSearchHeader(),

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
                  return ListView(
                    children: [_buildQuickFilters(), _buildRecentSearches()],
                  );
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
