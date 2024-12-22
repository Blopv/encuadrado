import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/firebase_services.dart';

class DaySelectorFormField extends StatefulWidget {
  final List<String> diasPermitidos;
  final List<DateTime> feriados;
  final ValueChanged<Map<String, String>> onSelectionCompleted;
  final int duracionMin;
  final String horarioInicio;
  final String horarioFin;
  final String professionalId;
  final String serviceId;

  const DaySelectorFormField({
    Key? key,
    required this.diasPermitidos,
    required this.feriados,
    required this.onSelectionCompleted,
    required this.duracionMin,
    required this.horarioInicio,
    required this.horarioFin,
    required this.professionalId,
    required this.serviceId,
  }) : super(key: key);

  @override
  _DaySelectorFormFieldState createState() => _DaySelectorFormFieldState();
}

class _DaySelectorFormFieldState extends State<DaySelectorFormField> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTime;
  List<String> _availableTimes = [];
  List<Map<String, String>> _reservedAppointments = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openCalendarDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDay != null && _selectedTime != null
                  ? "${_getDayName(_selectedDay!)} ${_selectedDay!.day}-${_selectedDay!.month}-${_selectedDay!.year} $_selectedTime"
                  : "Día y hora",
              style: TextStyle(
                fontSize: 16,
                color: (_selectedDay != null && _selectedTime != null)
                    ? Colors.black
                    : Colors.grey.shade600,
              ),
            ),
            const Icon(
              Icons.calendar_today,
              color: Color(0xFF5433FF),
            ),
          ],
        ),
      ),
    );
  }

  void _openCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TableCalendar(
                      locale: 'es_ES',
                      focusedDay: _focusedDay,
                      firstDay: DateTime.utc(2000, 1, 1),
                      lastDay: DateTime.utc(2100, 12, 31),
                      calendarFormat: CalendarFormat.week,
                      availableGestures: AvailableGestures.none,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      selectedDayPredicate: (day) => _selectedDay == day,
                      onDaySelected: (selectedDay, focusedDay) async {
                        if (_isDayAllowed(selectedDay)) {
                          try {
                            await _fetchReservedAppointments(
                              professionalId: widget.professionalId,
                              serviceId: widget.serviceId,
                            );

                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                              _selectedTime = null; 
                              _generateAvailableTimes();
                            });

                            setDialogState(() {}); 
                          } catch (e) {
                            print("Error al seleccionar el día: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Error al cargar horarios disponibles")),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Día no permitido")),
                          );
                        }
                      },
                      calendarStyle: CalendarStyle(
                        defaultTextStyle: const TextStyle(color: Color(0xFF5433FF)),
                        disabledTextStyle: const TextStyle(color: Colors.grey),
                        outsideTextStyle: const TextStyle(color: Color(0xFF5433FF)),
                        selectedDecoration: const BoxDecoration(
                          color: Color(0xFF5433FF),
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                      ),
                      enabledDayPredicate: (day) => _isDayAllowed(day),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(color: Colors.black),
                        weekendStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _selectedDay != null
                        ? Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _availableTimes.map((time) {
                              final isSelected = _selectedTime == time;
                              return ChoiceChip(
                                label: Text(
                                  time,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (isSelected) {
                                  setState(() {
                                    _selectedTime = isSelected ? time : null;
                                    if (_selectedDay != null && _selectedTime != null) {
                                      final horaFinal = _calculateHoraFinal(_selectedTime!);
                                      final selectedJson = {
                                        "dia":
                                            "${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}",
                                        "horaInicial": _selectedTime!,
                                        "horaFinal": horaFinal,
                                      };
                                      widget.onSelectionCompleted(selectedJson);
                                    }
                                  });
                                  setDialogState(() {});
                                },
                                backgroundColor: isSelected
                                    ? const Color(0x4C4B39EF)
                                    : const Color(0xFFF1F4F8),
                                selectedColor: const Color(0x4C4B39EF),
                                side: BorderSide(
                                  color: isSelected ? const Color(0xFF5433FF) : Colors.grey,
                                  width: 2,
                                ),
                              );
                            }).toList(),
                          )
                        : const Text("Seleccione un día para ver horarios disponibles"),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

Future<void> _fetchReservedAppointments({
  required String professionalId,
  required String serviceId,
}) async {
  if (professionalId.isEmpty || serviceId.isEmpty) {
    print("Error: professionalId o serviceId están vacíos.");
    return;
  }

  try {
    final reservedAppointments = await FirebaseService()
        .getAppointmentsForProfessionalAndService(professionalId, serviceId);

    setState(() {
      _reservedAppointments = reservedAppointments
          .map<Map<String, String>>((appointment) => {
                'dia': appointment['dia'],
                'horaInicial': appointment['horaInicial'],
                'horaFinal': appointment['horaFinal'],
              })
          .toList();
    });
  } catch (e) {
    print("Error al obtener citas reservadas: $e");
  }
}

  String _calculateHoraFinal(String horaInicial) {
    final parts = horaInicial.split(':');
    final startHour = int.parse(parts[0]);
    final startMinute = int.parse(parts[1]);

    final endTime = Duration(hours: startHour, minutes: startMinute) +
        Duration(minutes: widget.duracionMin);

    final endHour = endTime.inHours;
    final endMinute = endTime.inMinutes % 60;

    return "${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}";
  }

  void _generateAvailableTimes() {
    final startHour = int.parse(widget.horarioInicio.split(":")[0]);
    final startMinute = int.parse(widget.horarioInicio.split(":")[1]);
    final endHour = int.parse(widget.horarioFin.split(":")[0]);
    final endMinute = int.parse(widget.horarioFin.split(":")[1]);

    final startTime = Duration(hours: startHour, minutes: startMinute);
    final endTime = Duration(hours: endHour, minutes: endMinute);

    List<String> times = [];
    Duration currentTime = startTime;

    while (currentTime + Duration(minutes: widget.duracionMin) <= endTime) {
      final hours = currentTime.inHours;
      final minutes = currentTime.inMinutes % 60;
      final formattedTime = "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";

      if (_isTimeSlotAvailable(formattedTime, widget.duracionMin)) {
        times.add(formattedTime);
      }

      currentTime += Duration(minutes: widget.duracionMin);
    }

    setState(() {
      _availableTimes = times;
    });
  }

  bool _isTimeSlotAvailable(String horaInicial, int duracionMin) {
    final selectedDate = _selectedDay;
    if (selectedDate == null) return false;

    final slotStart = _convertToDuration(horaInicial);
    final slotEnd = slotStart + Duration(minutes: duracionMin);

    for (var appointment in _reservedAppointments) {
      if (appointment['dia'] == _formatDate(selectedDate)) {
        final reservedStart = _convertToDuration(appointment['horaInicial']!);
        final reservedEnd = _convertToDuration(appointment['horaFinal']!);

        if (!(slotEnd <= reservedStart || slotStart >= reservedEnd)) {
          return false;
        }
      }
    }
    return true;
  }

  Duration _convertToDuration(String hora) {
    final parts = hora.split(':');
    return Duration(hours: int.parse(parts[0]), minutes: int.parse(parts[1]));
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }


  bool _isDayAllowed(DateTime day) {
    final dayName = _getDayName(day);
    return widget.diasPermitidos.contains(dayName) &&
        !widget.feriados.contains(DateTime(day.year, day.month, day.day));
  }

  String _getDayName(DateTime date) {
    const days = ['DOM', 'LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB'];
    return days[date.weekday % 7];
  }
}
