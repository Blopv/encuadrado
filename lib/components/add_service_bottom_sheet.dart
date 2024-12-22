import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddServiceBottomSheet extends StatefulWidget {
  final VoidCallback onServiceAdded;
  const AddServiceBottomSheet({Key? key, required this.onServiceAdded}) : super(key: key);

  @override
  _AddServiceBottomSheetState createState() => _AddServiceBottomSheetState();
}

class _AddServiceBottomSheetState extends State<AddServiceBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _minDurationController = TextEditingController();
  final TextEditingController _maxDurationController = TextEditingController();

  List<String> _selectedDays = [];
  final List<String> _dayOptions = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
  bool _hasTimeError = false;

  @override
  void initState() {
    super.initState();
    _minDurationController.text = '30'; 
    _maxDurationController.text = '90'; 
  }

  Future<void> _addService() async {
    _validateTime(); 
    if (_hasTimeError || _selectedDays.isEmpty) {
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      try {
        final documentId = FirebaseFirestore.instance.collection('Servicios').doc().id;

        await FirebaseFirestore.instance.collection('Servicios').doc(documentId).set({
          'nombreServicio': _serviceNameController.text,
          'dias': _selectedDays,
          'horario': {
            'inicio': _startTimeController.text,
            'fin': _endTimeController.text,
          },
          'duracionMin': int.parse(_minDurationController.text),
          'duracionMax': int.parse(_maxDurationController.text),
          'precio': int.parse(_priceController.text),
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Servicio agregado correctamente.')),
        );

        Navigator.pop(context);
        widget.onServiceAdded(); 
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar servicio: $e')),
        );
      }
    }
  }

  void _validateTime() {
    if (_startTimeController.text.isNotEmpty && _endTimeController.text.isNotEmpty) {
      final startTime = TimeOfDay(
        hour: int.parse(_startTimeController.text.split(':')[0]),
        minute: int.parse(_startTimeController.text.split(':')[1]),
      );
      final endTime = TimeOfDay(
        hour: int.parse(_endTimeController.text.split(':')[0]),
        minute: int.parse(_endTimeController.text.split(':')[1]),
      );

      setState(() {
        _hasTimeError = endTime.hour < startTime.hour ||
            (endTime.hour == startTime.hour && endTime.minute < startTime.minute);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agregar Servicio',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _serviceNameController,
                  style: const TextStyle(fontSize: 16), 
                  decoration: InputDecoration(
                    labelText: 'Nombre del Servicio',
                    labelStyle: const TextStyle(fontSize: 14), 
                    filled: true,
                    fillColor: const Color(0xFFF1F4F8), 
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E3E7), width: 2), 
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E3E7), width: 2), 
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF5433FF), width: 2), 
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 2), 
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.redAccent, width: 2), 
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obligatorio.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),
                const Text(
                  'Indica tu horario de atención.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startTimeController,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Hora Inicial',
                          labelStyle: const TextStyle(fontSize: 14),
                          filled: true,
                          fillColor: const Color(0xFFF1F4F8),
                          suffixIcon: const Icon(Icons.access_time, color: Color(0xFF5433FF)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _hasTimeError ? Colors.redAccent : const Color(0xFFE0E3E7),
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _hasTimeError ? Colors.redAccent : const Color(0xFFE0E3E7),
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _hasTimeError ? Colors.redAccent : const Color(0xFF5433FF),
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                          ),
                        ),
                        onTap: () async {
                          TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  primaryColor: const Color(0xFF5433FF),
                                  colorScheme: const ColorScheme.light(primary: Color(0xFF5433FF)),
                                  buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (time != null) {
                            _startTimeController.text = time.format(context);
                            setState(() {
                              _validateTime(); 
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obligatorio.';
                          }
                          return null;
                        },
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _endTimeController,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Hora Final',
                          labelStyle: const TextStyle(fontSize: 14),
                          filled: true,
                          fillColor: const Color(0xFFF1F4F8),
                          suffixIcon: const Icon(Icons.access_time, color: Color(0xFF5433FF)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _hasTimeError ? Colors.redAccent : const Color(0xFFE0E3E7),
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _hasTimeError ? Colors.redAccent : const Color(0xFFE0E3E7),
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _hasTimeError ? Colors.redAccent : const Color(0xFF5433FF),
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                          ),
                        ),
                        onTap: () async {
                          TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  primaryColor: const Color(0xFF5433FF),
                                  colorScheme: const ColorScheme.light(primary: Color(0xFF5433FF)),
                                  buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (time != null) {
                            _endTimeController.text = time.format(context);
                            setState(() {
                              _validateTime(); 
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obligatorio.';
                          }
                          return null;
                        },
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
                    if (_hasTimeError)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Hora Final no puede ser menor que la Inicial.',
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Duración Mín (minutos)',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F4F8),
                              border: Border.all(color: const Color(0xFFE0E3E7), width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.remove,
                                    color: int.parse(_minDurationController.text) > 30
                                        ? const Color(0xFF5433FF)
                                        : const Color(0xFFE0E3E7),
                                  ),
                                  onPressed: int.parse(_minDurationController.text) > 30
                                      ? () {
                                          setState(() {
                                            int currentValue = int.tryParse(_minDurationController.text) ?? 30;
                                            _minDurationController.text = (currentValue - 15).toString();
                                          });
                                        }
                                      : null, 
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      _minDurationController.text.isEmpty
                                          ? '30'
                                          : _minDurationController.text,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.add,
                                    color: int.parse(_minDurationController.text) < int.parse(_maxDurationController.text)
                                        ? const Color(0xFF5433FF)
                                        : const Color(0xFFE0E3E7),
                                  ),
                                  onPressed: int.parse(_minDurationController.text) < int.parse(_maxDurationController.text)
                                      ? () {
                                          setState(() {
                                            int currentValue = int.tryParse(_minDurationController.text) ?? 30;
                                            _minDurationController.text = (currentValue + 15).toString();
                                          });
                                        }
                                      : null, 
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Duración Máx (minutos)',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F4F8),
                              border: Border.all(color: const Color(0xFFE0E3E7), width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.remove,
                                    color: int.parse(_maxDurationController.text) > int.parse(_minDurationController.text)
                                        ? const Color(0xFF5433FF)
                                        : const Color(0xFFE0E3E7),
                                  ),
                                  onPressed: int.parse(_maxDurationController.text) > int.parse(_minDurationController.text)
                                      ? () {
                                          setState(() {
                                            int currentValue = int.tryParse(_maxDurationController.text) ?? 90;
                                            _maxDurationController.text = (currentValue - 15).toString();
                                          });
                                        }
                                      : null, 
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      _maxDurationController.text.isEmpty
                                          ? '90'
                                          : _maxDurationController.text,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.add,
                                    color: int.parse(_maxDurationController.text) < 90
                                        ? const Color(0xFF5433FF)
                                        : const Color(0xFFE0E3E7),
                                  ),
                                  onPressed: int.parse(_maxDurationController.text) < 90
                                      ? () {
                                          setState(() {
                                            int currentValue = int.tryParse(_maxDurationController.text) ?? 90;
                                            _maxDurationController.text = (currentValue + 15).toString();
                                          });
                                        }
                                      : null, 
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Indica los días de atención.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: _dayOptions.map((day) {
                    return ChoiceChip(
                      label: Text(day),
                      selected: _selectedDays.contains(day),
                      selectedColor: const Color(0x4C4B39EF),
                      backgroundColor: const Color(0xFFF1F4F8),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: _selectedDays.contains(day)
                              ? const Color(0xFF4B39EF)
                              : const Color(0xFFE0E3E7),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDays.add(day);
                          } else {
                            _selectedDays.remove(day);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                if (_selectedDays.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Debes seleccionar al menos un día.',
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'Indica el precio por hora de atención.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'Precio por Hora',
                    labelStyle: const TextStyle(fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFFF1F4F8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E3E7), width: 2), 
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E3E7), width: 2), 
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF5433FF), width: 2), 
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 2), 
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.redAccent, width: 2), 
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obligatorio.';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Ingrese un número válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _addService(),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color(0xFF5433FF),
                  ),
                  child: const Text(
                    'Agregar Servicio',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
