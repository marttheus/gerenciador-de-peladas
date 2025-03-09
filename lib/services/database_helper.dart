import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import '../models/player.dart';
import '../models/match.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'gerenciador_pelada.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE players(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        weight INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE matches(
        id TEXT PRIMARY KEY,
        dateTime TEXT NOT NULL,
        durationMinutes INTEGER NOT NULL,
        cost REAL NOT NULL,
        sortMethod INTEGER NOT NULL,
        maxPlayersPerTeam INTEGER NOT NULL,
        status INTEGER NOT NULL,
        pixKey TEXT,
        selectedPlayers TEXT NOT NULL,
        teams TEXT NOT NULL,
        paidPlayerIds TEXT NOT NULL,
        preselectedTeams TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertPlayer(Player player) async {
    final db = await database;
    await db.insert(
      'players',
      player.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updatePlayer(Player player) async {
    final db = await database;
    await db.update(
      'players',
      player.toJson(),
      where: 'id = ?',
      whereArgs: [player.id],
    );
  }

  Future<void> deletePlayer(String id) async {
    final db = await database;
    await db.delete('players', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Player>> getPlayers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('players');

    return List.generate(maps.length, (i) {
      return Player.fromJson(maps[i]);
    });
  }

  Map<String, dynamic> _matchToJson(Match match) {
    return {
      'id': match.id,
      'dateTime': match.dateTime.toIso8601String(),
      'durationMinutes': match.durationMinutes,
      'cost': match.cost,
      'sortMethod': match.sortMethod.index,
      'maxPlayersPerTeam': match.maxPlayersPerTeam,
      'status': match.status.index,
      'pixKey': match.pixKey,
      'selectedPlayers': jsonEncode(
        match.selectedPlayers.map((p) => p.toJson()).toList(),
      ),
      'teams': jsonEncode(
        match.teams
            .map(
              (t) => {
                'id': t.id,
                'name': t.name,
                'players': t.players.map((p) => p.toJson()).toList(),
              },
            )
            .toList(),
      ),
      'paidPlayerIds': jsonEncode(match.paidPlayerIds),
      'preselectedTeams': jsonEncode(match.preselectedTeams),
    };
  }

  Match _matchFromJson(Map<String, dynamic> json) {
    final selectedPlayersJson = jsonDecode(json['selectedPlayers']) as List;
    final selectedPlayers =
        selectedPlayersJson
            .map(
              (playerJson) =>
                  Player.fromJson(Map<String, dynamic>.from(playerJson)),
            )
            .toList();

    final teamsJson = jsonDecode(json['teams']) as List;
    final teams =
        teamsJson.map((teamJson) {
          final Map<String, dynamic> teamMap = Map<String, dynamic>.from(
            teamJson,
          );
          final playersJson = teamMap['players'] as List;
          final players =
              playersJson
                  .map(
                    (playerJson) =>
                        Player.fromJson(Map<String, dynamic>.from(playerJson)),
                  )
                  .toList();

          return Team(
            id: teamMap['id'],
            name: teamMap['name'],
            players: players,
          );
        }).toList();

    final paidPlayerIdsJson = jsonDecode(json['paidPlayerIds']) as List;
    final paidPlayerIds = paidPlayerIdsJson.cast<String>();

    final preselectedTeamsJson = jsonDecode(json['preselectedTeams']) as Map;
    final preselectedTeams = Map<String, List<String>>.from(
      preselectedTeamsJson.map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      ),
    );

    return Match(
      id: json['id'],
      dateTime: DateTime.parse(json['dateTime']),
      durationMinutes: json['durationMinutes'],
      cost: json['cost'],
      sortMethod: TeamSortMethod.values[json['sortMethod']],
      maxPlayersPerTeam: json['maxPlayersPerTeam'],
      selectedPlayers: selectedPlayers,
      teams: teams,
      status: MatchStatus.values[json['status']],
      pixKey: json['pixKey'],
      paidPlayerIds: paidPlayerIds,
      preselectedTeams: preselectedTeams,
    );
  }

  Future<void> insertMatch(Match match) async {
    final db = await database;
    await db.insert(
      'matches',
      _matchToJson(match),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateMatch(Match match) async {
    final db = await database;
    await db.update(
      'matches',
      _matchToJson(match),
      where: 'id = ?',
      whereArgs: [match.id],
    );
  }

  Future<void> deleteMatch(String id) async {
    final db = await database;
    await db.delete('matches', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Match>> getMatches() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('matches');

    return List.generate(maps.length, (i) {
      return _matchFromJson(maps[i]);
    });
  }
}
