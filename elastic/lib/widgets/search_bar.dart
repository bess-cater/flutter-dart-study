import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import '../providers/search_provider.dart';

class CustomSearchBar extends StatefulWidget {
  final VoidCallback onFilterTap;
  final VoidCallback onSearchTap;

  const CustomSearchBar({
    Key? key,
    required this.onFilterTap,
    required this.onSearchTap,
  }) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final _searchSubject = BehaviorSubject<String>();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchSubject.stream
        .debounceTime(const Duration(milliseconds: 500))
        .listen((query) async {
      debugPrint('Search query (debounced): $query');
      if (mounted) {
        setState(() {
          _isSearching = true;
        });
        
        try {
          await context.read<SearchProvider>().setSearchQuery(query);
        } catch (e) {
          debugPrint('Error during search: $e');
        } finally {
          if (mounted) {
            setState(() {
              _isSearching = false;
            });
          }
        }
      }
    });
    
    // Set initial value from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final query = context.read<SearchProvider>().searchQuery;
      if (query.isNotEmpty) {
        _controller.text = query;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  _isSearching 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Search festivals...',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        _searchSubject.add(value);
                      },
                      onTap: widget.onSearchTap,
                      readOnly: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: widget.onFilterTap,
          ),
        ],
      ),
    );
  }
} 