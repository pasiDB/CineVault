import 'package:Mirarr/functions/get_base_url.dart';
import 'package:Mirarr/functions/regionprovider_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:Mirarr/moviesPage/models/movie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

class CustomMovieWidget extends StatelessWidget {
  static final Map<int, bool> _availabilityCache = {};

  final Movie movie;

  const CustomMovieWidget({super.key, required this.movie});

  Future<bool> checkAvailability(int movieId, BuildContext context) async {
    if (_availabilityCache.containsKey(movieId)) {
      return _availabilityCache[movieId]!;
    }
    final baseUrl =
        getBaseUrl(Provider.of<RegionProvider>(context).currentRegion);
    final apiKey = dotenv.env['TMDB_API_KEY'];
    final response = await http.get(
      Uri.parse(
        '${baseUrl}movie/$movieId/watch/providers?api_key=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final Map<String, dynamic> results = data['results'];

      _availabilityCache[movieId] = results.isNotEmpty;
      return results.isNotEmpty;
    } else {
      _availabilityCache[movieId] = false;
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        height: 500,
        width: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: movie.posterPath.isNotEmpty
              ? DecorationImage(
                  image: CachedNetworkImageProvider(
                    '${getImageBaseUrl(Provider.of<RegionProvider>(context).currentRegion)}/t/p/w500${movie.posterPath}',
                  ),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Stack(
          children: [
            if (movie.posterPath.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black, Colors.transparent]),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            Container(
              margin: const EdgeInsets.only(top: 8, left: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(),
              child: Text(
                '⭐ ${movie.score?.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              right: 10,
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(),
                child: FutureBuilder(
                  future: checkAvailability(movie.id, context),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(5.0),
                        child: SizedBox(
                            height: 10,
                            width: 10,
                            child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.hasError) {
                      return const Text('Error loading data');
                    } else {
                      return snapshot.data == true
                          ? const Icon(
                              Icons.download_rounded,
                              color: Colors.yellow,
                            )
                          : const Icon(
                              Icons.file_download_off_sharp,
                              color: Colors.yellow,
                            );
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Text(
                      movie.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Text(
                      movie.releaseDate,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
