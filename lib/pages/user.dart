import 'package:flutter/material.dart';
import 'package:encuadrado/services/firebase_services.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../components/navbar.dart';
import '../components/appointment_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/calendar_service.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({Key? key}) : super(key: key);

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();
  final CalendarService _calendarService = CalendarService();
  List<Map<String, dynamic>> _appointmentsList = []; 
  List<Appointment> _calendarAppointments = []; 
  String _userName = 'Usuario';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchUserAppointments();
    _fetchHolidays();
  }

  Future<void> _fetchUserAppointments() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final appointments = await _firebaseService.getUserAppointments(userId);

      final List<Map<String, dynamic>> enrichedAppointments = [];
      for (var appointment in appointments) {
        final serviceInfo = await _firebaseService.getServiceById(appointment['serviceId']);
        final professionalInfo = await _firebaseService.getProfessionalInfo(appointment['professionalId']);

        enrichedAppointments.add({
          'titulo': serviceInfo['nombreServicio'] ?? 'Sin título',
          'profesional': professionalInfo['name'] ?? 'N/A',
          'correo': professionalInfo['email'] ?? 'N/A',
          'fecha': appointment['dia'],
          'hora': appointment['horaInicial'],
          'duracion': appointment['duracion'],
          'precio': appointment['precio'],
        });

        final String dia = appointment['dia'];
        final String horaInicial = appointment['horaInicial'];
        final String horaFinal = appointment['horaFinal'];

        final DateTime startTime = DateTime.parse(
            '${dia.split('/')[2]}-${dia.split('/')[1]}-${dia.split('/')[0]}T$horaInicial:00');

        final DateTime endTime = DateTime.parse(
            '${dia.split('/')[2]}-${dia.split('/')[1]}-${dia.split('/')[0]}T$horaFinal:00');

        _calendarAppointments.add(Appointment(
          startTime: startTime,
          endTime: endTime,
          subject: serviceInfo['nombreServicio'] ?? 'Sin título',
          notes: '${appointment['precio']} CLP',
          color: Colors.blue,
        ));
      }

      setState(() {
        _appointmentsList = enrichedAppointments;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener citas: $e')),
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
      final List<Appointment> holidayAppointments = holidays.map((holiday) {
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
                              Container(height: 40),
                              _buildUserInfo(user),
                              const SizedBox(height: 16),
                              const Text(
                                'Mis Citas',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildAppointmentsRow(),
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
                              Padding(
                                padding: const EdgeInsets.only(bottom: 100), 
                                child: _buildCalendar()
                              ),
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
              child: const NavBarWidget(),
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
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 20,
            ),
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

  Widget _buildAppointmentsRow() {
    return _appointmentsList.isEmpty
        ? const Center(
            child: Text(
              'No hay citas aún, ¡Agenda una cita!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        : SizedBox(
            height: 230,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _appointmentsList.length,
              itemBuilder: (context, index) {
                final appointment = _appointmentsList[index];
                return AppointmentCard(
                  nombreServicio: appointment['titulo'] ?? 'Sin título',
                  fecha: appointment['fecha'] ?? 'No especificada',
                  horarioInicio: appointment['hora'] ?? 'No especificada',
                  duracion: appointment['duracion']?.toInt() ?? 0,
                  precio: appointment['precio']?.toInt() ?? 0,
                  profesional: appointment['profesional'] ?? 'Desconocido',
                  correoProfesional: appointment['correo'] ?? 'N/A',
                );
              },
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
        appointmentBuilder: (BuildContext context, CalendarAppointmentDetails details) {
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
      ),
    );
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
