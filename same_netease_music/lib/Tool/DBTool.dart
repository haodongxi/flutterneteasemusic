import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';

class DBTool {
  String dbPath;
  Database database;

  Future<Database> getDBPath() async {
    var databasesPath = await getDatabasesPath();
    dbPath = join(databasesPath, 'netease.db');
    return await _createKeyValueTable();
  }

  _createKeyValueTable() async {
    // open the database
    database = await openDatabase(dbPath, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE IF NOT EXISTS KeyValue (key TEXT, value TEXT)');
    });
    return database;
  }

  addValueForKey(String key, String value) async {
    List<Map> list =
        await database.rawQuery('SELECT * FROM KeyValue WHERE key=?', [key]);
    if (list == null || list.length == 0) {
      await database.transaction((txn) async {
        await txn.rawInsert(
            'INSERT INTO KeyValue(key, value) VALUES("$key", "$value")');
      });
    } else {
      await database.rawUpdate(
          'UPDATE KeyValue SET value = ? WHERE key = ?', [value, key]);
    }
  }

  Future<List> getValueWithKey(String key) async {
    print(3);
    Future<List> values = await _getAsynDB(key);
    print(values ?? 5);
    return values;
  }

  deleteValueForKey(String key) async {
    await database.rawDelete('DELETE FROM KeyValue WHERE key = ?', [key]);
  }

  getAllValue() async {
    List<Map> list = await database.rawQuery('SELECT * FROM KeyValue');
    return list;
  }

  _getAsynDB(String key) async {
    print(4.toString() + key);
    return await database.rawQuery('SELECT * FROM KeyValue WHERE key=?', [key]);
  }

  closeDB() async {
    await database?.close();
  }
}
