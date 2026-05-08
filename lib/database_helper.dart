import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  // ─── Getter database (buat jika belum ada) ───────────────────────────────

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'agenda_nusantara.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabel tasks
    await db.execute('''
      CREATE TABLE tasks (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        title       TEXT    NOT NULL,
        description TEXT    NOT NULL,
        due_date    TEXT    NOT NULL,
        category    TEXT    NOT NULL,
        is_done     INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Tabel user
    await db.execute('''
      CREATE TABLE user (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT    NOT NULL UNIQUE,
        password TEXT    NOT NULL
      )
    ''');

    // Insert user default
    await db.insert('user', {
      'username': 'user',
      'password': 'user',
    });
  }

  // ─── TASK: Insert ─────────────────────────────────────────────────────────

  Future<int> insertTask(TaskModel task) async {
    final db = await database;
    return await db.insert(
      'tasks',
      task.toMap()..remove('id'), // biarkan AUTOINCREMENT yang isi id
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ─── TASK: Get All ────────────────────────────────────────────────────────

  /// Ambil semua tugas. Opsional filter berdasarkan category ('important' / 'regular').
  Future<List<TaskModel>> getAllTasks({String? category}) async {
    final db = await database;

    List<Map<String, dynamic>> result;

    if (category != null) {
      result = await db.query(
        'tasks',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'id DESC',
      );
    } else {
      result = await db.query('tasks', orderBy: 'id DESC');
    }

    return result.map((row) => TaskModel.fromMap(row)).toList();
  }

  // ─── TASK: Update Status (selesai / belum) ────────────────────────────────

  Future<int> updateTaskStatus(int id, int isDone) async {
    final db = await database;
    return await db.update(
      'tasks',
      {'is_done': isDone},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── TASK: Delete ─────────────────────────────────────────────────────────

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── TASK: Count Done ─────────────────────────────────────────────────────

  Future<int> countDoneTasks() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE is_done = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ─── TASK: Count Undone ───────────────────────────────────────────────────

  Future<int> countUndoneTasks() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE is_done = 0',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ─── USER: Check Login ────────────────────────────────────────────────────

  /// Return true jika username + password cocok di database.
  Future<bool> checkLogin(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'user',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }

  // ─── USER: Change Password ────────────────────────────────────────────────

  /// Return true jika berhasil update. Cek dulu password lama sebelum ganti.
  Future<bool> changePassword(
      String username, String oldPassword, String newPassword) async {
    final db = await database;

    // Verifikasi password lama dulu
    final check = await db.query(
      'user',
      where: 'username = ? AND password = ?',
      whereArgs: [username, oldPassword],
    );

    if (check.isEmpty) return false; // password lama salah

    final count = await db.update(
      'user',
      {'password': newPassword},
      where: 'username = ?',
      whereArgs: [username],
    );

    return count > 0;
  }
}