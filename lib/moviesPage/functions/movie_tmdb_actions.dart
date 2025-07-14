import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:hive/hive.dart';

final apiKey = dotenv.env['TMDB_API_KEY'];

Future<String?> addWatchList(
    String accountId, String sessionId, int movieId) async {
  final openbox = await Hive.openBox('sessionBox');
  final String accountId = openbox.get('accountId');
  final String sessionData = openbox.get('sessionData');
  const String baseUrl = 'https://tmdb.maybeparsa.top/tmdb';

  final String url =
      '$baseUrl/account/$accountId/watchlist?api_key=$apiKey&session_id=$sessionData';

  Map<String, dynamic> requestBody = {
    'media_type': 'movie',
    'media_id': movieId,
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
        debugPrint('Movie added to watchlist successfully!');
      }
      return null;
    } else {
      return 'Failed to add movie to watchlist';
    }
  } catch (error) {
    return error.toString();
  }
}

Future<String?> addRating(
    String sessionId, int movieId, double userScore) async {
  final openbox = await Hive.openBox('sessionBox');
  final String sessionData = openbox.get('sessionData');
  const String baseUrl = 'https://tmdb.maybeparsa.top/tmdb';

  final String url =
      '$baseUrl/movie/$movieId/rating?api_key=$apiKey&session_id=$sessionData';

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
        debugPrint('Rating added for $movieId successfully!');
      }
      return null;
    } else {
      return 'Failed to add rating for $movieId';
    }
  } catch (error) {
    return error.toString();
  }
}

Future<String?> removeRating(String sessionId, int movieId) async {
  final openbox = await Hive.openBox('sessionBox');
  final String sessionData = openbox.get('sessionData');
  const String baseUrl = 'https://tmdb.maybeparsa.top/tmdb';

  final String url =
      '$baseUrl/movie/$movieId/rating?api_key=$apiKey&session_id=$sessionData';

  try {
    final http.Response response = await http.delete(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json;charset=utf-8',
      },
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        debugPrint('Rating removed for $movieId successfully!');
      }
      return null;
    } else {
      return 'Failed to remove rating for $movieId';
    }
  } catch (error) {
    return error.toString();
  }
}

Future<String?> addFavorite(
    String accountId, String sessionId, int movieId) async {
  final openbox = await Hive.openBox('sessionBox');
  final String accountId = openbox.get('accountId');
  final String sessionData = openbox.get('sessionData');
  const String baseUrl = 'https://tmdb.maybeparsa.top/tmdb';

  final String url =
      '$baseUrl/account/$accountId/favorite?api_key=$apiKey&session_id=$sessionData';

  Map<String, dynamic> requestBody = {
    'media_type': 'movie',
    'media_id': movieId,
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
        debugPrint('Movie added to favorites successfully!');
      }
      return null;
    } else {
      return 'Failed to add movie to favorites';
    }
  } catch (error) {
    return error.toString();
  }
}

Future<String?> removeFromWatchList(
    String accountId, String sessionId, int movieId) async {
  final openbox = await Hive.openBox('sessionBox');
  final String accountId = openbox.get('accountId');
  final String sessionData = openbox.get('sessionData');
  const String baseUrl = 'https://tmdb.maybeparsa.top/tmdb';

  final String url =
      '$baseUrl/account/$accountId/watchlist?api_key=$apiKey&session_id=$sessionData';

  Map<String, dynamic> requestBody = {
    'media_type': 'movie',
    'media_id': movieId,
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
        debugPrint('Movie removed from watchlist successfully!');
      }
      return null;
    } else {
      return 'Failed to remove movie from watchlist';
    }
  } catch (error) {
    return error.toString();
  }
}

Future<String?> removeFromFavorite(
    String accountId, String sessionId, int movieId) async {
  final openbox = await Hive.openBox('sessionBox');
  final String accountId = openbox.get('accountId');
  final String sessionData = openbox.get('sessionData');
  const String baseUrl = 'https://tmdb.maybeparsa.top/tmdb';

  final String url =
      '$baseUrl/account/$accountId/favorite?api_key=$apiKey&session_id=$sessionData';

  Map<String, dynamic> requestBody = {
    'media_type': 'movie',
    'media_id': movieId,
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
        debugPrint('Movie removed from favorites successfully!');
      }
      return null;
    } else {
      return 'Failed to remove movie from favorites';
    }
  } catch (error) {
    return error.toString();
  }
}
