import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/festival.dart';
import '../services/elastic_service.dart';

class SearchProvider extends ChangeNotifier {
  String _searchQuery = '';
  String _selectedCategory = '';
  double _startDateRange = 0.0;
  double _endDateRange = 1.0;
  bool _isSearching = false;
  List<Festival> _festivals = [];
  List<Festival> _filteredFestivals = [];
  bool _isLoading = true;
  bool _usingElastic = false;
  
  // Elastic service
  final ElasticService _elasticService = ElasticService();
  
  // Date range constants
  static final DateTime _startDate = DateTime(2025, 3, 31);
  static final DateTime _endDate = DateTime(2025, 12, 31);
  static final int _totalDays = _endDate.difference(_startDate).inDays;

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  double get startDateRange => _startDateRange;
  double get endDateRange => _endDateRange;
  bool get isSearching => _isSearching;
  List<Festival> get filteredFestivals => _filteredFestivals;
  List<Festival> get allFestivals => _festivals;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  int get totalDays => _totalDays;
  bool get isLoading => _isLoading;
  bool get usingElastic => _usingElastic;

  SearchProvider() {
    // No need to call initialize, it's handled in the ElasticService constructor
    _initializeData();
  }

  Future<void> _initializeData() async {
    _isLoading = true;
    notifyListeners();
    
    // Try to load from Elastic first
    try {
      final isConnected = await _elasticService.testConnection();
      
      if (isConnected) {
        _usingElastic = true;
        await _loadFromElastic();
      } else {
        _usingElastic = false;
        await _loadFromLocalJson();
      }
    } catch (e) {
      debugPrint('Error initializing Elastic: $e');
      _usingElastic = false;
      await _loadFromLocalJson();
    }
  }

  Future<void> _loadFromElastic() async {
    try {
      // Load all festivals from Elastic App Search
      _festivals = await _elasticService.getAllFestivals();
      _filteredFestivals = _festivals;
      _isLoading = false;
      notifyListeners();
      debugPrint('Loaded ${_festivals.length} festivals from Elastic');
    } catch (e) {
      _isLoading = false;
      debugPrint('Error loading festivals from Elastic: $e');
      // Fall back to local data
      await _loadFromLocalJson();
    }
  }
  
  Future<void> _loadFromLocalJson() async {
    try {
      _usingElastic = false;
      final String jsonString = await rootBundle.loadString('assets/data.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      _festivals = jsonData.map((json) => Festival.fromJson(json)).toList();
      _filteredFestivals = _festivals;
      _isLoading = false;
      notifyListeners();
      debugPrint('Loaded ${_festivals.length} festivals from local JSON');
    } catch (e) {
      _isLoading = false;
      debugPrint('Error loading festivals from local JSON: $e');
      notifyListeners();
    }
  }

  Future<void> setSearchQuery(String query) async {
    _searchQuery = query;
    _isSearching = query.isNotEmpty;
    debugPrint('Search query set to: $query');
    
    if (_usingElastic) {
      await _applyElasticSearch();
    } else {
      _applyLocalFilters();
    }
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    if (_usingElastic) {
      _applyElasticSearch();
    } else {
      _applyLocalFilters();
    }
  }

  void updateDateRangeValues(double start, double end) {
    _startDateRange = start;
    _endDateRange = end;
    notifyListeners();
  }
  
  // Apply search with current date range values
  void applyDateRangeFilter() {
    if (_usingElastic) {
      _applyElasticSearch();
    } else {
      _applyLocalFilters();
    }
  }
  
  // Set date range and trigger search (original behavior)
  void setDateRange(double start, double end) {
    _startDateRange = start;
    _endDateRange = end;
    
    if (_usingElastic) {
      _applyElasticSearch();
    } else {
      _applyLocalFilters();
    }
  }

  void setSearching(bool searching) {
    _isSearching = searching;
    if (!searching) {
      _searchQuery = '';
    }
    if (_usingElastic) {
      _applyElasticSearch();
    } else {
      _applyLocalFilters();
    }
  }

  void clearFilters() {
    _selectedCategory = '';
    _startDateRange = 0.0;
    _endDateRange = 1.0;
    _searchQuery = '';
    _isSearching = false;
    if (_usingElastic) {
      _loadFromElastic();
    } else {
      _filteredFestivals = _festivals;
      notifyListeners();
    }
  }

  DateTime _getDateFromRange(double range) {
    return _startDate.add(Duration(days: (range * _totalDays).round()));
  }

  Future<void> _applyElasticSearch() async {
    debugPrint('Applying Elastic search with query: $_searchQuery');
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // Calculate date range if filters are applied
      DateTime? startDateFilter;
      DateTime? endDateFilter;
      
      if (_startDateRange > 0.0 || _endDateRange < 1.0) {
        startDateFilter = _getDateFromRange(_startDateRange);
        endDateFilter = _getDateFromRange(_endDateRange);
      }
      
      // Use Elastic App Search service to get filtered results
      _filteredFestivals = await _elasticService.searchFestivals(
        query: _searchQuery,
        category: _selectedCategory,
        startDate: startDateFilter,
        endDate: endDateFilter,
      );
      
      _isLoading = false;
      debugPrint('Found ${_filteredFestivals.length} matches from Elastic');
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      debugPrint('Error applying Elastic search: $e');
      // Fall back to local filtering
      _usingElastic = false;
      _applyLocalFilters();
    }
  }
  
  void _applyLocalFilters() {
    debugPrint('Applying local filters with query: $_searchQuery');
    
    if (_festivals.isEmpty) {
      debugPrint('Festival list is empty!');
      return;
    }
    
    _filteredFestivals = _festivals.where((festival) {
      // Apply search query filter
      final matchesQuery = _searchQuery.isEmpty ||
          festival.festivalName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          festival.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          festival.category.toLowerCase().contains(_searchQuery.toLowerCase());

      if (_searchQuery.isNotEmpty && matchesQuery) {
        debugPrint('Match found: ${festival.festivalName}');
      }

      // Apply category filter
      final matchesCategory = _selectedCategory.isEmpty ||
          festival.category.toLowerCase() == _selectedCategory.toLowerCase();

      // Apply date filter
      final startDate = _getDateFromRange(_startDateRange);
      final endDate = _getDateFromRange(_endDateRange);
      final matchesDate = (festival.startDate.isAfter(startDate) || 
                          festival.startDate.isAtSameMomentAs(startDate)) &&
                         (festival.endDate.isBefore(endDate) || 
                          festival.endDate.isAtSameMomentAs(endDate));

      return matchesQuery && matchesCategory && matchesDate;
    }).toList();

    debugPrint('Found ${_filteredFestivals.length} matches locally');
    notifyListeners();
  }
} 