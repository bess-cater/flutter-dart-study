import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';

class FilterModal extends StatefulWidget {
  const FilterModal({Key? key}) : super(key: key);

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  // BehaviorSubject for debouncing date range changes
  final _dateRangeSubject = BehaviorSubject<RangeValues>();
  
  @override
  void initState() {
    super.initState();
    
    // Set up debounce for date range changes
    _dateRangeSubject.stream
      .debounceTime(const Duration(milliseconds: 500))
      .listen((values) {
        if (!mounted) return;
        final provider = Provider.of<SearchProvider>(context, listen: false);
        // Use the method that triggers search after debounce
        provider.applyDateRangeFilter();
      });
  }
  
  @override
  void dispose() {
    // Clean up resources
    _dateRangeSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Consumer<SearchProvider>(
            builder: (context, provider, child) {
              return Wrap(
                spacing: 8,
                children: [
                  'music',
                  'performance',
                  'culture',
                  'traditional',
                  'art',
                  'opera',
                  'fireworks',
                  'nature'
                ].map((category) {
                  return ChoiceChip(
                    label: Text(category),
                    selected: provider.selectedCategory == category,
                    onSelected: (selected) {
                      provider.setSelectedCategory(selected ? category : '');
                    },
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Date Range',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Consumer<SearchProvider>(
            builder: (context, provider, child) {
              final startDate = provider.startDate.add(
                Duration(days: (provider.startDateRange * provider.totalDays).round()),
              );
              final endDate = provider.startDate.add(
                Duration(days: (provider.endDateRange * provider.totalDays).round()),
              );
              
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'From: ${startDate.day}/${startDate.month}/${startDate.year}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'To: ${endDate.day}/${endDate.month}/${endDate.year}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: RangeValues(
                      provider.startDateRange,
                      provider.endDateRange,
                    ),
                    min: 0.0,
                    max: 1.0,
                    divisions: provider.totalDays,
                    labels: RangeLabels(
                      '${startDate.day}/${startDate.month}/${startDate.year}',
                      '${endDate.day}/${endDate.month}/${endDate.year}',
                    ),
                    onChanged: (RangeValues values) {
                      // Update UI values immediately
                      provider.updateDateRangeValues(values.start, values.end);
                      // Queue the debounced search
                      _dateRangeSubject.add(values);
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  context.read<SearchProvider>().clearFilters();
                },
                child: const Text('Clear'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 