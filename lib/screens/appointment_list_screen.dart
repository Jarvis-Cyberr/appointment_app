import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/appointment_provider.dart';
import '../widgets/appointment_card.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FF),
      appBar: AppBar(
        title: const Text(
          'Appointments',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          isScrollable: true,
          tabs: [
            Tab(text: 'All (${provider.allAppointments.length})'),
            Tab(text: 'Scheduled (${provider.scheduledAppointments.length})'),
            Tab(text: 'Completed (${provider.completedAppointments.length})'),
            Tab(text: 'Cancelled (${provider.cancelledAppointments.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AppointmentTab(appointments: provider.allAppointments),
          _AppointmentTab(appointments: provider.scheduledAppointments),
          _AppointmentTab(appointments: provider.completedAppointments),
          _AppointmentTab(appointments: provider.cancelledAppointments),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _AppointmentTab extends StatelessWidget {
  final List appointments;

  const _AppointmentTab({required this.appointments});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppointmentProvider>();

    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today,
                size: 80,
                color: const Color(0xFF6C63FF).withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text(
              'No appointments here',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (_, i) {
        final apt = appointments[i];
        return Slidable(
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              if (apt.status == 'scheduled')
                SlidableAction(
                  onPressed: (_) async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        title: const Text('Cancel Appointment'),
                        content: Text(
                            'Cancel appointment for ${apt.name}?'),
                        actions: [
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: const Text('No')),
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, true),
                              child: const Text('Yes',
                                  style:
                                      TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      provider.cancelAppointment(apt);
                    }
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.cancel,
                  label: 'Cancel',
                  borderRadius: BorderRadius.circular(16),
                ),
              if (apt.status == 'scheduled')
                SlidableAction(
                  onPressed: (_) {
                    provider.markInProgress(apt);
                  },
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  icon: Icons.play_arrow,
                  label: 'Start',
                  borderRadius: BorderRadius.circular(16),
                ),
            ],
          ),
          child: AppointmentCard(
            appointment: apt,
            onTap: () => _showDetails(context, apt, provider),
          ),
        );
      },
    );
  }

  void _showDetails(context, apt, provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(apt.name,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('ID: ${apt.appointmentId}',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            _DetailRow(icon: Icons.medical_services,
                label: 'Service', value: apt.serviceType),
            _DetailRow(icon: Icons.access_time,
                label: 'Time', value: apt.timeSlot),
            _DetailRow(icon: Icons.calendar_today,
                label: 'Date',
                value: '${apt.dateTime.day}/${apt.dateTime.month}/${apt.dateTime.year}'),
            _DetailRow(icon: Icons.confirmation_number,
                label: 'Queue Position',
                value: '#${apt.queuePosition}'),
            _DetailRow(icon: Icons.info,
                label: 'Status', value: apt.status),
            if (apt.notes.isNotEmpty)
              _DetailRow(icon: Icons.note,
                  label: 'Notes', value: apt.notes),
            const SizedBox(height: 16),
            if (apt.status == 'scheduled')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    provider.completeAppointment(apt);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Mark Completed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6C63FF)),
          const SizedBox(width: 12),
          Text('$label: ',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
            child: Text(value,
                style:
                    const TextStyle(fontSize: 14, color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}