import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/event_model.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';

class EventDetailScreen extends ConsumerWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  String _formatEventDate(String dateStr) {
    try {
      // Assuming dateStr is in yyyy-MM-dd format from backend
      final DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd-MMM, yyyy').format(date);
    } catch (e) {
      return dateStr; // Fallback to original string if parsing fails
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to changes for this specific event in the dashboard state
    final dashboardState = ref.watch(dashboardNotifierProvider);
    final currentEvent = dashboardState.events.firstWhere(
      (e) => e.id == event.id,
      orElse: () => event,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Event Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentEvent.imageUrl != null)
              CachedNetworkImage(
                imageUrl: currentEvent.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 300,
                  color: Colors.grey[900],
                  child: const Center(child: CircularProgressIndicator(color: Colors.orange)),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 300,
                  color: Colors.grey[900],
                  child: const Icon(Icons.error, color: Colors.white),
                ),
              )
            else
              Image.asset(
                'assets/images/event_placeholder.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          currentEvent.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => ref
                            .read(dashboardNotifierProvider.notifier)
                            .toggleLike(currentEvent.id, 'event'),
                        icon: Icon(
                          currentEvent.isLiked ? Icons.favorite : Icons.favorite_border,
                          color: currentEvent.isLiked ? Colors.red : Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_rounded, color: Colors.orange, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              currentEvent.location ?? 'TBA',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, color: Colors.orange, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '${_formatEventDate(currentEvent.date)}  •  ${currentEvent.time}',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'About Event',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentEvent.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
