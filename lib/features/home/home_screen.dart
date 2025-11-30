import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Tracker"),
        centerTitle: true,
        automaticallyImplyLeading: false, // Hilangkan tombol back jika ada
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt_rounded,
              size: 100,
              color: Colors.blueAccent.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            const Text(
              "Selamat Datang di Task Tracker",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Kelola tugas kuliahmu dengan mudah",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}