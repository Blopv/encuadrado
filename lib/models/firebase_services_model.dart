import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String nombreServicio;
  final List<String> dias;
  final String horarioInicio;
  final String horarioFin;
  final int duracionMin;
  final int duracionMax;
  final int precio;
  final String userId;
  final DateTime createdAt;

  ServiceModel({
    required this.id,
    required this.nombreServicio,
    required this.dias,
    required this.horarioInicio,
    required this.horarioFin,
    required this.duracionMin,
    required this.duracionMax,
    required this.precio,
    required this.userId,
    required this.createdAt,
  });

  factory ServiceModel.fromMap(String id, Map<String, dynamic> data) {
    return ServiceModel(
      id: id,
      nombreServicio: data['nombreServicio'],
      dias: List<String>.from(data['dias']),
      horarioInicio: data['horario']['inicio'],
      horarioFin: data['horario']['fin'],
      duracionMin: data['duracionMin'],
      duracionMax: data['duracionMax'],
      precio: data['precio'],
      userId: data['userId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(), 
    );
  }
}
