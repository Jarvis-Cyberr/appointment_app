import 'package:flutter/material.dart';
import '../models/appointment.dart';

class QueueCard extends StatelessWidget {
  final Appointment appointment;
  final int position;
  final bool isCurrentlyServing;

  const QueueCard({
    super.key,
    required this.appointment,
    required this.position,
    this.isCurrentlyServing = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: isCurrentlyServing
            ? const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF9C63FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isCurrentlyServing ? null : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isCurrentlyServing
                ? const Color(0xFF6C63FF).withOpacity(0.4)
                : Colors.grey.withOpacity(0.1),
            blurRadius: isCurrentlyServing ? 15 : 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: isCurrentlyServing
            ? null
            : Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Position number
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isCurrentlyServing
                    ? Colors.white.withOpacity(0.2)
                    : const Color(0xFF6C63FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: isCurrentlyServing
                    ? const Icon(Icons.person_pin,
                        color: Colors.white, size: 24)
                    : Text(
                        '$position',
                        style: const TextStyle(
                          color: Color(0xFF6C63FF),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color:
                          isCurrentlyServing ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    appointment.serviceType,
                    style: TextStyle(
                      fontSize: 12,
                      color: isCurrentlyServing
                          ? Colors.white70
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  appointment.timeSlot,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isCurrentlyServing
                        ? Colors.white
                        : const Color(0xFF6C63FF),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isCurrentlyServing
                        ? Colors.white.withOpacity(0.2)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isCurrentlyServing
                        ? 'Now Serving'
                        : '~${(position - 1) * 15} mins',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isCurrentlyServing ? Colors.white : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}