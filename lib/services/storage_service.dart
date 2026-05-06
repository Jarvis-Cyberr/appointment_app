import 'package:hive_flutter/hive_flutter.dart';
import '../models/appointment.dart';

class StorageService {
  static const _boxName = 'appointments';
  static Box<Appointment>? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(AppointmentAdapter());
    _box = await Hive.openBox<Appointment>(_boxName);
  }

  static List<Appointment> getAllAppointments() {
    return _box?.values.toList() ?? [];
  }

  static Future<void> saveAppointment(Appointment appointment) async {
    await _box?.put(appointment.id, appointment);
  }

  static Future<void> deleteAppointment(String id) async {
    await _box?.delete(id);
  }

  static Future<void> updateAppointment(Appointment appointment) async {
    await _box?.put(appointment.id, appointment);
  }

  static List<Appointment> getAppointmentsByDate(DateTime date) {
    return _box?.values.where((a) {
          return a.dateTime.year == date.year &&
              a.dateTime.month == date.month &&
              a.dateTime.day == date.day;
        }).toList() ??
        [];
  }

  static bool isSlotAvailable(DateTime dateTime, String timeSlot) {
    final existing = _box?.values.where((a) {
          return a.timeSlot == timeSlot &&
              a.dateTime.year == dateTime.year &&
              a.dateTime.month == dateTime.month &&
              a.dateTime.day == dateTime.day &&
              a.status != 'cancelled';
        }).toList() ??
        [];
    return existing.length < 3;
  }
}