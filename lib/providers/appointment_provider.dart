import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/storage_service.dart';
import '../services/queue_service.dart';

class AppointmentProvider extends ChangeNotifier {
  List<Appointment> _appointments = [];
  String _searchQuery = '';
  String _filterStatus = 'All';
  String _filterService = 'All';
  DateTime? _filterDate;
  bool _isLoading = false;

  List<Appointment> get appointments => _filteredAppointments();
  List<Appointment> get allAppointments => _appointments;
  String get searchQuery => _searchQuery;
  String get filterStatus => _filterStatus;
  String get filterService => _filterService;
  DateTime? get filterDate => _filterDate;
  bool get isLoading => _isLoading;

  List<Appointment> get todayAppointments =>
      _appointments.where((a) => a.isToday).toList();

  List<Appointment> get activeQueue => QueueService.getActiveQueue();

  int get currentToken => QueueService.getCurrentToken();

  List<Appointment> get scheduledAppointments =>
      _appointments.where((a) => a.status == 'scheduled').toList();

  List<Appointment> get completedAppointments =>
      _appointments.where((a) => a.status == 'completed').toList();

  List<Appointment> get cancelledAppointments =>
      _appointments.where((a) => a.status == 'cancelled').toList();

  void loadAppointments() {
    _appointments = StorageService.getAllAppointments();
    notifyListeners();
  }

  List<Appointment> _filteredAppointments() {
    return _appointments.where((apt) {
      final matchesSearch = _searchQuery.isEmpty ||
          apt.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          apt.appointmentId.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus =
          _filterStatus == 'All' || apt.status == _filterStatus.toLowerCase();

      final matchesService =
          _filterService == 'All' || apt.serviceType == _filterService;

      final matchesDate = _filterDate == null ||
          (apt.dateTime.year == _filterDate!.year &&
              apt.dateTime.month == _filterDate!.month &&
              apt.dateTime.day == _filterDate!.day);

      return matchesSearch && matchesStatus && matchesService && matchesDate;
    }).toList();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setFilterService(String service) {
    _filterService = service;
    notifyListeners();
  }

  void setFilterDate(DateTime? date) {
    _filterDate = date;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterStatus = 'All';
    _filterService = 'All';
    _filterDate = null;
    notifyListeners();
  }

  Future<bool> bookAppointment(Appointment appointment) async {
    _isLoading = true;
    notifyListeners();

    // Check slot availability
    if (!StorageService.isSlotAvailable(
        appointment.dateTime, appointment.timeSlot)) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Assign queue position
    appointment.queuePosition = QueueService.assignQueuePosition(
        appointment.dateTime, appointment.timeSlot);

    await StorageService.saveAppointment(appointment);
    loadAppointments();

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> cancelAppointment(Appointment appointment) async {
    appointment.status = 'cancelled';
    await StorageService.updateAppointment(appointment);
    loadAppointments();
  }

  Future<void> completeAppointment(Appointment appointment) async {
    appointment.status = 'completed';
    await StorageService.updateAppointment(appointment);
    loadAppointments();
  }

  Future<void> markInProgress(Appointment appointment) async {
    appointment.status = 'inProgress';
    await StorageService.updateAppointment(appointment);
    loadAppointments();
  }

  Future<void> moveQueueForward() async {
    await QueueService.moveQueueForward();
    loadAppointments();
  }

  Future<void> rescheduleAppointment(
      Appointment appointment, DateTime newDate, String newTimeSlot) async {
    if (!StorageService.isSlotAvailable(newDate, newTimeSlot)) return;
    appointment.dateTime = newDate;
    appointment.timeSlot = newTimeSlot;
    appointment.status = 'scheduled';
    appointment.queuePosition =
        QueueService.assignQueuePosition(newDate, newTimeSlot);
    await StorageService.updateAppointment(appointment);
    loadAppointments();
  }

  int getUserPosition(String appointmentId) {
    return QueueService.getUserQueuePosition(appointmentId);
  }

  int getEstimatedWait(String appointmentId) {
    return QueueService.getEstimatedWait(appointmentId);
  }
}