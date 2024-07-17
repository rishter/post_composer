import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const dbName = 'post_composer_database.db';

Future<void> createTables(DatabaseExecutor db) async {
  await db.execute('''
      CREATE TABLE posts(
        id INTEGER PRIMARY KEY,
        name TEXT,
        created INTEGER
      );
    ''');
  await db.execute('''
      CREATE TABLE slides(
        post_id INTEGER,
        position INTEGER, 
        content TEXT, 
        PRIMARY KEY (post_id, position),
        FOREIGN KEY (post_id) REFERENCES posts(id)
      ) WITHOUT ROWID;
    ''');
}

Future<Database> getDatabase() async {
  WidgetsFlutterBinding.ensureInitialized();
  return await openDatabase(
    join(await getDatabasesPath(), dbName),
    onCreate: (DatabaseExecutor db, version) {
      return createTables(db);
    },
    version: 1,
  );
}

Future<void> deleteDatabase() async {
  await databaseFactory.deleteDatabase(join(await getDatabasesPath(), dbName));
}
