import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

class GalleryStorage {
  static const _storeName = 'gallery';
  static final _store = stringMapStoreFactory.store(_storeName);
  late Database _db;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = '${dir.path}/gallery.db';
    _db = await databaseFactoryIo.openDatabase(dbPath);
  }

  Future<void> saveImage(File file) async {
    await _store.record(file.path).put(_db, {
      'path': file.path,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<File>> loadImages() async {
    final records = await _store.find(_db);
    return records
        .map((r) => File(r.key))
        .where((f) => f.existsSync())
        .toList();
  }

  Future<void> clear() async {
    await _store.delete(_db);
  }
}
