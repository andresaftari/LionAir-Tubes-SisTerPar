import 'package:flutter/material.dart';

class TicketWidget extends StatelessWidget {
  final String location;
  final String time;

  const TicketWidget({super.key, required this.location, required this.time});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location: $location'),
            Text('Time: $time'),
          ],
        ),
      ),
    );
  }
}