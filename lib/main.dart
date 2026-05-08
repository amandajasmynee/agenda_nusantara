import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'add_task_page.dart';
import 'task_list_page.dart';
import 'settings_page.dart';
import 'database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.instance.database;

  runApp(const AgendaNusantaraApp());
}

class AgendaNusantaraApp extends StatelessWidget {
  const AgendaNusantaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda Nusantara',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFCC0000)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/add-task': (context) => const AddTaskPage(),
        '/task-list': (context) => const TaskListPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}