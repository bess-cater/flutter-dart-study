import 'package:elastic_app_search/elastic_app_search.dart';
import 'package:flutter/material.dart';
import '../models/festival.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ElasticService {
  // Singleton pattern
  static final ElasticService _instance = ElasticService._internal();
  factory ElasticService() => _instance;
  
  
  static final String _endPoint = dotenv.env['ENDPOINT']!;
  static final String _searchKey = dotenv.env['SEARCH_KEY']!;
  static final String _engineName = dotenv.env['ENGINE_NAME']!;
  
  late final ElasticAppSearch _appSearch;
  late final Dio _dio;
  bool _isInitialized = false;

  // Private constructor that initializes the appSearch instance
  ElasticService._internal() {
    initialize();
  }
  
  // Initialize the client - now safe to call multiple times
  void initialize() {
    if (_isInitialized) {
      debugPrint('ElasticService already initialized');
      return;
    }
    
    // Log to help with debugging
    debugPrint('Creating ElasticAppSearch instance with:');
    debugPrint('Endpoint: $_endPoint');
    debugPrint('Engine: $_engineName');
    
    // Initialize Dio for direct API calls
    _dio = Dio(BaseOptions(
      baseUrl: _endPoint,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_searchKey',
      },
    ));
      
    _appSearch = ElasticAppSearch(
      endPoint: _endPoint,
      searchKey: _searchKey,
    );
    _isInitialized = true;
    debugPrint('ElasticService initialized with endpoint: $_endPoint');
  }
  
  // Test connection using direct Dio HTTP request (bypassing the library)
  Future<bool> testConnectionDirect() async {
    try {
      final searchUrl = '$_endPoint/api/as/v1/engines/$_engineName/search';
      debugPrint('Testing direct connection to: $searchUrl');
      
      // Direct curl equivalent 
      final response = await _dio.post(
        '/api/as/v1/engines/$_engineName/search',
        data: {
          'query': 'music'
        },
      );
      
      debugPrint('Direct API response status: ${response.statusCode}');
      debugPrint('Direct API response data: ${response.data}');
      
      if (response.statusCode == 200 && response.data != null) {
        final results = response.data['results'] as List<dynamic>;
        debugPrint('Direct API call: Found ${results.length} results');
        if (results.isNotEmpty) {
          debugPrint('First result: ${results.first}');
        }
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Direct test connection failed: $e');
      return false;
    }
  }
  
  // Test connection with a simple search
  Future<bool> testConnection() async {
    try {
      debugPrint('Testing connection to: $_endPoint');
      debugPrint('Using engine: $_engineName');
      debugPrint('With search key: ${_searchKey.substring(0, 10)}...');
      
      // First try a direct API call
      final directResult = await testConnectionDirect();
      if (!directResult) {
        debugPrint('Direct API call failed, trying through library...');
      }
      
      final response = await _appSearch
          .engine(_engineName)
          .query("music")
          .get();
      
      debugPrint('Test connection successful! ${response.results.length} results');
      if (response.results.isNotEmpty) {
        debugPrint('Sample result: ${response.results.first.data}');
        // Print the raw structure of the first result
        debugPrint('Raw result keys: ${response.results.first.data?.keys.toList()}');
        // Examine the full response structure
        final firstResult = response.results.first;
        debugPrint('Result fields: ${jsonEncode(firstResult)}');
      }
      return true;
    } catch (e) {
      debugPrint('Test connection failed: $e');
      return false;
    }
  }
  
  // Search festivals with filtering options
  Future<List<Festival>> searchFestivals({
    required String query,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    debugPrint('Searching for: "$query" using elastic_app_search package');
    
    try {
      // Create query using the ElasticAppSearch API
      ElasticEngine engine = _appSearch.engine(_engineName);
      
      // Start building the query
      ElasticQuery elasticQuery = engine.query(query)
        .resultField("content")
        .resultField("festival_name")
        .resultField("place")
        .resultField("category")
        .resultField("start_date")
        .resultField("end_date");
      
      // Add category filter if provided
      if (category != null && category.isNotEmpty) {
        elasticQuery = elasticQuery.filter("category", isEqualTo: category);
      }
      
      // Add date range filters using DateTime objects directly
      if (startDate != null) {
        debugPrint('Adding start_date filter: isGreaterThanOrEqualTo $startDate');
        elasticQuery = elasticQuery.filter(
          "start_date", 
          isGreaterThanOrEqualTo: startDate
        );
      }
      
      if (endDate != null) {
        debugPrint('Adding end_date filter: isLessThan $endDate');
        elasticQuery = elasticQuery.filter(
          "end_date", 
          isLessThan: endDate
        );
      }
      
      // Execute the search
      debugPrint('Executing elastic_app_search query...');
      ElasticResponse response = await elasticQuery.get();
      
      debugPrint('Found ${response.results.length} results');
      
      // Map results to Festival objects
      final festivals = response.results.map((result) {
        try {
          final data = result.data;
          if (data == null) return null;
          
          return Festival(
            content: _getFieldValue(data, 'content'),
            festivalName: _getFieldValue(data, 'festival_name'),
            place: _getFieldValue(data, 'place'),
            category: _getFieldValue(data, 'category'),
            startDate: _parseDate(_getFieldValue(data, 'start_date')),
            endDate: _parseDate(_getFieldValue(data, 'end_date')),
          );
        } catch (e) {
          debugPrint('Error parsing festival data: $e');
          return null;
        }
      }).whereType<Festival>().toList();
      
      return festivals;
    } catch (e) {
      debugPrint('Error in elastic_app_search: $e');
      // Fall back to direct search if the package fails
      return searchFestivalsDirect(
        query: query,
        category: category,
        startDate: startDate,
        endDate: endDate,
      );
    }
  }
  
  // Search festivals with direct API call
  Future<List<Festival>> searchFestivalsDirect({
    required String query,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    debugPrint('Direct search for: "$query"');
    debugPrint('Date filters: start=$startDate, end=$endDate');
    
    try {
      // Build the request data to match the Elastic Enterprise Search API format
      final Map<String, dynamic> requestData = {
        'query': query,
        'result_fields': {
          'content': { 'raw': {} },
          'festival_name': { 'raw': {} },
          'place': { 'raw': {} },
          'category': { 'raw': {} },
          'start_date': { 'raw': {} },
          'end_date': { 'raw': {} },
        },
      };
      
      // Build date filters if dates are provided
      if (startDate != null || endDate != null) {
        // Create a list for all filters
        final List<Map<String, dynamic>> allFilters = [];
        
        // Add category filter if provided
        if (category != null && category.isNotEmpty) {
          allFilters.add({
            'category': category
          });
        }
        
        // Add date filters
        if (startDate != null) {
          // Format date as string
          final startDateStr = startDate.toIso8601String().split('T')[0];
          allFilters.add({
            'start_date': startDateStr
          });
          debugPrint('Adding start_date filter: $startDateStr');
        }
        
        if (endDate != null) {
          // Format date as string
          final endDateStr = endDate.toIso8601String().split('T')[0];
          allFilters.add({
            'end_date': endDateStr
          });
          debugPrint('Adding end_date filter: $endDateStr');
        }
        
        // Add filter structure to request data
        requestData['filters'] = {
          'all': allFilters,
          'none': [],
          'any': []
        };
        
        debugPrint('Filter structure: ${jsonEncode(requestData['filters'])}');
      } else if (category != null && category.isNotEmpty) {
        // If only category filter is provided
        final List<Map<String, dynamic>> allFilters = [];
        allFilters.add({
          'category': category
        });
        
        requestData['filters'] = {
          'all': allFilters,
          'none': [],
          'any': []
        };
      }
      
      // Print the complete request for debugging
      debugPrint('Direct API request: ${jsonEncode(requestData)}');
      
      // Execute the direct request
      final response = await _dio.post(
        '/api/as/v1/engines/$_engineName/search',
        data: requestData,
      );
      
      debugPrint('Direct API response status: ${response.statusCode}');
      
      if (response.statusCode == 200 && response.data != null) {
        final results = response.data['results'] as List<dynamic>;
        debugPrint('Found ${results.length} results');
        
        if (results.isNotEmpty) {
          debugPrint('First result structure: ${results.first}');
        }
        
        // Map the results to Festival objects
        final festivals = results.map((resultData) {
          try {
            // Extract raw values from the nested structure
            return Festival(
              content: _extractRawValue(resultData, 'content'),
              festivalName: _extractRawValue(resultData, 'festival_name'),
              place: _extractRawValue(resultData, 'place'),
              category: _extractRawValue(resultData, 'category'),
              startDate: _parseDate(_extractRawValue(resultData, 'start_date')),
              endDate: _parseDate(_extractRawValue(resultData, 'end_date')),
            );
          } catch (e) {
            debugPrint('Error parsing festival data: $e');
            return null;
          }
        }).whereType<Festival>().toList();
        
        debugPrint('Parsed ${festivals.length} festivals');
        return festivals;
      }
      
      return [];
    } catch (e) {
      debugPrint('Error in direct search: $e');
      return [];
    }
  }
  
  // Extract raw values from the Elastic Search response
  String _extractRawValue(dynamic data, String fieldName) {
    if (data == null) return '';
    
    try {
      final fieldData = data[fieldName];
      if (fieldData == null) return '';
      
      if (fieldData is Map && fieldData.containsKey('raw')) {
        return fieldData['raw']?.toString() ?? '';
      }
      
      return fieldData.toString();
    } catch (e) {
      debugPrint('Error extracting $fieldName: $e');
      return '';
    }
  }
  
  // Helper to extract field values from the elastic_app_search response
  String _getFieldValue(Map<String, dynamic> data, String fieldName) {
    if (data.containsKey(fieldName)) {
      return data[fieldName]?.toString() ?? '';
    }
    return '';
  }
  
  // Helper method to parse dates safely
  DateTime _parseDate(dynamic dateStr) {
    try {
      if (dateStr is DateTime) return dateStr;
      if (dateStr == null || dateStr.toString().isEmpty) return DateTime.now();
      return DateTime.parse(dateStr.toString());
    } catch (e) {
      debugPrint('Error parsing date: $e for value: $dateStr');
      return DateTime.now();
    }
  }
  
  // Get all festivals (no filtering) using direct API call
  Future<List<Festival>> getAllFestivals() async {
    debugPrint('Getting all festivals using direct API call');
    return searchFestivalsDirect(query: '');
  }
} 