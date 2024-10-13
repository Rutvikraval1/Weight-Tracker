
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "weight_tracker.db";
  static const _databaseVersion = 1;

  static const tableUser = 'user';
  static const columnName = 'name';
  static const columnNotificationTime = 'notificationTime';

  static const tableWeight = 'weight';
  static const columnDate = 'date';
  static const columnWeight = 'weight';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableUser (
        $columnName TEXT NOT NULL,
        $columnNotificationTime TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableWeight (
        $columnDate TEXT PRIMARY KEY,
        $columnWeight REAL
      )
    ''');
  }

  Future<void> insertUser(String name, String notificationTime) async {
    Database db = await instance.database;
    await db.insert(tableUser, {
      columnName: name,
      columnNotificationTime: notificationTime,
    });
  }

  Future<Map?> getUser() async {
    Database db = await instance.database;
    List<Map> users = await db.query(tableUser);
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  Future<void> insertWeight(String date, double weight) async {
    Database db = await instance.database;
    await db.insert(tableWeight, {
      columnDate: date,
      columnWeight: weight,
    });
  }

  Future<List<Map<String, dynamic>>> getAllWeights() async {
    Database db = await instance.database;
    return await db.query(tableWeight);
  }
}
