import 'package:http/http.dart' as http;
import 'dart:convert';

class CalendarService {
  final String _url = 'https://apis.digital.gob.cl/fl/feriados'; 

  Future<List<Map<String, dynamic>>> fetchHolidays() async {
    try {
      final response = await http.get(Uri.parse(_url)); 
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Error al obtener los feriados: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error al conectar con la API de feriados: $e');
    }
  }
}
