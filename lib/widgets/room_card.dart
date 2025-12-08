import 'package:flutter/material.dart';

class RoomCard extends StatelessWidget {
  final String roomName;
  final int lightsCount;
  final bool isOn;
  final VoidCallback onTap;

  const RoomCard({
    super.key,
    required this.roomName,
    required this.lightsCount,
    required this.isOn,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isOn
              ? LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isOn ? null : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isOn
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lightbulb,
              size: 40,
              color: isOn ? Colors.white : Colors.grey.shade400,
            ),
            const Spacer(),
            Text(
              roomName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isOn ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$lightsCount lights',
              style: TextStyle(
                fontSize: 14,
                color: isOn ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
