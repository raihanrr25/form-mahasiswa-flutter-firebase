import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'form1_crud.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Wajib untuk koneksi Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Data Mahasiswa',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Form1Crud(),
    );
  }
}
