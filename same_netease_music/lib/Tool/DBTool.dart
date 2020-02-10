import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';

class DBTool {
  String dbPath;
  Database database;

  Future<Database> OpenKeyValueDB() async {
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

  Future addValueForKey(String key, String value) async {
    List<Map> list =
        await database.rawQuery('SELECT * FROM KeyValue WHERE key=?', [key]);
    if (list == null || list.length == 0) {
      return await database.transaction((txn) async {
        int row = await txn.rawInsert(
            'INSERT INTO KeyValue(key, value) VALUES("$key", "$value")');
        return row;
      });
    } else {
      return await database.rawUpdate(
          'UPDATE KeyValue SET value = ? WHERE key = ?', [value, key]);
    }
  }

  Future<List> getValueWithKey(String key) async {
    List<Map> list =
        await database.rawQuery('SELECT * FROM KeyValue WHERE key=?', [key]);
    return list;
  }

  Future deleteValueForKey(String key) async {
    return await database
        .rawDelete('DELETE FROM KeyValue WHERE key = ?', [key]);
  }

  Future getAllValue() async {
    List<Map> list = await database.rawQuery('SELECT * FROM KeyValue');
    return list;
  }

  Future<Database> OpenHistoryDB() async {
    var databasesPath = await getDatabasesPath();
    dbPath = join(databasesPath, 'netease.db');
    return await _createHistoryTable();
  }

  Future _createHistoryTable() async {
    // open the database
    return database = await openDatabase(dbPath, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE IF NOT EXISTS SearchHistory (searchName TEXT)');
      return database;
    });
  }

  Future addHistoryForName(String name) async {
    List<Map> list = await database
        .rawQuery('SELECT * FROM SearchHistory WHERE searchName=?', [name]);
    if (list == null || list.length == 0) {
      return await database.transaction((txn) async {
        int row = await txn
            .rawInsert('INSERT INTO SearchHistory(searchName) VALUES("$name")');
        return row;
      });
    } else {
      return null;
    }
  }

  Future deleteHistoryForName(String name) async {
    return await database
        .rawDelete('DELETE FROM SearchHistory WHERE searchName = ?', [name]);
  }

  Future getAllHistory() async {
    List<Map> list = await database.rawQuery('SELECT * FROM SearchHistory');
    return list;
  }

  Future closeDB() async {
    return await database?.close();
  }
}
