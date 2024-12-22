import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firebase_services_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addService(ServiceModel service) async {
    await _firestore.collection('Servicios').add({
      'nombreServicio': service.nombreServicio,
      'dias': service.dias,
      'horario': {
        'inicio': service.horarioInicio,
        'fin': service.horarioFin,
      },
      'duracionMin': service.duracionMin,
      'duracionMax': service.duracionMax,
      'precio': service.precio,
      'userId': service.userId,
    });
  }

  Future<List<Map<String, dynamic>>> getServices() async {
    final snapshot = await _firestore
        .collection('Servicios')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<String> getUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return 'Usuario';
    }

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists && userDoc.data()?['name'] != null) {
      return userDoc.data()?['name'] as String;
    }
    return 'Usuario';
  }

  Future<List<Map<String, dynamic>>> getAllServices() async {
    final snapshot = await _firestore.collection('Servicios').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<Map<String, dynamic>> getProfessionalInfo(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>;
    } else {
      throw Exception('No se encontró información para el UID: $uid');
    }
  }

  Future<void> createAppointment(String userId, String professionalUid, Map<String, dynamic> appointment) async {
    final firestore = FirebaseFirestore.instance;

    await firestore
        .collection('users')
        .doc(userId) 
        .collection('appointments') 
        .add(appointment);

    await firestore
        .collection('users') 
        .doc(professionalUid) 
        .collection('appointments') 
        .add(appointment);
  }

  Future<List<Map<String, dynamic>>> getUserAppointments(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users') 
          .doc(userId) 
          .collection('appointments') 
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; 
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener las citas del usuario: $e');
    }
  }

  Future<Map<String, dynamic>> getServiceById(String serviceId) async {
    try {
      final serviceDoc = await _firestore.collection('Servicios').doc(serviceId).get();
      if (serviceDoc.exists) {
        return serviceDoc.data() as Map<String, dynamic>;
      } else {
        throw Exception('No se encontró el servicio con ID: $serviceId');
      }
    } catch (e) {
      throw Exception('Error al obtener el servicio: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAppointmentsForProfessionalAndService(
    String professionalId, String serviceId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(professionalId)
          .collection('appointments') 
          .where('professionalId', isEqualTo: professionalId)
          .where('serviceId', isEqualTo: serviceId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; 
        return data;
      }).toList();
    } catch (e) {
      throw Exception("Error al obtener appointments: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getAppointmentsForProfessional(
    String professionalId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(professionalId)
          .collection('appointments') 
          .where('professionalId', isEqualTo: professionalId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; 
        return data;
      }).toList();
    } catch (e) {
      throw Exception("Error al obtener appointments: $e");
    }
  }
}
