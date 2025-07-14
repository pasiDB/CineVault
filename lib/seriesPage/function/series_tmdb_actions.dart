import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:hive/hive.dart';

final apiKey = dotenv.env['TMDB_API_KEY'];
Future<String?> addRating(
    String sessionId, int serieId, double userScore) async {
  final openbox = await Hive.openBox('sessionBox');
  final String sessionData = openbox.get('sessionData');
  const String baseUrl = 'https://tmdb.maybeparsa.top/tmdb';

  final String url =
      '$baseUrl/tv/$serieId/rating?api_key=$apiKey&session_id=$sessionData';

  Map<String, dynamic> requestBody = {
    'value': userScore,
  };

  try {
    final http.Response response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json;charset=utf-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 201) {
      if (kDebugMode) {
        debugPrint('Rating added for $serieId successfully!');
      }
      return null;
    } else {
      return 'Failed to add rating for $serieId';
    }
  } catch (error) {
    return error.toString();
  }
}

Future<String?> removeRating(String sessionId, int serieId) async {
  final openbox = await Hive.openBox('sessionBox');
  final String sessionData = openbox.get('sessionData');
  const String baseUrl = 'https://tmdb.maybeparsa.top/tmdb';

  final String url =
      '$baseUrl/tv/$serieId/rating?api_key=$apiKey&session_id=$sessionData';

  try {
    final http.Response response = await http.delete(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json;charset=utf-8',
      },
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        debugPrint('Rating removed for $serieId successfully!');
      }
      return null;
    } else {
      return 'Failed to remove rating for $serieId';
    }
  } catch (error) {
    return error.toString();
  }
}

Future<String?> addWatchList(
    String accountId, String sessionId, int serieId) async {
  final openbox = await Hive.openBox('sessionBox');
  final String accountId = openbox.get('accountId');
  final String sessionData = openbox.get('sessionData');
  const String baseUrl = 'https://tmdb.maybeparsa.top/tmdb';

  final String url =
      '$baseUrl/account/$accountId/watchlist?api_key=$apiKey&session_id=$sessionData';

  Map<String, dynamic> requestBody = {
    'media_type': 'tv',
    'media_id': serieId,
    'watchlist': true,
  };

  try {
    final http.Response response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json;charset=utf-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 201) {
      if (kDebugMode) {
        debugPrint('Serie added to watchlist successfully!');
      }
      return null;
    } else {
      return 'Failed to add serie to watchlist';
    }
  } catch (error) {
    return error.toString();
  }
}

Future<String?> addFavorite(
    String accountId, String sessionId, int serieId) async {
  final openbox = await Hive.openBox('sessionBox');
  final String accountId = openbox.get('accountId');
  final String sessionData = openbox.get('sessionData');
  const String baseUrl = 'https://tmdb.maybeparsa.top/tmdb';

  final String url =
      '$baseUrl/account/$accountId/favorite?api_key=$apiKey&session_id=$sessionData';

  Map<String, dynamic> requestBody = {
    'media_type': 'tv',
    'media_id': serieId,
    'favorite': true,
  };

  try {
    final http.Response response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json;charset=utf-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 201) {
      if (kDebugMode) {
        debugPrint('Serie added to favorites successfully!');
      }
      return null;
    } else {
      return 'Failed to add serie to favorites';
    }
  } catch (error) {
    return error.toString();
  }
}

Future<String?> removeFromWatchList(
    String accountId, String sessionId, int serieId) async {
  final openbox = await Hive.openBox('sessionBox');
  final String accountId = openbox.get('accountId');
  final String sessionData = openbox.get('sessionData');
  const String baseUrl = 'https://tmdb.maybeparsa.top/tmdb';

  final String url =
      '$baseUrl/account/$accountId/watchlist?api_key=$apiKey&session_id=$sessionData';

  Map<String, dynamic> requestBody = {
    'media_type': 'tv',
    'media_id': serieId,
    'watchlist': false,
  };

  try {
    final http.Response response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json;charset=utf-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        debugPrint('Serie removed from watchlist successfully!');
      }
      return null;
    } else {
      return 'Failed to remove serie from watchlist';
    }
  } catch (error) {
    return error.toString();
  }
}

Future<String?> removeFromFavorite(
    String accountId, String sessionId, int serieId) async {
  final openbox = await Hive.openBox('sessionBox');
  final String accountId = openbox.get('accountId');
  final String sessionData = openbox.get('sessionData');
  const String baseUrl = 'https://tmdb.maybeparsa.top/tmdb';

  final String url =
      '$baseUrl/account/$accountId/favorite?api_key=$apiKey&session_id=$sessionData';

  Map<String, dynamic> requestBody = {
    'media_type': 'tv',
    'media_id': serieId,
    'favorite': false,
  };

  try {
    final http.Response response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json;charset=utf-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        debugPrint('Serie removed from favorites successfully!');
      }
      return null;
    } else {
      return 'Failed to remove serie from favorites';
    }
  } catch (error) {
    return error.toString();
  }
}
