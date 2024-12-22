import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ServiceCard extends StatelessWidget {
  final String nombreServicio;
  final List<String> dias;
  final String horarioInicio;
  final String horarioFin;
  final int duracionMin;
  final int duracionMax;
  final int precio;
  final String profesional;
  final String correoProfesional;
  final bool isUser;

  const ServiceCard({
    Key? key,
    required this.nombreServicio,
    required this.dias,
    required this.horarioInicio,
    required this.horarioFin,
    required this.duracionMin,
    required this.duracionMax,
    required this.precio,
    required this.profesional,
    required this.correoProfesional,
    required this.isUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final duration = duracionMin == duracionMax
        ? '$duracionMin minutos'
        : '$duracionMin - $duracionMax minutos';

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
                nombreServicio,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5433FF),
                      fontSize: 16,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                dias.join(', '),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isUser) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Profesional: $profesional',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Correo: $correoProfesional',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Horario: $horarioInicio - $horarioFin',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Duración: $duration',
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
