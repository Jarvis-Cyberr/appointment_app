import '../models/appointment.dart';
import 'storage_service.dart';

class QueueService {
  static int getCurrentToken() {
    final appointments = StorageService.getAllAppointments();
    final inProgress = appointments.where((a) => a.status == 'inProgress').toList();
    if (inProgress.isEmpty) return 0;
    return inProgress.first.queuePosition;
  }

  static List<Appointment> getActiveQueue() {
    final appointments = StorageService.getAllAppointments();
    final queue = appointments
        .where((a) => a.status == 'scheduled' || a.status == 'inProgress')
        .toList();
    queue.sort((a, b) => a.queuePosition.compareTo(b.queuePosition));
    return queue;
  }

  static int assignQueuePosition(DateTime date, String timeSlot) {
    final appointments = StorageService.getAppointmentsByDate(date);
    final slotAppointments = appointments
        .where((a) => a.timeSlot == timeSlot && a.status != 'cancelled')
        .toList();
    return slotAppointments.length + 1;
  }

  static int getUserQueuePosition(String appointmentId) {
    final queue = getActiveQueue();
    for (int i = 0; i < queue.length; i++) {
      if (queue[i].id == appointmentId) return i + 1;
    }
    return -1;
  }

  static int getEstimatedWait(String appointmentId) {
    final position = getUserQueuePosition(appointmentId);
    if (position == -1) return 0;
    return (position - 1) * 15;
  }

  static Future<void> moveQueueForward() async {
    final appointments = StorageService.getAllAppointments();
    
    // Complete current inProgress
    final inProgress = appointments
        .where((a) => a.status == 'inProgress')
        .toList();
    for (var apt in inProgress) {
      apt.status = 'completed';
      await StorageService.updateAppointment(apt);
    }

    // Move next scheduled to inProgress
    final scheduled = appointments
        .where((a) => a.status == 'scheduled')
        .toList();
    scheduled.sort((a, b) => a.queuePosition.compareTo(b.queuePosition));
    
    if (scheduled.isNotEmpty) {
      scheduled.first.status = 'inProgress';
      await StorageService.updateAppointment(scheduled.first);
    }
  }

  static String getWaitTimeText(int minutes) {
    if (minutes == 0) return 'You are next!';
    if (minutes < 60) return '$minutes mins';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }
} // Queue Service - Handles all queue logic, position assignment and wait time calculation