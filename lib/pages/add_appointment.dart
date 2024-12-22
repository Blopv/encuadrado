import 'package:flutter/material.dart';
import 'package:encuadrado/services/firebase_services.dart';
import 'package:encuadrado/services/calendar_service.dart';
import '../components/navbar.dart';
import '../components/service_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/user_calendar.dart';
import '../pages/user.dart';

class AddAppointmentPage extends StatefulWidget {
  const AddAppointmentPage({Key? key}) : super(key: key);

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<AddAppointmentPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();
  final CalendarService _calendarService = CalendarService();
  List<Map<String, dynamic>> _services = [];
  List<DateTime> _feriados = [];
  String _userName = 'Usuario';
  int? _selectedServiceIndex;
  Map<String, String>? _selectedDateTime;
  int _selectedDuration = 0;

  final Color enabledButtonColor = const Color(0xFF5433FF);
  final Color disabledButtonColor = Colors.grey.shade400;

  @override
  void initState() {
    super.initState();
    _fetchServices();
    _fetchUserName();
    _fetchHolidays();
  }

  Future<void> _fetchServices() async {
    try {
      final services = await _firebaseService.getAllServices();
      for (var service in services) {
        final String professionalUid = service['userId'];
        final professionalInfo = await _firebaseService.getProfessionalInfo(professionalUid);
        service['nombreProfesional'] = professionalInfo['name'] ?? 'N/A';
        service['correoProfesional'] = professionalInfo['email'] ?? 'N/A';
      }
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
      setState(() {
        _feriados = holidays.map((holiday) => DateTime.parse(holiday['fecha'])).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener los feriados: $e')),
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
                                'Selecciona un servicio',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _services.isEmpty ? _buildNoServices() : _buildServiceCards(),
                              const SizedBox(height: 16),
                              const Text(
                                'Selecciona la duración',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildDurationSelector(),
                              const SizedBox(height: 16),
                              const Text(
                                'Selecciona día y hora',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildDaySelector(),
                              const SizedBox(height: 16),
                              _buildPriceInfo(),
                              const SizedBox(height: 16),
                              Padding(padding: const EdgeInsets.only(bottom: 100),  child: _buildScheduleButton()),
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
            backgroundColor: enabledButtonColor,
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
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoServices() {
    return const Center(
      child: Text(
        'No hay servicios para mostrar',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildServiceCards() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _services.asMap().entries.map((entry) {
          final index = entry.key;
          final service = entry.value;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedServiceIndex = index;
                _selectedDuration = service['duracionMin'] ?? 0;
                _selectedDateTime = null; // Resetea la selección del día y hora
              });
            },
            child: ServiceCard(
              nombreServicio: service['nombreServicio'] ?? 'N/A',
              dias: List<String>.from(service['dias'] ?? []),
              horarioInicio: service['horario']['inicio'].toString(),
              horarioFin: service['horario']['fin'].toString(),
              duracionMin: (service['duracionMin'] as num?)?.toInt() ?? 0,
              duracionMax: (service['duracionMax'] as num?)?.toInt() ?? 0,
              precio: (service['precio'] as num?)?.toInt() ?? 0,
              profesional: service['nombreProfesional'] ?? 'N/A',
              correoProfesional: service['correoProfesional'] ?? 'N/A',
              isUser: true,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDurationSelector() {
    final isServiceSelected = _selectedServiceIndex != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E3E7), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.remove,
              color: isServiceSelected && _selectedDuration > (_services[_selectedServiceIndex!]['duracionMin'] ?? 0)
                  ? enabledButtonColor
                  : disabledButtonColor,
            ),
            onPressed: isServiceSelected && _selectedDuration > (_services[_selectedServiceIndex!]['duracionMin'] ?? 0)
                ? () {
                    setState(() {
                      _selectedDuration -= 15;
                    });
                  }
                : null,
          ),
          Expanded(
            child: Center(
              child: Text(
                isServiceSelected ? '$_selectedDuration min' : '0 minutos',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.add,
              color: isServiceSelected && _selectedDuration < (_services[_selectedServiceIndex!]['duracionMax'] ?? 0)
                  ? enabledButtonColor
                  : disabledButtonColor,
            ),
            onPressed: isServiceSelected && _selectedDuration < (_services[_selectedServiceIndex!]['duracionMax'] ?? 0)
                ? () {
                    setState(() {
                      _selectedDuration += 15;
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfo() {
    if (_services.isEmpty || _selectedServiceIndex == null || _selectedDuration == 0) {
      return const SizedBox(); 
    }

    final selectedService = _services[_selectedServiceIndex!];
    final pricePerHour = (selectedService['precio'] as num).toInt();
    final totalPrice = (_selectedDuration / 60) * pricePerHour;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        'Precio: \$${totalPrice.round()}', 
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    final bool isServiceSelected = _selectedServiceIndex != null;

    return GestureDetector(
      onTap: isServiceSelected
          ? null
          : () => _showSnackBar('Debes seleccionar un servicio antes de elegir un día y hora'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE0E3E7), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DaySelectorFormField(
          diasPermitidos: isServiceSelected
              ? List<String>.from(_services[_selectedServiceIndex!]['dias'] ?? [])
              : [],
          feriados: _feriados,
          duracionMin: isServiceSelected ? _selectedDuration : 0,
          horarioInicio: isServiceSelected
              ? _services[_selectedServiceIndex!]['horario']['inicio'].toString()
              : "00:00",
          horarioFin: isServiceSelected
              ? _services[_selectedServiceIndex!]['horario']['fin'].toString()
              : "00:00",
          professionalId: isServiceSelected ? _services[_selectedServiceIndex!]['userId'].toString() : "",
          serviceId: isServiceSelected ? _services[_selectedServiceIndex!]['id'].toString() : "",
          onSelectionCompleted: isServiceSelected
              ? (Map<String, String> selectedJson) {
                  setState(() {
                    _selectedDateTime = selectedJson.map((key, value) => MapEntry(key, value.toString()));
                  });
                  print("Selección completada: ${_selectedDateTime!['dia']} ${_selectedDateTime!['horaInicial']} - ${_selectedDateTime!['horaFinal']}");
                }
              : (_) => {},
        ),
      ),
    );
  }

  Widget _buildScheduleButton() {
    if (_services.isEmpty || _selectedServiceIndex == null) {
      return ElevatedButton(
        onPressed: () => _showSnackBar('Debes seleccionar un servicio antes de agendar'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: disabledButtonColor,
        ),
        child: const Text(
          'Agendar',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    final selectedService = _services[_selectedServiceIndex!];
    final professionalUid = selectedService['userId'];
    final pricePerHour = (selectedService['precio'] as num).toDouble();
    final totalPrice = (_selectedDuration / 60) * pricePerHour;
    final userId = _auth.currentUser!.uid;

    return ElevatedButton(
      onPressed: () async {
        if (_selectedDateTime != null) {
          final appointment = {
            'serviceId': selectedService['id'],
            'userId': userId,
            'duracion': _selectedDuration,
            'dia': _selectedDateTime!['dia']!,
            'horaInicial': _selectedDateTime!['horaInicial']!,
            'horaFinal': _selectedDateTime!['horaFinal']!,
            'precio': totalPrice,
            'professionalId': professionalUid, 
          };

          try {
            await _firebaseService.createAppointment(userId, professionalUid, appointment);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserHomePage(),
              ),
            );
            _showSnackBar('Cita agendada con éxito');
          } catch (e) {
            _showSnackBar('Error al agendar la cita: $e');
          }
        } else {
          _showSnackBar('Selecciona un día y hora antes de agendar');
        }
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: enabledButtonColor,
      ),
      child: const Text(
        'Agendar',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
