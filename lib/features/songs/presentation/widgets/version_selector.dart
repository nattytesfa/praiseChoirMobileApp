import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';
import 'package:praise_choir_app/core/widgets/common/custom_text_field.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:praise_choir_app/features/songs/data/models/song_model.dart';

class VersionSelector extends StatefulWidget {
  final SongModel song;
  final Function(SongVersion) onVersionAdded;
  final Function(String) onVersionDeleted;

  const VersionSelector({
    super.key,
    required this.song,
    required this.onVersionAdded,
    required this.onVersionDeleted,
  });

  @override
  State<VersionSelector> createState() => _VersionSelectorState();
}

class _VersionSelectorState extends State<VersionSelector> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Default version types
  final List<Map<String, String>> _defaultTypes = [
    {'value': 'traditional', 'label': 'traditional'.tr()},
    {'value': 'modern', 'label': 'modern'.tr()},
    {'value': 'acoustic', 'label': 'acoustic'.tr()},
    {'value': 'choir', 'label': 'choirArrangement'.tr()},
    {'value': 'solo', 'label': 'soloVersion'.tr()},
  ];

  // Current list of types (defaults + custom ones found in song)
  late List<Map<String, String>> _versionTypes;

  // Currently selected type value
  String _selectedVersionType = 'traditional';

  // Keep track of locally added types to preserve them during rebuilds
  // even if the song model hasn't updated yet
  final List<Map<String, String>> _localCustomTypes = [];

  @override
  void initState() {
    super.initState();
    _initializeVersionTypes();
  }

  @override
  void didUpdateWidget(VersionSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.song != oldWidget.song) {
      _initializeVersionTypes();
    }
  }

  void _initializeVersionTypes() {
    // Start with defaults
    _versionTypes = List.from(_defaultTypes);

    // Add any custom types found in the song's existing versions
    for (final version in widget.song.versions) {
      _ensureTypeExists(version.name);
    }

    // Add any locally added types (preserves selection during async updates)
    for (final type in _localCustomTypes) {
      _ensureTypeExists(type['label']!);
    }
  }

  void _ensureTypeExists(String label) {
    // Check if this label already exists in our types (case insensitive)
    final exists = _versionTypes.any(
      (t) => t['label']?.toLowerCase() == label.toLowerCase(),
    );

    if (!exists && label.toLowerCase() != 'custom') {
      // Create a value key from the label
      final value = label.toLowerCase().replaceAll(RegExp(r'\s+'), '_');

      // Add to list (before the last item if we haven't added 'Custom' yet,
      // but here we are building the list so we just add it)
      _versionTypes.add({'value': value, 'label': label});
    }
  }

  void _addVersion() {
    if (!_formKey.currentState!.validate()) return;

    final customNameInput = _nameController.text.trim();
    String finalName;
    String finalValue;

    // Determine the name and value for the new version
    if (customNameInput.isNotEmpty) {
      // User typed a custom name
      finalName = customNameInput;
      finalValue = finalName.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    } else if (_selectedVersionType == 'custom') {
      // User selected 'Custom' but didn't type anything -> Default to "Custom"
      finalName = 'Custom';
      finalValue = 'custom_version';
    } else {
      // User selected a predefined chip
      final selectedType = _versionTypes.firstWhere(
        (t) => t['value'] == _selectedVersionType,
        orElse: () => {'label': 'Unknown', 'value': 'unknown'},
      );
      finalName = selectedType['label']!;
      finalValue = selectedType['value']!;
    }

    // Create the version object
    final version = SongVersion(
      id: 'version_${DateTime.now().millisecondsSinceEpoch}',
      name: finalName,
      createdAt: DateTime.now(),
    );

    // Update UI state to include this new type as a chip if it's new
    setState(() {
      // Add to local types to preserve it
      if (!_localCustomTypes.any((t) => t['value'] == finalValue)) {
        _localCustomTypes.add({'value': finalValue, 'label': finalName});
      }

      // Remove 'Custom' temporarily to add the new type before it
      final customOption = _versionTypes.firstWhere(
        (t) => t['value'] == 'custom',
        orElse: () => {'value': 'custom', 'label': 'Custom'},
      );
      _versionTypes.removeWhere((t) => t['value'] == 'custom');

      _ensureTypeExists(finalName);

      // Add 'Custom' back at the end
      _versionTypes.add(customOption);

      // Select the new type
      _selectedVersionType = finalValue;

      // Clear input
      _nameController.clear();
    });

    // Notify parent
    widget.onVersionAdded(version);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('versionAddedSuccess'.tr())));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated &&
                  (state.user.role == 'admin' ||
                      state.user.role == 'songwriter')) {
                return _buildAddVersionForm();
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 20),
          _buildExistingVersions(),
        ],
      ),
    );
  }

  Widget _buildAddVersionForm() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'addSongVersion'.tr(),
                  style: AppTextStyles.titleLarge,
                ),
              ),
              const SizedBox(height: 16),

              // Version Type Chips
              Text('versionType'.tr(), style: AppTextStyles.inputLabel),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _versionTypes.map((type) {
                  final isSelected = _selectedVersionType == type['value'];
                  return ChoiceChip(
                    label: Text(type['label']!),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedVersionType = type['value']!;
                        });
                      }
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Custom Name Field
              CustomTextField(
                controller: _nameController,
                label: 'customNameOptional'.tr(),
                hintText: 'enterCustomVersionName'.tr(),
                validator: (value) {
                  if (value != null && value.length > 50) {
                    return 'nameTooLong'.tr();
                  }
                  return null;
                },
                labelText: '',
              ),
              const SizedBox(height: 16),

              // Add Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addVersion,
                  child: Text('addVersion'.tr()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExistingVersions() {
    if (widget.song.versions.isEmpty) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.music_note, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  'noVersionsAdded'.tr(),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'existingVersions'.tr(
                args: [widget.song.versions.length.toString()],
              ),
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 12),
            ...widget.song.versions.map(
              (version) => _buildVersionItem(version),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionItem(SongVersion version) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            version.audioPath != null ? Icons.audio_file : Icons.music_note,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  version.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (version.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    version.notes,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'addedDate'.tr(args: [_formatDate(version.createdAt)]),
                  style: AppTextStyles.caption.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.play_arrow)),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated && state.user.role == 'admin') {
                return IconButton(
                  onPressed: () => _confirmDelete(version),
                  icon: const Icon(Icons.delete, color: Colors.red),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(SongVersion version) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('deleteVersion'.tr()),
        content: Text('deleteVersionConfirm'.tr(args: [version.name])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onVersionDeleted(version.id);
            },
            child: Text(
              'delete'.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
