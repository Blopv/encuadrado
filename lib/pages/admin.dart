import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../components/navbar.dart';
import '../components/service_card.dart';
import '../services/firebase_services.dart';
import '../services/calendar_service.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();
  final CalendarService _calendarService = CalendarService();
  List<Map<String, dynamic>> _services = [];
  List<Appointment> _calendarAppointments = [];
  String _userName = 'Usuario';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchServices();
    _fetchHolidays();
    _fetchReservedAppointments();
  }

  Future<void> _fetchServices() async {
    try {
      final services = await _firebaseService.getServices();
      services.sort((a, b) {
        final createdAtA = a['createdAt'] as Timestamp?;
        final createdAtB = b['createdAt'] as Timestamp?;
        if (createdAtA == null || createdAtB == null) return 0;
        return createdAtB.compareTo(createdAtA);
      });

      setState(() {
        _services = services;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener los servicios: $e')),
      );
    }
  }

  Future<void> _fetchUserName() async {
    try {
      final userName = await _firebaseService.getUserName();
      setState(() {
        _userName = userName;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener el nombre de usuario: $e')),
      );
    }
  }

  Future<void> _fetchHolidays() async {
    try {
      final holidays = await _calendarService.fetchHolidays();
      final holidayAppointments = holidays.map((holiday) {
        final holidayDate = DateTime.parse(holiday['fecha']);
        return Appointment(
          startTime: holidayDate,
          endTime: holidayDate.add(const Duration(hours: 23, minutes: 59)),
          subject: holiday['nombre'],
          notes: holiday['tipo'],
          color: Colors.red,
        );
      }).toList();

      setState(() {
        _calendarAppointments.addAll(holidayAppointments);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener feriados: $e')),
      );
    }
  }

  Future<void> _fetchReservedAppointments() async {
    try {
      final professionalId = _auth.currentUser?.uid;
      if (professionalId == null) return;

      final reservedAppointments = await _firebaseService.getAppointmentsForProfessional(professionalId);
      print(reservedAppointments);

      for (var appointment in reservedAppointments) {
        final serviceInfo = await _firebaseService.getServiceById(appointment['serviceId']);
        final userInfo = await _firebaseService.getProfessionalInfo(appointment['userId']);

        final DateTime startTime = DateTime.parse(
            '${appointment['dia'].split('/')[2]}-${appointment['dia'].split('/')[1]}-${appointment['dia'].split('/')[0]}T${appointment['horaInicial']}:00');

        final DateTime endTime = DateTime.parse(
            '${appointment['dia'].split('/')[2]}-${appointment['dia'].split('/')[1]}-${appointment['dia'].split('/')[0]}T${appointment['horaFinal']}:00');

        _calendarAppointments.add(Appointment(
          startTime: startTime,
          endTime: endTime,
          subject: serviceInfo['nombreServicio'] ?? 'Sin título',
          notes: 'Cliente: ${userInfo['name'] ?? 'Desconocido'}\n'
              'Correo: ${userInfo['email'] ?? 'N/A'}\n'
              'Hora: ${appointment['horaInicial']}\n'
              'Duración: ${appointment['duracion']} minutos\n'
              'Precio: ${appointment['precio']} CLP',

          color: Colors.blue,
        ));
      }

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener reservas: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F4F8),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 700),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildUserInfo(user),
                              const SizedBox(height: 16),
                              const Text(
                                'Mis Servicios',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildServices(),
                              const SizedBox(height: 16),
                              const Text(
                                'Calendario Semanal',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildCalendar(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: NavBarWidget(
                onServiceAdded: _fetchServices,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(User? user) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF5433FF),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _userName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? 'correo@example.com',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServices() {
    if (_services.isEmpty) {
      return const Center(
        child: Text(
          'No hay servicios aún, ¡Agrega tu servicio!',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _services.map((service) {
          return ServiceCard(
            nombreServicio: service['nombreServicio'] ?? 'N/A',
            dias: List<String>.from(service['dias'] ?? []),
            horarioInicio: service['horario']['inicio'] ?? 'N/A',
            horarioFin: service['horario']['fin'] ?? 'N/A',
            duracionMin: (service['duracionMin'] as num?)?.toInt() ?? 0,
            duracionMax: (service['duracionMax'] as num?)?.toInt() ?? 0,
            precio: (service['precio'] as num?)?.toInt() ?? 0,
            profesional: service['nombreProfesional'] ?? 'N/A',
            correoProfesional: service['correoProfesional'] ?? 'N/A',
            isUser: false,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: SfCalendar(
        view: CalendarView.week,
        firstDayOfWeek: 1,
        todayHighlightColor: const Color(0xFF5433FF),
        headerStyle: const CalendarHeaderStyle(
          textAlign: TextAlign.center,
          backgroundColor: Colors.white,
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        timeSlotViewSettings: const TimeSlotViewSettings(
          timeFormat: 'HH:mm',
          timeTextStyle: TextStyle(fontSize: 12, color: Colors.black),
        ),
        appointmentBuilder: (context, details) {
          final Appointment appointment = details.appointments.first;
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: appointment.color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              appointment.subject,
              style: const TextStyle(fontSize: 10, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          );
        },
        dataSource: AppointmentDataSource(_calendarAppointments),
        onTap: (CalendarTapDetails details) {
          if (details.appointments != null && details.appointments!.isNotEmpty) {
            final appointment = details.appointments!.first as Appointment;
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(appointment.subject),
                  content: Text(appointment.notes ?? 'No hay información adicional.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
