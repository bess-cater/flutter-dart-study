import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import '../providers/search_provider.dart';
import '../widgets/festival_card.dart';
import '../widgets/filter_modal.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _searchController;
  final _searchSubject = BehaviorSubject<String>();
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    
    //? debounce
    _searchSubject.stream
        .debounceTime(const Duration(milliseconds: 500))
        .listen((query) async {
      if (mounted) {
        setState(() {
          _isSearching = true;
        });
        
      
        await context.read<SearchProvider>().setSearchQuery(query);
        
        if (mounted) {
          setState(() {
            _isSearching = false;
          });
        }
      }
    });
    
    // Set initial state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SearchProvider>(context, listen: false);
      _searchController.text = provider.searchQuery;
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: "Search festivals...",
            border: InputBorder.none,
          ),
          onChanged: (value) {
            _searchSubject.add(value);  // Use BehaviorSubject for debounce
          },
          autofocus: true,
        ),
        actions: [
          
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => const FilterModal(),
              );
            },
          ),
        ],
      ),
      body: Consumer<SearchProvider>(
        builder: (context, provider, child) {
          // Show loading state from provider
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          // Show popular searches when search is empty
          if (_searchController.text.isEmpty) {
            return _buildPopularSearches(context);
          }
          
          // Show search results
          return _buildSearchResults(provider);
        },
      ),
    );
  }

  Widget _buildPopularSearches(BuildContext context) {
    final popularSearches = [
      'Seoul Spring Festa',
      'Seoul Drum Festival',
      'Seoul Music Festival',
      'Seoul World Fireworks Festival',
      'Seoul Street Arts Festival',
    ];

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Popular Searches',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...popularSearches.map((search) => ListTile(
          leading: const Icon(Icons.search),
          title: Text(search),
          onTap: () async {
            _searchController.text = search;
            
            setState(() {
              _isSearching = true;
            });
            
            await context.read<SearchProvider>().setSearchQuery(search);
            
            if (mounted) {
              setState(() {
                _isSearching = false;
              });
            }
          },
        )),
      ],
    );
  }

  Widget _buildSearchResults(SearchProvider provider) {
    if (provider.filteredFestivals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found for "${provider.searchQuery}"',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: provider.filteredFestivals.length,
      itemBuilder: (context, index) {
        final festival = provider.filteredFestivals[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: FestivalCard(
            festival: festival,
            searchQuery: provider.searchQuery,
          ),
        );
      },
    );
  }
} 