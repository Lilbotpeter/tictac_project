import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';


class DatabaseHelper {

  final String databaseName = "history.db";

  

  Future<Database> initDB() async{
    final databasePath = await getDatabasesPath();
    final path = join(databasePath,databaseName);

    return await openDatabase(
      join(path,databaseName),
      onCreate: (database,version) async{
        await database.execute(
          "CREATE TABLE History( id INTEGER PRIMARY KEY AUTOINCREMENT,winner TEXT)",
          
        );
      },
      version: 1,
    );
  }

  Future<void> insertData(String winner) async {
  final db = await initDB();
  await db.insert(
    'History',
    {'winner': winner},
  );
}






  // Future<int> insertHistory(String player,String result) async{
  //   final db = await database;
  //   Map<int, String> row = {

  //   };
  //   return await db.insert(history,row);

  // }


  
}
