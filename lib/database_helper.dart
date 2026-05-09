import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  // ── Getter database ────────────────────────────────────────────────────────

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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ── onCreate ───────────────────────────────────────────────────────────────

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        title          TEXT    NOT NULL,
        description    TEXT    NOT NULL,
        due_date       TEXT    NOT NULL,
        category       TEXT    NOT NULL,
        is_done        INTEGER NOT NULL DEFAULT 0,
        completed_date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE user (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.insert('user', {'username': 'aziz', 'password': '12345'});
  }

  // ── onUpgrade ──────────────────────────────────────────────────────────────

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final columns = await db.rawQuery('PRAGMA table_info(tasks)');
      final exists = columns.any((c) => c['name'] == 'completed_date');
      if (!exists) {
        await db.execute('ALTER TABLE tasks ADD COLUMN completed_date TEXT');
      }
    }
  }

  // ── INSERT ─────────────────────────────────────────────────────────────────

  Future<int> insertTask(TaskModel task) async {
    final db = await database;
    return await db.insert(
      'tasks',
      task.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ── GET ALL — filter opsional: category dan/atau isDone ───────────────────

  Future<List<TaskModel>> getAllTasks({
    String? category,
    int? isDone,
  }) async {
    final db = await database;

    final conditions = <String>[];
    final args = <dynamic>[];

    if (category != null) {
      conditions.add('category = ?');
      args.add(category);
    }
    if (isDone != null) {
      conditions.add('is_done = ?');
      args.add(isDone);
    }

    final where = conditions.isNotEmpty ? conditions.join(' AND ') : null;

    final result = await db.query(
      'tasks',
      where: where,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'id DESC',
    );

    return result.map((r) => TaskModel.fromMap(r)).toList();
  }

  // ── UPDATE STATUS + COMPLETED DATE ────────────────────────────────────────

  Future<int> updateTaskStatus(int id, int isDone) async {
    final db = await database;
    return await db.update(
      'tasks',
      {
        'is_done': isDone,
        'completed_date': isDone == 1 ? _todayString() : null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // ── COUNT DONE ─────────────────────────────────────────────────────────────

  Future<int> countDoneTasks() async {
    final db = await database;
    final r =
        await db.rawQuery('SELECT COUNT(*) as c FROM tasks WHERE is_done = 1');
    return Sqflite.firstIntValue(r) ?? 0;
  }

  // ── COUNT UNDONE ───────────────────────────────────────────────────────────

  Future<int> countUndoneTasks() async {
    final db = await database;
    final r =
        await db.rawQuery('SELECT COUNT(*) as c FROM tasks WHERE is_done = 0');
    return Sqflite.firstIntValue(r) ?? 0;
  }

  // ── GRAFIK: 7 hari terakhir selalu 7 titik, count = 0 jika tidak ada ──────

  Future<List<Map<String, dynamic>>> getCompletedTasksPerDay() async {
    final db = await database;

    // Ambil semua data grouped by completed_date
    final rows = await db.rawQuery('''
      SELECT completed_date as date, COUNT(*) as count
      FROM tasks
      WHERE is_done = 1
        AND completed_date IS NOT NULL
      GROUP BY completed_date
    ''');

    // Jadikan map { 'dd/MM/yyyy': count }
    final Map<String, int> countMap = {
      for (final r in rows) r['date'] as String: r['count'] as int,
    };

    // Bangun 7 hari terakhir (hari ini = index 6)
    final List<Map<String, dynamic>> result = [];
    final today = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final label = _formatDate(date);
      result.add({
        'date': label,
        'count': countMap[label] ?? 0,
      });
    }

    return result; // selalu 7 elemen, urut dari terlama → hari ini
  }

  // ── CHECK LOGIN ────────────────────────────────────────────────────────────

  Future<bool> checkLogin(String username, String password) async {
    final db = await database;
    final r = await db.query(
      'user',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return r.isNotEmpty;
  }

  // ── CHANGE PASSWORD ────────────────────────────────────────────────────────

  Future<bool> changePassword(
      String username, String oldPassword, String newPassword) async {
    final db = await database;
    final check = await db.query(
      'user',
      where: 'username = ? AND password = ?',
      whereArgs: [username, oldPassword],
    );
    if (check.isEmpty) return false;

    final count = await db.update(
      'user',
      {'password': newPassword},
      where: 'username = ?',
      whereArgs: [username],
    );
    return count > 0;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _todayString() => _formatDate(DateTime.now());

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';
}
