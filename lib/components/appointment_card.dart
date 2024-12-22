import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  final String nombreServicio;
  final String fecha;
  final String horarioInicio;
  final int duracion;
  final int precio;
  final String profesional;
  final String correoProfesional;

  const AppointmentCard({
    Key? key,
    required this.nombreServicio,
    required this.fecha,
    required this.horarioInicio,
    required this.duracion,
    required this.precio,
    required this.profesional,
    required this.correoProfesional,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedPrice = NumberFormat("#,##0", "es_CL").format(precio);

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFF5433FF), 
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, 
            children: [
              Text(
                nombreServicio.isNotEmpty ? nombreServicio : 'Sin título',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5433FF),
                      fontSize: 16,
                    ),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profesional: ${profesional.isNotEmpty ? profesional : 'Desconocido'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Correo: ${correoProfesional.isNotEmpty ? correoProfesional : 'N/A'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fecha: ${fecha.isNotEmpty ? fecha : 'No especificada'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hora: ${horarioInicio.isNotEmpty ? horarioInicio : 'No especificada'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Duración: ${duracion > 0 ? '$duracion minutos' : 'Sin definir'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '\$$formattedPrice',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
