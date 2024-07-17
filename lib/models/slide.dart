import 'dart:async';

import '../util/db.dart';

import 'package:sqflite/sqflite.dart';

class Slide {
  final int? postId;
  final int position;
  final String content;

  const Slide({
    this.postId,
    required this.position,
    required this.content,
  });

  Map<String, Object?> toMap() {
    return {
      'post_id': postId,
      'position': position,
      'content': content,
    };
  }

  @override
  String toString() {
    return 'Slide{postId: $postId, position: $position, content: $content}';
  }
}

Future<Slide> upsertSlide(Slide slide, {Transaction? trx}) async {
  final db = trx ?? await getDatabase();
  await db.insert(
    'slides',
    slide.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
  return Slide(
      postId: slide.postId, position: slide.position, content: slide.content);
}

Future<List<Slide>> getSlidesForPost(int postId) async {
  final db = await getDatabase();

  final List<Map<String, Object?>> slideMaps =
      await db.query('slides', where: 'post_id = ?', whereArgs: [postId]);

  List<Slide> slides = [
    for (final {
          'post_id': postId as int,
          'position': position as int,
          'content': content as String,
        } in slideMaps)
      Slide(postId: postId, position: position, content: content)
  ];

  slides.sort((a, b) => a.position.compareTo(b.position));

  return slides;
}

Future<List<Slide>> deleteSlideCascade(int postId, int position) async {
  final db = await getDatabase();
  List<Slide> slides = await getSlidesForPost(postId);

  db.transaction((Transaction trx) async {
    await deleteSlide(postId, position, trx: trx);

    for (int i = position + 1; i < slides.length; i++) {
      // replace the previous slide
      await upsertSlide(
          Slide(postId: postId, position: i - 1, content: slides[i].content),
          trx: trx);

      await deleteSlide(postId, i, trx: trx);
    }
  });

  return await getSlidesForPost(postId);
}

Future<void> deleteSlide(int postId, int position, {Transaction? trx}) async {
  final db = trx ?? await getDatabase();

  await db.delete(
    'slides',
    where: 'post_id = ? and position = ?',
    whereArgs: [postId, position],
  );
}
