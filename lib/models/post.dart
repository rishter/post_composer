import 'dart:async';
import '../util/db.dart';
import 'slide.dart';

import 'package:sqflite/sqflite.dart';

class Post {
  final int? id;
  final String name;
  DateTime? createdAt;
  List<Slide> slides;

  Post(
      {this.id,
      required this.name,
      this.createdAt,
      this.slides = const [Slide(position: 0, content: "")]});

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'created': createdAt?.millisecondsSinceEpoch,
    };
  }

  String dateString() {
    if (createdAt == null) return 'none';

    return '${createdAt!.month}/${createdAt!.day}/${createdAt!.year}';
  }

  @override
  String toString() {
    String createdString =
        createdAt != null ? ', createdAt${createdAt!.toIso8601String()}' : '';
    return 'Post{id: $id, name: $name$createdString}';
  }
}

Future<Post> upsertPost(Post post) async {
  final db = await getDatabase();
  post.createdAt ??= DateTime.now();
  final int id = await db.insert(
    'posts',
    post.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
  return Post(id: id, name: post.name, createdAt: post.createdAt);
}

Future<List<Post>> getPosts() async {
  final db = await getDatabase();

  final List<Map<String, Object?>> postMaps = await db.query('posts');

  List<Post> posts = [
    for (final {
          'id': id as int,
          'name': name as String,
          'created': created as int,
        } in postMaps)
      Post(
          id: id,
          name: name,
          createdAt: DateTime.fromMillisecondsSinceEpoch(created)),
  ];

  posts.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

  return posts;
}

Future<void> updatePost(Post post) async {
  final db = await getDatabase();
  await db.update(
    'posts',
    post.toMap(),
    where: 'id = ?',
    whereArgs: [post.id],
  );
}

Future<void> deletePost(int id) async {
  final db = await getDatabase();
  await db.delete(
    'posts',
    where: 'id = ?',
    whereArgs: [id],
  );
}
