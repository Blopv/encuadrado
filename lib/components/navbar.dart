import 'package:encuadrado/pages/login.dart';
import 'package:flutter/material.dart';
import 'add_service_bottom_sheet.dart';
import '../pages/admin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/user.dart';
import '../pages/add_appointment.dart';

class NavBarWidget extends StatelessWidget {
  final VoidCallback? onServiceAdded; 

  const NavBarWidget({Key? key, this.onServiceAdded}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Material(
                color: Colors.transparent,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 10,
                        color: Color(0x1A57636C),
                        offset: Offset(0, -10),
                        spreadRadius: 0.1,
                      )
                    ],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.home_rounded,
                  color: Color(0xFF9299A1),
                  size: 30,
                ),
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .get();

                    if (userDoc.exists && userDoc.data()?['role'] == 'Admin') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminHomePage(),
                        ),
                      );
                    } else if (userDoc.exists && userDoc.data()?['role'] == 'User') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UserHomePage(),
                        ),
                      );
                    }
                  }
                },
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5433FF),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () async {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            final userDoc = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .get();

                            if (userDoc.exists && userDoc.data()?['role'] == 'Admin') {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) => AddServiceBottomSheet(
                                  onServiceAdded: onServiceAdded ?? () {},
                                ),
                              );
                            } else if (userDoc.exists && userDoc.data()?['role'] == 'User') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddAppointmentPage(),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.logout,
                  color: Color(0xFF9299A1),
                  size: 30,
                ),
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sesión cerrada exitosamente')),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginWidget(),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al cerrar sesión: $e')),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
