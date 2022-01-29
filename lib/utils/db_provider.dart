import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shop_record/models/mobile_part.dart';
import 'package:shop_record/models/part_item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBProvider {
  static const _dbName = "mobileDatabase.db";
  static const tableName = "mobilepart";
  static const tableName1 = "mobilepartitems";
  static const _dbVersion = 2;
  static const columnId = "_id";
  static const coulmnPartName = "partname";
  static const columnIconName = "iconname";
  // making a singleton class
  DBProvider._();
  static final DBProvider instance = DBProvider._();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();
  _initDatabase() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String path = join(appDocDir.path, _dbName);
    // await deletedDatabase(path);

    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $tableName(
      $columnId INTEGER PRIMARY KEY,
      $coulmnPartName TEXT NOT NULL,
      $columnIconName TEXT NOT NULL)
    ''');
    await db.execute('''
    CREATE TABLE $tableName1(
      ${PartItem.columnId} INTEGER PRIMARY KEY,
      ${PartItem.columnPartName} TEXT NOT NULL,
      ${PartItem.columnItemName} TEXT NOT NULL,
      ${PartItem.columnPrice} LONG INTEGER)
    ''');
  }

  // insert mobileparts
  Future<MobilePart> insert(MobilePart row) async {
    Database db = await instance.database;
    final id = await db.insert(tableName, row.toMap());
    return row.copy(id: id);
  }

  // insert part items of different company and sizes
  Future<PartItem> insertPartItem(PartItem row) async {
    Database db = await instance.database;
    final id = await db.insert(tableName1, row.toMap());
    debugPrint("insertPartItem: $id");
    return row.copy(id: id);
  }

  Future<List<MobilePart>> queryAll() async {
    Database db = await instance.database;

    final result = await db.query(tableName);
    debugPrint(result.toString());
    return result.isEmpty
        ? []
        : result.map((item) => MobilePart.fromMap(item)).toList();
  }

// query all parts for a specific mobile part
  Future<List<PartItem>> queryAllPartItems(String part) async {
    Database db = await instance.database;

    final result = await db.query(tableName1,
        where: '${PartItem.columnPartName}=?', whereArgs: [part]);
    debugPrint(result.toString());
    return result.isEmpty
        ? []
        : result.map((item) => PartItem.fromMap(item)).toList();
  }

  Future<MobilePart> update(MobilePart row) async {
    Database db = await instance.database;

    var index = await db.update(tableName, row.toMap(),
        where: '$columnId = ?', whereArgs: [row.id]);
    debugPrint("from upo: " + index.toString());
    return row.copy();
  }

// update a specific part item
  Future<PartItem> updatePartItem(PartItem row) async {
    Database db = await instance.database;

    int index = await db.update(tableName1, row.toMap(),
        where: '${PartItem.columnId} = ?', whereArgs: [row.id]);
    debugPrint(row.copy().toMap().toString());
    debugPrint(index.toString());
    return row.copy(id: row.id);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(tableName, where: '$columnId = ?', whereArgs: [id]);
  }

// delete items of mobile part
  Future<int> deletePartItem(String partName) async {
    Database db = await instance.database;
    return await db.delete(tableName1,
        where: '${PartItem.columnPartName}= ?', whereArgs: [partName]);
  }

  // delete a specific item of mobile part
  Future<int> deleteSinglePartItem(int id) async {
    Database db = await instance.database;
    return await db
        .delete(tableName1, where: '${PartItem.columnId}= ?', whereArgs: [id]);
  }

  Future deleteTable() async {
    Database db = await instance.database;

    db.rawQuery("DROP TABLE IF EXISTS $tableName");
  }

  Future deletedDatabase(String path) async {
    databaseFactory.deleteDatabase(path);
  }
}
