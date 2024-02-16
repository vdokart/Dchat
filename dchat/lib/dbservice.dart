import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, 'user_login.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            password TEXT
          )
        ''');
      },
    );
  }
}

class User {
  final int id;
  final String username;
  final String password;

  User({
    required this.id,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
    );
  }
}

class Parameter {
  final int id;
  final double temperature;
  final double topP;
  final int maxTokens;
  final int numResponses;
  final double presencePenalty;
  final double frequencyPenalty;
  final String stopSequences;
  final String systemPrompt;

  Parameter({
    required this.id,
    required this.temperature,
    required this.topP,
    required this.maxTokens,
    required this.numResponses,
    required this.presencePenalty,
    required this.frequencyPenalty,
    required this.stopSequences,
    required this.systemPrompt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'temperature': temperature,
      'topP': topP,
      'maxTokens': maxTokens,
      'numResponses': numResponses,
      'presencePenalty': presencePenalty,
      'frequencyPenalty': frequencyPenalty,
      'stopSequences': stopSequences,
      'systemPrompt': systemPrompt,
    };
  }
}

class ParameterService {
  static final ParameterService _instance = ParameterService._internal();
  factory ParameterService() => _instance;
  ParameterService._internal();

  late Database _database;

  Future<void> initializeDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, 'app.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS parameters (
            id INTEGER PRIMARY KEY,
            temperature REAL,
            topP REAL,
            maxTokens INTEGER,
            numResponses INTEGER,
            presencePenalty REAL,
            frequencyPenalty REAL,
            stopSequences TEXT
            systemPrompt TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertParameter(Parameter parameter) async {
    await _database.insert(
      'parameters',
      parameter.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Parameter>> getParameters() async {
    final List<Map<String, dynamic>> maps = await _database.query('parameters');
    return List.generate(maps.length, (i) {
      return Parameter(
        id: maps[i]['id'],
        temperature: maps[i]['temperature'],
        topP: maps[i]['topP'],
        maxTokens: maps[i]['maxTokens'],
        numResponses: maps[i]['numResponses'],
        presencePenalty: maps[i]['presencePenalty'],
        frequencyPenalty: maps[i]['frequencyPenalty'],
        stopSequences: maps[i]['stopSequences'],
        systemPrompt: maps[i]['systemPrompt'],
      );
    });
  }

  Future<void> updateParameter(Parameter parameter) async {
    await _database.update(
      'parameters',
      parameter.toMap(),
      where: "id = ?",
      whereArgs: [parameter.id],
    );
  }

  Future<void> deleteParameter(int id) async {
    await _database.delete(
      'parameters',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
