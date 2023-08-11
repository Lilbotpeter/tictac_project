import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


class DatabaseHelper {
  static final String moveHistory = 'move_history';
  static final String colRow = 'row';
  static final String colCol = 'col';
  static final DatabaseHelper instance = DatabaseHelper._getInstance();
  static Database? _database;

  DatabaseHelper._getInstance();

  static final String history = 'play_history';

  static final String colId = 'id';
  static final String colPlayer = 'player';
  static final String colResult = 'result';

  Future<Database> get database async {
    if (_database != null) return _database!;
    databaseFactory = databaseFactoryFfi;

    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    
    String path = join(await getDatabasesPath(), 'tic_tac_toe.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }


void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $moveHistory(
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colPlayer TEXT,
        $colRow INTEGER,
        $colCol INTEGER,
      )
    ''');
  }

  Future<int> insertMove(String player, int row, int col) async {
    final db = await database;
    Map<String, dynamic> roww = {
      colPlayer: player,
      colRow: row,
      colCol: col,
    };
    return await db.insert(moveHistory, roww);
  }


  Future<int> insertPlayHistory(String player, String result) async {
    final db = await database;
    Map<String, dynamic> row = {
      colPlayer: player,
      colResult: result,
    };
    return await db.insert(history, row);
  }


  void saveMove(String player, int row, int col) async {
  await DatabaseHelper.instance.insertMove(player, row, col);
}

  


  Future<List<Map<String, dynamic>>> queryAllPlayHistory() async {
    final db = await database;
    return await db.query(history);
  }
}
