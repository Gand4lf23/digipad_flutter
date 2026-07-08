import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

class GalleryStorage {
  // Singleton: all GalleryStorage() calls return the same instance and DB.
  static final GalleryStorage instance = GalleryStorage._();
  GalleryStorage._();
  factory GalleryStorage() => instance;

  static const _storeName = 'gallery';
  static final StoreRef<String, Map<String, dynamic>> _store =
      stringMapStoreFactory.store(_storeName);

  late Database _db;
  Future<void>? _initFuture;

  Future<void> init() {
    _initFuture ??= _doInit();
    return _initFuture!;
  }

  Future<void> _doInit() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'gallery.db');
    _db = await databaseFactoryIo.openDatabase(dbPath);
  }

  Future<void> saveImage(File file) async {
    await init();
    await _store.record(file.path).put(_db, {
      'path': file.path,
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'image',
    });
  }

  Future<void> saveVideo(File file) async {
    await init();
    await _store.record(file.path).put(_db, {
      'path': file.path,
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'video',
    });
  }

  Future<List<File>> loadImages() async {
    await init();
    final records = await _store.find(_db);
    records.sort((a, b) {
      final tA = DateTime.tryParse(a.value['timestamp'] ?? '') ?? DateTime(0);
      final tB = DateTime.tryParse(b.value['timestamp'] ?? '') ?? DateTime(0);
      return tB.compareTo(tA);
    });
    return records
        .map((r) => File(r.value['path'] as String))
        .where((f) => f.existsSync())
        .toList();
  }

  /// Reactive stream — emits immediately and again on every save/delete.
  Stream<List<File>> watchImages() async* {
    await init();
    yield* _store.query().onSnapshots(_db).map((records) {
      final sorted = [...records];
      sorted.sort((a, b) {
        final tA = DateTime.tryParse(a.value['timestamp'] ?? '') ?? DateTime(0);
        final tB = DateTime.tryParse(b.value['timestamp'] ?? '') ?? DateTime(0);
        return tB.compareTo(tA);
      });
      return sorted
          .map((r) => File(r.value['path'] as String))
          .where((f) => f.existsSync())
          .toList();
    });
  }

  Future<bool> deleteImage(File file) async {
    try {
      await init();
      await _store.record(file.path).delete(_db);
      if (await file.exists()) {
        await file.delete();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> clearDatabase() async {
    await init();
    await _store.delete(_db);
  }
}
