import 'dart:io';
import 'dart:ui';

import 'package:mirarr/functions/fetchers/fetch_movie_credits.dart';
import 'package:mirarr/functions/fetchers/fetch_movie_details.dart';
import 'package:mirarr/functions/fetchers/fetch_other_movies_by_director.dart';
import 'package:mirarr/functions/get_base_url.dart';
import 'package:mirarr/functions/regionprovider_class.dart';
import 'package:mirarr/moviesPage/checkers/custom_tmdb_ids_effects.dart';
import 'package:mirarr/moviesPage/functions/get_imdb_rating.dart';
import 'package:mirarr/moviesPage/functions/movie_tmdb_actions.dart';
import 'package:mirarr/moviesPage/functions/on_tap_movie_desktop.dart';
import 'package:mirarr/moviesPage/functions/torrent_links.dart';
import 'package:mirarr/moviesPage/movie_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:mirarr/moviesPage/UI/cast_crew_row.dart';
import 'package:mirarr/widgets/bottom_bar.dart';
import 'package:mirarr/moviesPage/functions/check_availability.dart';
import 'package:mirarr/widgets/custom_divider.dart';
import 'package:mirarr/widgets/image_gallery_page.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mirarr/moviesPage/functions/watch_links.dart';
import 'package:provider/provider.dart';
import 'package:mirarr/functions/show_error_dialog.dart';

class MovieDetailPageDesktop extends StatefulWidget {
  final String movieTitle;
  final int movieId;

  const MovieDetailPageDesktop(
      {super.key, required this.movieTitle, required this.movieId});

  @override
  MovieDetailPageDesktopState createState() => MovieDetailPageDesktopState();
}

class MovieDetailPageDesktopState extends State<MovieDetailPageDesktop> {
  late Future<List<String>> _castImagesFuture;
  bool? isMovieWatchlist;
  bool? isMovieFavorite;
  bool isUserLoggedIn = false;
  dynamic isMovieRated;
  double? userRating;
  double? userScore;
  String? imdbId;

  final apiKey = dotenv.env['TMDB_API_KEY'];

  Map<String, dynamic>? moviedetails;
  Map<String, dynamic>? movieInfo;

  double? popularity;
  int? budget;
  int? revenue;
  List<dynamic>? genres;
  List<dynamic>? productionCountries;
  List<dynamic>? productionCompanies;
  List<dynamic>? spokenLanguages;

  String? backdrops;
  double? score;
  String? about;
  int? duration;
  String? releaseDate;
  String? language;
  String? posterPath;
  String? imdbRating;
  String rottenTomatoesRating = 'N/A';

  @override
  void initState() {
    super.initState();
    checkUserLogin();
    _fetchMovieDetails();
    checkAccountState();
    _loadMovieImages();
    final region =
        Provider.of<RegionProvider>(context, listen: false).currentRegion;
    fetchCredits(widget.movieId, region);
  }

  void onTapMovie(String movieTitle, int movieId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MovieDetailPage(movieTitle: movieTitle, movieId: movieId),
      ),
    );
  }

  void _loadMovieImages() {
    _castImagesFuture = _fetchMovieImages(widget.movieId);
  }

  void _openImageGallery(List<String> imageUrls) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageGalleryPage(imageUrls: imageUrls),
      ),
    );
  }

  Future<void> checkUserLogin() async {
    final openbox = await Hive.openBox('sessionBox');
    final sessionData = openbox.get('sessionData');
    if (sessionData != null) {
      setState(() {
        isUserLoggedIn = true;
      });
    }
  }

  Future<void> checkAccountState() async {
    final region =
        Provider.of<RegionProvider>(context, listen: false).currentRegion;
    final openbox = await Hive.openBox('sessionBox');
    final sessionId = openbox.get('sessionData');
    final baseUrl = getBaseUrl(region);
    final response = await http.get(
      Uri.parse(
          '${baseUrl}movie/${widget.movieId}/account_states?api_key=$apiKey&session_id=$sessionId'),
    );
    if (!mounted) return;
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      setState(() {
        isMovieWatchlist = responseData['watchlist'];
        isMovieFavorite = responseData['favorite'];
        isMovieRated = responseData['rated'];
        if (isMovieRated != false) {
          userRating = responseData['rated']['value'];
        }
      });
    }
  }

  Future<List<String>> _fetchMovieImages(int movieId) async {
    final region =
        Provider.of<RegionProvider>(context, listen: false).currentRegion;
    final baseUrl = getBaseUrl(region);
    final response = await http.get(
      Uri.parse('${baseUrl}movie/$movieId/images?api_key=$apiKey'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['backdrops'];
      return data.map((image) => image['file_path'] as String).toList();
    } else {
      throw Exception('Failed to load cast images');
    }
  }

  void updateImdbRating(String rating) {
    setState(() {
      imdbRating = rating;
    });
  }

  void updateRottenTomatoesRating(String rating) {
    setState(() {
      rottenTomatoesRating = rating;
    });
  }

  Future<void> _fetchMovieDetails() async {
    try {
      final region =
          Provider.of<RegionProvider>(context, listen: false).currentRegion;
      final responseData = await fetchMovieDetails(widget.movieId, region);
      if (!mounted) return;
      setState(() {
        moviedetails = responseData;
        budget = responseData['budget'];
        revenue = responseData['revenue'];
        genres = responseData['genres'];
        backdrops = responseData['backdrop_path'];
        score = responseData['vote_average'];
        about = responseData['overview'];
        duration = responseData['runtime'];
        releaseDate = responseData['release_date'];
        language = responseData['original_language'];
        posterPath = responseData['poster_path'];
        productionCountries = responseData['production_countries'];
        productionCompanies = responseData['production_companies'];
        spokenLanguages = responseData['spoken_languages'];
        imdbId = responseData['imdb_id'];
      });
      if (imdbId != null) {
        await getMovieRatings(
            imdbId, updateImdbRating, updateRottenTomatoesRating);
        if (!mounted) return;
      }
    } catch (e) {
      throw Exception('Failed to load movie details');
    }
  }

  @override
  Widget build(BuildContext context) {
    final region =
        Provider.of<RegionProvider>(context, listen: false).currentRegion;
    int? hours = duration != null ? duration! ~/ 60 : null;
    int? minutes = duration != null ? duration! % 60 : null;
    String year = releaseDate != null && releaseDate!.isNotEmpty
        ? releaseDate!.substring(0, 4)
        : 'NA';
    return Scaffold(
      appBar: Platform.isLinux || Platform.isWindows || Platform.isMacOS
          ? AppBar(
              toolbarHeight: 40,
              backgroundColor: getMovieColor(context, widget.movieId),
              iconTheme: const IconThemeData(color: Colors.black),
              actions: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                  child: Text(
                    widget.movieTitle,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            )
          : null,
      body: moviedetails == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(
                physics: const BouncingScrollPhysics(),
                scrollbars: true,
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                },
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: CachedNetworkImageProvider(
                                '${getImageBaseUrl(region)}/t/p/w500$backdrops'),
                            fit: BoxFit.fitWidth,
                            opacity: 0.5),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CachedNetworkImage(
                                imageUrl:
                                    '${getImageBaseUrl(region)}/t/p/w500$posterPath',
                                placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  height: 800,
                                  width: 600,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20)),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: imageProvider,
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                    ),
                                    child: Text(widget.movieTitle,
                                        style: getMovieTitleTextStyle(
                                            widget.movieId)),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          _castImagesFuture.then((imageUrls) {
                                            _openImageGallery(imageUrls);
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.image_rounded,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Visibility(
                                        visible: isUserLoggedIn == true,
                                        child: GestureDetector(
                                          onTap: () async {
                                            if (!mounted) return;
                                            if (isMovieWatchlist == null) {
                                              return;
                                            }
                                            final movieId = widget.movieId;
                                            final openbox = await Hive.openBox(
                                                'sessionBox');
                                            final String accountId =
                                                openbox.get('accountId');
                                            final String sessionData =
                                                openbox.get('sessionData');
                                            if (isMovieWatchlist!) {
                                              // Remove from watchlist
                                              final error =
                                                  await removeFromWatchList(
                                                      accountId,
                                                      sessionData,
                                                      movieId);
                                              if (error != null &&
                                                  context.mounted) {
                                                showErrorDialog(
                                                    'Error', error, context);
                                              } else {
                                                setState(() {
                                                  isMovieWatchlist = false;
                                                });
                                              }
                                            } else {
                                              // Add to watchlist
                                              final error = await addWatchList(
                                                  accountId,
                                                  sessionData,
                                                  movieId);
                                              if (error != null &&
                                                  context.mounted) {
                                                showErrorDialog(
                                                    'Error', error, context);
                                              } else {
                                                setState(() {
                                                  isMovieWatchlist = true;
                                                });
                                              }
                                            }
                                          },
                                          child: Icon(
                                            isMovieWatchlist == null
                                                ? Icons.bookmark_border
                                                : isMovieWatchlist!
                                                    ? Icons.bookmark
                                                    : Icons.bookmark_border,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: isUserLoggedIn == true,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 0, 0, 0),
                                          child: GestureDetector(
                                            onTap: () async {
                                              if (!mounted) return;
                                              if (isMovieFavorite == null) {
                                                return;
                                              }
                                              final movieId = widget.movieId;
                                              final openbox =
                                                  await Hive.openBox(
                                                      'sessionBox');
                                              final String accountId =
                                                  openbox.get('accountId');
                                              final String sessionData =
                                                  openbox.get('sessionData');
                                              if (isMovieFavorite!) {
                                                final error =
                                                    await removeFromFavorite(
                                                        accountId,
                                                        sessionData,
                                                        movieId);
                                                if (error != null &&
                                                    context.mounted) {
                                                  showErrorDialog(
                                                      'Error', error, context);
                                                } else {
                                                  setState(() {
                                                    isMovieFavorite = false;
                                                  });
                                                }
                                              } else {
                                                final error = await addFavorite(
                                                    accountId,
                                                    sessionData,
                                                    movieId);
                                                if (error != null &&
                                                    context.mounted) {
                                                  showErrorDialog(
                                                      'Error', error, context);
                                                } else {
                                                  setState(() {
                                                    isMovieFavorite = true;
                                                  });
                                                }
                                              }
                                            },
                                            child: Icon(
                                              isMovieFavorite == null
                                                  ? Icons.favorite_border
                                                  : isMovieFavorite!
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // logged in and rated
                                      if (isUserLoggedIn == true &&
                                          isMovieRated != false &&
                                          userRating != null)
                                        Container(
                                          margin: const EdgeInsets.all(10),
                                          padding: const EdgeInsets.all(10),
                                          decoration: const BoxDecoration(
                                              color: Colors.black38,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30))),
                                          child: GestureDetector(
                                            onTap: () => showModalBottomSheet(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: RatingBar.builder(
                                                        initialRating:
                                                            userRating ?? 0,
                                                        minRating: 1,
                                                        maxRating: 10,
                                                        itemSize: 35,
                                                        unratedColor:
                                                            Colors.grey,
                                                        direction:
                                                            Axis.horizontal,
                                                        allowHalfRating: true,
                                                        itemCount: 10,
                                                        itemPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 0),
                                                        itemBuilder:
                                                            (context, _) =>
                                                                const Icon(
                                                          Icons.star,
                                                          color: Colors.amber,
                                                        ),
                                                        onRatingUpdate:
                                                            (rating) async {
                                                          if (!mounted) return;
                                                          final movieId =
                                                              widget.movieId;
                                                          final openbox =
                                                              await Hive.openBox(
                                                                  'sessionBox');

                                                          final String
                                                              sessionData =
                                                              openbox.get(
                                                                  'sessionData');
                                                          final error =
                                                              await addRating(
                                                                  sessionData,
                                                                  movieId,
                                                                  rating);
                                                          if (error != null &&
                                                              context.mounted) {
                                                            showErrorDialog(
                                                                'Error',
                                                                error,
                                                                context);
                                                          } else {
                                                            setState(() {
                                                              isMovieRated !=
                                                                  false;
                                                              userRating =
                                                                  rating;
                                                            });
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                    const CustomDivider(),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        if (!context.mounted) {
                                                          return;
                                                        }
                                                        final openbox =
                                                            await Hive.openBox(
                                                                'sessionBox');

                                                        final String
                                                            sessionData =
                                                            openbox.get(
                                                                'sessionData');
                                                        final error =
                                                            await removeRating(
                                                                sessionData,
                                                                widget.movieId);
                                                        if (!context.mounted) {
                                                          return;
                                                        }
                                                        if (error != null) {
                                                          showErrorDialog(
                                                              'Error',
                                                              error,
                                                              context);
                                                        } else {
                                                          Navigator.of(context)
                                                              .pop();
                                                          setState(() {
                                                            isMovieRated =
                                                                false;
                                                            userRating = null;
                                                          });
                                                        }
                                                      },
                                                      child: const Text(
                                                        ' 🗑️ Delete Rating',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                            child: Text(
                                              '👤 ${userRating?.toStringAsFixed(1)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 13,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      //logged in not rated
                                      if (isUserLoggedIn == true &&
                                          isMovieRated == false &&
                                          userRating == null)
                                        IconButton(
                                            onPressed: () {
                                              showModalBottomSheet(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      RatingBar.builder(
                                                        initialRating: 5,
                                                        minRating: 1,
                                                        maxRating: 10,
                                                        itemSize: 35,
                                                        unratedColor:
                                                            Colors.grey,
                                                        direction:
                                                            Axis.horizontal,
                                                        allowHalfRating: true,
                                                        itemCount: 10,
                                                        itemPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 0),
                                                        itemBuilder:
                                                            (context, _) =>
                                                                const Icon(
                                                          Icons.star,
                                                          color: Colors.amber,
                                                        ),
                                                        onRatingUpdate:
                                                            (rating) async {
                                                          if (!mounted) return;
                                                          final movieId =
                                                              widget.movieId;
                                                          final openbox =
                                                              await Hive.openBox(
                                                                  'sessionBox');

                                                          final String
                                                              sessionData =
                                                              openbox.get(
                                                                  'sessionData');
                                                          final error =
                                                              await addRating(
                                                                  sessionData,
                                                                  movieId,
                                                                  rating);
                                                          if (error != null &&
                                                              context.mounted) {
                                                            showErrorDialog(
                                                                'Error',
                                                                error,
                                                                context);
                                                          } else {
                                                            setState(() {
                                                              isMovieRated =
                                                                  '"value":$rating';
                                                              userRating =
                                                                  rating;
                                                            });
                                                          }
                                                        },
                                                      ),
                                                      const SizedBox(
                                                        height: 40,
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.add_reaction,
                                              color: Colors.white,
                                            )),
                                      Container(
                                        margin: const EdgeInsets.all(5),
                                        padding: const EdgeInsets.all(10),
                                        decoration: const BoxDecoration(
                                            color: Colors.black38,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30))),
                                        child: Text(
                                          '⭐ ${score?.toStringAsFixed(1)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: imdbRating != null &&
                                            imdbRating!.isNotEmpty,
                                        child: Container(
                                          margin: const EdgeInsets.all(5),
                                          padding: const EdgeInsets.all(10),
                                          decoration: const BoxDecoration(
                                              color: Colors.black38,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30))),
                                          child: Text(
                                            'IMDB⭐ $imdbRating',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 13,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: rottenTomatoesRating != 'N/A',
                                        child: Container(
                                          margin: const EdgeInsets.all(5),
                                          padding: const EdgeInsets.all(10),
                                          decoration: const BoxDecoration(
                                              color: Colors.black38,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30))),
                                          child: Text(
                                            'Rotten Tomatoes🍅 $rottenTomatoesRating',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 13,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),

                                      Center(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: (genres as List<dynamic>)
                                                .map<Widget>((genre) {
                                              return Text(
                                                genre['name'] + ' | ',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w200),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        25, 10, 25, 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: FutureBuilder(
                                              future: checkAvailability(
                                                  widget.movieId, region),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  // Display loading indicator while fetching data
                                                  return const SizedBox();
                                                } else if (snapshot.hasError) {
                                                  // Display error message if fetching data fails
                                                  return const Text(
                                                      'Error loading data');
                                                } else {
                                                  // Display check mark if results are not empty
                                                  return snapshot.data == true
                                                      ? SizedBox(
                                                          width: 400,
                                                          child:
                                                              FloatingActionButton(
                                                            backgroundColor:
                                                                getMovieColor(
                                                                    context,
                                                                    widget
                                                                        .movieId),
                                                            onPressed: () =>
                                                                showWatchOptions(
                                                                    context,
                                                                    widget
                                                                        .movieId,
                                                                    widget
                                                                        .movieTitle,
                                                                    releaseDate ??
                                                                        '',
                                                                    imdbId ??
                                                                        ''),
                                                            child: Text('Watch',
                                                                style: getMovieButtonTextStyle(
                                                                    widget
                                                                        .movieId)),
                                                          ))
                                                      : const SizedBox();
                                                }
                                              }),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        25, 10, 25, 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                            child: SizedBox(
                                          width: 400,
                                          child: FloatingActionButton(
                                            backgroundColor: getMovieColor(
                                                context, widget.movieId),
                                            onPressed: () => showTorrentOptions(
                                                context,
                                                widget.movieId,
                                                widget.movieTitle,
                                                releaseDate,
                                                imdbId),
                                            child: Text(
                                              'Torrent Search',
                                              style: getMovieButtonTextStyle(
                                                  widget.movieId),
                                            ),
                                          ),
                                        ))
                                      ],
                                    ),
                                  ),
                                  const CustomDivider(),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                    child: Container(
                                        width: 600,
                                        alignment: Alignment.center,
                                        child: Text(
                                          about!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w300,
                                          ),
                                          textAlign: TextAlign.justify,
                                        )),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: 110,
                                          child: Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                5, 5, 5, 5),
                                            margin: const EdgeInsets.fromLTRB(
                                                5, 5, 5, 5),
                                            decoration: BoxDecoration(
                                              color: getMovieBackgroundColor(
                                                  context, widget.movieId),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              children: [
                                                const Text(
                                                  'Duration',
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w200,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    "${hours}H ${minutes}M",
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 110,
                                          child: Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                5, 5, 5, 5),
                                            margin: const EdgeInsets.fromLTRB(
                                                5, 5, 5, 5),
                                            decoration: BoxDecoration(
                                              color: getMovieBackgroundColor(
                                                  context, widget.movieId),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              children: [
                                                const Text(
                                                  'Year',
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w200,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    year,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 110,
                                          child: Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                5, 5, 5, 5),
                                            margin: const EdgeInsets.fromLTRB(
                                                5, 5, 5, 5),
                                            decoration: BoxDecoration(
                                              color: getMovieBackgroundColor(
                                                  context, widget.movieId),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              children: [
                                                const Text(
                                                  'Language',
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w200,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    language != null
                                                        ? language!
                                                            .toUpperCase()
                                                        : 'N/A',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    FutureBuilder(
                      future: fetchCredits(widget.movieId, region),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Text(
                              'Error loading cast and crew details');
                        } else {
                          final Map<String, List<Map<String, dynamic>>> data =
                              snapshot.data
                                  as Map<String, List<Map<String, dynamic>>>;
                          final List<Map<String, dynamic>> castList =
                              data['cast'] ?? [];
                          final List<Map<String, dynamic>> crewList =
                              data['crew'] ?? [];

                          return Column(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(25, 10, 0, 0),
                                    child: Text(
                                      'Cast',
                                      textAlign: TextAlign.justify,
                                      style: getMovieTitleTextStyle(
                                          widget.movieId),
                                    ),
                                  )
                                ],
                              ),
                              const CustomDivider(),
                              buildCastRowDesktop(castList, context),
                              Row(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(25, 10, 0, 0),
                                    child: Text(
                                      'Crew',
                                      textAlign: TextAlign.justify,
                                      style: getMovieTitleTextStyle(
                                          widget.movieId),
                                    ),
                                  ),
                                ],
                              ),
                              const CustomDivider(),
                              buildCrewRowDesktop(crewList, context)
                            ],
                          );
                        }
                      },
                    ),
                    const CustomDivider(),
                    FutureBuilder(
                      future: fetchCredits(widget.movieId, region),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Text(
                              'Error loading cast and crew details');
                        } else {
                          final Map<String, List<Map<String, dynamic>>> data =
                              snapshot.data
                                  as Map<String, List<Map<String, dynamic>>>;

                          final List<Map<String, dynamic>> crewList =
                              data['crew'] ?? [];

                          Map<String, dynamic>? director;

                          for (var crewMember in crewList) {
                            if (crewMember['job'] == 'Director') {
                              director = crewMember;
                              break;
                            }
                          }

                          if (director != null) {
                            return Column(
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(25, 10, 0, 0),
                                    child: Text("Movies by ${director['name']}",
                                        style: getMovieTitleTextStyle(
                                            widget.movieId)),
                                  ),
                                ),
                                FutureBuilder(
                                  future: fetchOtherMoviesByDirector(
                                      director['id'], region),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return const Text(
                                          'Error loading other movies');
                                    } else {
                                      List<dynamic> movies =
                                          snapshot.data as List<dynamic>;

                                      return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: movies.map((movie) {
                                            return Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: [
                                                    Card(
                                                      elevation: 4,
                                                      child: GestureDetector(
                                                        onTap: () => Platform
                                                                    .isAndroid ||
                                                                Platform.isIOS
                                                            ? onTapMovie(
                                                                movie['title'],
                                                                movie['id'])
                                                            : onTapMovieDesktop(
                                                                movie['title'],
                                                                movie['id'],
                                                                context),
                                                        child: Container(
                                                          height: 300,
                                                          width: 200,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            image: movie[
                                                                        'poster_path']
                                                                    .isNotEmpty
                                                                ? DecorationImage(
                                                                    image:
                                                                        CachedNetworkImageProvider(
                                                                      '${getImageBaseUrl(region)}/t/p/w200${movie['poster_path']}',
                                                                    ),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  )
                                                                : null, // No image if there's no poster path
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 140,
                                                      child: Text(
                                                        movie['title'],
                                                        textAlign:
                                                            TextAlign.center,
                                                        maxLines: 2,
                                                        softWrap: true,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ));
                                          }).toList(),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            );
                          } else {
                            return const SizedBox();
                          }
                        }
                      },
                    ),
                    const CustomDivider(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Container(
                        alignment: Alignment.center,
                        child: ExpansionTile(
                          collapsedIconColor: Theme.of(context).primaryColor,
                          title: Text('Other Info',
                              style: getMovieTitleTextStyle(widget.movieId)),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(25, 10, 0, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      budget != null && budget != 0
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Budget',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                ),
                                                Text(
                                                  '\$${NumberFormat("#,##0").format(budget)}',
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            )
                                          : Container(),
                                      const CustomDivider(),
                                      revenue != null && revenue != 0
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Revenue',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                ),
                                                Text(
                                                  '\$${NumberFormat("#,##0").format(revenue)}',
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            )
                                          : Container(),
                                      const CustomDivider(),
                                      Text(
                                        'Production Countries',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: (productionCountries
                                                as List<dynamic>)
                                            .map<Widget>((productionCountry) {
                                          return Text(
                                            productionCountry['name'],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w200,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      const CustomDivider(),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Production Companies',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: (productionCompanies
                                                    as List<dynamic>)
                                                .map<Widget>(
                                                    (productionCompany) {
                                              return Text(
                                                productionCompany['name'],
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w200,
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                      const CustomDivider(),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Spoken Languages',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: (spokenLanguages
                                                    as List<dynamic>)
                                                .map<Widget>((spokenLanguage) {
                                              return Text(
                                                spokenLanguage['name'],
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w200,
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const BottomBar(),
    );
  }
}
