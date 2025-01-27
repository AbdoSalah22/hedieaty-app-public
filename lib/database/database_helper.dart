import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('hedieaty.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 3, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user(
        id TEXT PRIMARY KEY,
        username TEXT,
        profilePictureURL TEXT,
        isSynced INTEGER
      )
    ''');

    await db.execute('''
          CREATE TABLE IF NOT EXISTS events (
            id TEXT PRIMARY KEY,
            name TEXT,
            description TEXT,
            location TEXT,
            date TEXT,
            status TEXT,
            isSynced INTEGER,
            userId TEXT,
            FOREIGN KEY (userId) REFERENCES user(id)
          )
        ''');
  }

  Future<int> insertOrUpdateUser(Map<String, dynamic> user) async {
    final db = await instance.database;

    return await db.insert(
      'user',
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertOrUpdateEvent(Map<String, dynamic> event) async {
    final db = await instance.database;

    return await db.insert(
      'events',
      event,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getLocalUser(String id) async {
    final db = await instance.database;

    final result =
    await db.query('user', where: 'id = ?', whereArgs: [id], limit: 1);

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getLocalEvent(String id) async {
    final db = await instance.database;

    final result =
    await db.query('events', where: 'id = ?', whereArgs: [id], limit: 1);

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getUnsyncedUsers() async {
    final db = await instance.database;

    return await db.query('user', where: 'isSynced = 0');
  }


  Future<List<Map<String, dynamic>>> getUnsyncedEvents() async {
    final db = await instance.database;

    return await db.query('events', where: 'isSynced = 0');
  }

  Future<int> markUserAsSynced(String id) async {
    final db = await instance.database;

    return await db.update(
      'user',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> markEventAsSynced(String id) async {
    final db = await instance.database;

    return await db.update(
      'events',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> dropAllTables() async {
    // final db = await instance.database;
    //
    // await db.execute('DROP TABLE IF EXISTS events');
    // await db.execute('DROP TABLE IF EXISTS user');
  }
}
