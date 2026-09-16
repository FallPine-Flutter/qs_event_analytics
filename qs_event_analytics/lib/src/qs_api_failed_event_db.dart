part of '../qs_event_analytics.dart';

class _QsApiFailedEventDb {
  _QsApiFailedEventDb._internal();

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _dbName);
    // if (!kReleaseMode) {
    //   await deleteDatabase(path);
    // }
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _onCreate(db: db);
      },
    );
  }

  Future<void> _onCreate({required Database db}) async {
    final columns = _QsApiFailedEventModel.dbColumns();
    final sqlStr = columns.entries
        .map((entry) => "${entry.key} ${entry.value}")
        .join(",");

    await db.execute("""
      CREATE TABLE IF NOT EXISTS $_tableName (
        $sqlStr
      )
    """);
  }

  Future<int?> insert({required _QsApiFailedEventModel row}) async {
    return _database?.insert(_tableName, row.toJson());
  }

  Future<List<_QsApiFailedEventModel>> queryAll() async {
    final maps = await _database?.query(_tableName) ?? [];
    return List.generate(maps.length, (i) {
      return _QsApiFailedEventModel.fromJson(maps[i]);
    });
  }

  Future<int?> delete({required _QsApiFailedEventModel row}) async {
    if (row.eventId == null) {
      return null;
    }
    return _database?.delete(
      _tableName,
      where: 'event_id = ?',
      whereArgs: [row.eventId!],
    );
  }

  static Future<_QsApiFailedEventDb> getInstance() async {
    _instance._database ??= await _instance._initDatabase();
    return _instance;
  }

  final String _dbName = "qs_api_failed_event.db";
  final String _tableName = "qs_api_failed_event_table";
  Database? _database;

  static final _QsApiFailedEventDb _instance = _QsApiFailedEventDb._internal();
}
