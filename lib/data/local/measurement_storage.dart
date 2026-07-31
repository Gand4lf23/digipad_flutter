import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import '../models/measurement_record.dart';

class MeasurementStorage {
  static final MeasurementStorage instance = MeasurementStorage._();
  MeasurementStorage._();
  factory MeasurementStorage() => instance;

  static const _storeName = 'measurements';
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
    final dbPath = p.join(dir.path, 'measurements.db');
    _db = await databaseFactoryIo.openDatabase(dbPath);
  }

  Future<void> save(MeasurementRecord record) async {
    await init();
    await _store.record(record.id).put(_db, record.toJson());
  }

  Future<List<MeasurementRecord>> getAll() async {
    await init();
    final records = await _store.find(_db);
    final result = <MeasurementRecord>[];
    for (final r in records) {
      try {
        result.add(MeasurementRecord.fromJson(Map<String, dynamic>.from(r.value)));
      } catch (_) {}
    }
    return result;
  }

  Future<MeasurementRecord?> getById(String id) async {
    await init();
    final record = await _store.record(id).get(_db);
    if (record == null) return null;
    return MeasurementRecord.fromJson(Map<String, dynamic>.from(record));
  }

  Future<void> delete(String id) async {
    await init();
    await _store.record(id).delete(_db);
  }
}
