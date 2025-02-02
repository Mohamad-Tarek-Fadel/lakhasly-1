import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../domain/transcription.dart';
import '../domain/transcription_insight.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('transcriptions.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transcriptions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE insights(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transcription_id INTEGER NOT NULL,
        type INTEGER NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        rating INTEGER,
        FOREIGN KEY (transcription_id) REFERENCES transcriptions (id)
          ON DELETE CASCADE
      )
    ''');
  }

  Future<Transcription> create(Transcription transcription) async {
    final db = await instance.database;
    final id = await db.insert('transcriptions', transcription.toMap());
    return transcription.copyWith(id: id);
  }

  Future<List<Transcription>> getAllTranscriptions() async {
    final db = await instance.database;
    final result = await db.query('transcriptions', orderBy: 'created_at DESC');
    return result.map((json) => Transcription.fromMap(json)).toList();
  }

  Future<List<Transcription>> searchTranscriptions(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'transcriptions',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return result.map((json) => Transcription.fromMap(json)).toList();
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'transcriptions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> update(Transcription transcription) async {
    final db = await instance.database;
    return await db.update(
      'transcriptions',
      transcription.toMap(),
      where: 'id = ?',
      whereArgs: [transcription.id],
    );
  }

  Future<TranscriptionInsight> createInsight(TranscriptionInsight insight) async {
    final db = await instance.database;
    final id = await db.insert('insights', insight.toMap());
    return insight.copyWith(id: id);
  }

  Future<List<TranscriptionInsight>> getInsightsForTranscription(int transcriptionId) async {
    final db = await instance.database;
    final result = await db.query(
      'insights',
      where: 'transcription_id = ?',
      whereArgs: [transcriptionId],
      orderBy: 'created_at DESC',
    );
    return result.map((json) => TranscriptionInsight.fromMap(json)).toList();
  }

  Future<int> updateInsightRating(int insightId, int rating) async {
    final db = await instance.database;
    return await db.update(
      'insights',
      {'rating': rating},
      where: 'id = ?',
      whereArgs: [insightId],
    );
  }
} 