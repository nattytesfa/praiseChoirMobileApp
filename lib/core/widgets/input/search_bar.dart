import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final String hintText;
  final void Function(String) onSearch;
  final void Function() onClear;
  final Duration debounceDuration;

  const SearchBar({
    super.key,
    this.hintText = 'Search...',
    required this.onSearch,
    required this.onClear,
    this.debounceDuration = const Duration(milliseconds: 300),
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (_controller.text.isEmpty) {
      widget.onClear();
    } else {
      Future.delayed(widget.debounceDuration, () {
        if (_controller.text.isNotEmpty) {
          widget.onSearch(_controller.text);
        }
      });
    }
  }

  void _clearSearch() {
    _controller.clear();
    _focusNode.unfocus();
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(icon: const Icon(Icons.clear), onPressed: _clearSearch)
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
    );
  }
}

class SongSearchBar extends StatelessWidget {
  final void Function(String) onSearch;
  final void Function() onClear;

  const SongSearchBar({
    super.key,
    required this.onSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      hintText: 'Search songs by title or lyrics...',
      onSearch: onSearch,
      onClear: onClear,
    );
  }
}
