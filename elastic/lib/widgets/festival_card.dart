import 'package:flutter/material.dart';
import '../models/festival.dart';

class FestivalCard extends StatelessWidget {
  final Festival festival;
  final String searchQuery;

  const FestivalCard({
    Key? key,
    required this.festival,
    required this.searchQuery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool matchesName = searchQuery.isNotEmpty && 
        festival.festivalName.toLowerCase().contains(searchQuery.toLowerCase());

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              festival.festivalName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: matchesName ? Colors.blue : null,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${festival.startDate.day}/${festival.startDate.month}/${festival.startDate.year} - '
                  '${festival.endDate.day}/${festival.endDate.month}/${festival.endDate.year}',
                ),
                const SizedBox(width: 16),
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    festival.place,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(festival.category),
              backgroundColor: Colors.grey[200],
            ),
          ],
        ),
      ),
    );
  }
} 