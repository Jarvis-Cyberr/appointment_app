import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'appointment.g.dart';

enum AppointmentStatus { scheduled, inProgress, completed, cancelled }

enum ServiceType { clinic, salon, college, serviceCenter }

@HiveType(typeId: 0)
class Appointment extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String serviceType;

  @HiveField(3)
  late DateTime dateTime;

  @HiveField(4)
  late String status;

  @HiveField(5)
  late int queuePosition;

  @HiveField(6)
  late String timeSlot;

  @HiveField(7)
  late DateTime createdAt;

  @HiveField(8)
  late String notes;

  Appointment({
    String? id,
    required this.name,
    required this.serviceType,
    required this.dateTime,
    this.status = 'scheduled',
    this.queuePosition = 0,
    required this.timeSlot,
    this.notes = '',
    DateTime? createdAt,
  }) {
    this.id = id ?? const Uuid().v4();
    this.createdAt = createdAt ?? DateTime.now();
  }

  String get appointmentId => 'APT-${id.substring(0, 6).toUpperCase()}';

  int get estimatedWaitMinutes => queuePosition * 15;

  bool get isToday {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  AppointmentStatus get statusEnum {
    switch (status) {
      case 'inProgress':
        return AppointmentStatus.inProgress;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      default:
        return AppointmentStatus.scheduled;
    }
  }
}