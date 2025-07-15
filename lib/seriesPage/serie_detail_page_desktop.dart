// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:ui';

import 'package:mirarr/functions/fetchers/fetch_serie_details.dart';
import 'package:mirarr/functions/fetchers/fetch_series_credits.dart';
import 'package:mirarr/functions/get_base_url.dart';
import 'package:mirarr/functions/regionprovider_class.dart';
import 'package:mirarr/seriesPage/UI/seasons_details.dart';
import 'package:mirarr/seriesPage/checkers/custom_tmdb_ids_effects_series.dart';
import 'package:mirarr/seriesPage/function/get_imdb_rating_series.dart';
import 'package:mirarr/seriesPage/function/series_tmdb_actions.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mirarr/moviesPage/UI/cast_crew_row.dart';
import 'package:mirarr/widgets/bottom_bar.dart';
import 'package:mirarr/widgets/custom_divider.dart';
import 'package:provider/provider.dart';
import 'package:mirarr/functions/show_error_dialog.dart';

class SerieDetailPageDesktop extends StatefulWidget {
  final String serieName;
  final int serieId;

  const SerieDetailPageDesktop(
      {super.key, required this.serieName, required this.serieId});

  @override
  SerieDetailPageDesktopState createState() => SerieDetailPageDesktopState();
}

class SerieDetailPageDesktopState extends State<SerieDetailPageDesktop> {
  final apiKey = dotenv.env['TMDB_API_KEY'];
  Map<String, dynamic>? serieDetails;
  Map<String, dynamic>? externalIds;

  Map<String, dynamic>? serieInfo;
  bool? isSerieWatchlist;
  bool? isSerieFavorite;
  bool isUserLoggedIn = false;
  dynamic isSerieRated;
  double? userRating;
  double? userScore;
  String? posterPath;
  double? popularity;
  int? budget;
  List<dynamic>? genres;
  String? backdrops;
  double? score;
  String? about;
  int? duration;
  String? releaseDate;
  String? language;
  int? seasons;
  int? episodes;
  String? imdbId;
  String? imdbRating;

  String rottenTomatoesRating = 'N/A';

  @override
  void initState() {
    super.initState();
    checkUserLogin();

    checkAccountState();
    _fetchSerieDetails();
    final region =
        Provider.of<RegionProvider>(context, listen: false).currentRegion;
    fetchCredits(widget.serieId, region);
    fetchExternalId();
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
        '${baseUrl}tv/${widget.serieId}/account_states?api_key=$apiKey&session_id=$sessionId',
      ),
    );
    if (!mounted) return;
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      setState(() {
        isSerieWatchlist = responseData['watchlist'];
        isSerieFavorite = responseData['favorite'];
        isSerieRated = responseData['rated'];
        if (isSerieRated != false) {
          userRating = responseData['rated']['value'];
        }
      });
    }
  }

  Future<void> _fetchSerieDetails() async {
    try {
      final region =
          Provider.of<RegionProvider>(context, listen: false).currentRegion;
      final responseData = await fetchSerieDetails(widget.serieId, region);
      if (!mounted) return;
      setState(() {
        serieDetails = responseData;
        budget = responseData['budget'];
        genres = responseData['genres'];
        backdrops = responseData['backdrop_path'];
        score = responseData['vote_average'];
        about = responseData['overview'];
        duration = responseData['runtime'];
        posterPath = responseData['poster_path'];
        releaseDate = responseData['release_date'];
        language = responseData['original_language'];
        seasons = responseData['number_of_seasons'];
        episodes = responseData['number_of_episodes'];
      });
    } catch (e) {
      throw Exception('Failed to load serie details');
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

  Future<void> fetchExternalId() async {
    try {
      final region =
          Provider.of<RegionProvider>(context, listen: false).currentRegion;
      final baseUrl = getBaseUrl(region);
      final response = await http.get(
        Uri.parse(
            '${baseUrl}tv/${widget.serieId}/external_ids?api_key=$apiKey'),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          externalIds = responseData;
          imdbId = responseData['imdb_id'];
        });
        if (imdbId != null) {
          await getSerieRatings(
              imdbId, updateImdbRating, updateRottenTomatoesRating);
          if (!mounted) return;
        }
      } else {
        throw Exception('Failed to load serie details');
      }
    } catch (e) {
      throw Exception('Failed to load external Id');
    }
  }

  @override
  Widget build(BuildContext context) {
    final region =
        Provider.of<RegionProvider>(context, listen: false).currentRegion;
    return Scaffold(
      appBar: Platform.isLinux || Platform.isWindows || Platform.isMacOS
          ? AppBar(
              toolbarHeight: 40,
              backgroundColor: Theme.of(context).primaryColor,
              iconTheme: const IconThemeData(color: Colors.black),
              actions: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                  child: Text(
                    widget.serieName,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            )
          : null,
      body: serieDetails == null
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
                              '${getImageBaseUrl(region)}/t/p/original$backdrops',
                            ),
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
                                    '${getImageBaseUrl(region)}/t/p/original$posterPath',
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
                                    child: Text(widget.serieName,
                                        style: getSeriesTitleTextStyle(
                                            widget.serieId)),
                                  ),
                                  Row(
                                    children: [
                                      // IconButton(
                                      //   onPressed: () {
                                      //     _castImagesFuture.then((imageUrls) {
                                      //       _openImageGallery(imageUrls);
                                      //     });
                                      //   },
                                      //   icon: const Icon(
                                      //     Icons.image_rounded,
                                      //     color: Colors.white,
                                      //   ),
                                      // ),
                                      Visibility(
                                        visible: isUserLoggedIn == true,
                                        child: GestureDetector(
                                          onTap: () async {
                                            if (!mounted) return;
                                            if (isSerieWatchlist == null) {
                                              return;
                                            }
                                            final serieId = widget.serieId;
                                            final openbox = await Hive.openBox(
                                                'sessionBox');
                                            final String accountId =
                                                openbox.get('accountId');
                                            final String sessionData =
                                                openbox.get('sessionData');
                                            if (isSerieWatchlist!) {
                                              final error =
                                                  await removeFromWatchList(
                                                      accountId,
                                                      sessionData,
                                                      serieId);
                                              if (error != null &&
                                                  context.mounted) {
                                                showErrorDialog(
                                                    'Error', error, context);
                                              } else {
                                                setState(() {
                                                  isSerieWatchlist = false;
                                                });
                                              }
                                            } else {
                                              final error = await addWatchList(
                                                  accountId,
                                                  sessionData,
                                                  serieId);
                                              if (error != null &&
                                                  context.mounted) {
                                                showErrorDialog(
                                                    'Error', error, context);
                                              } else {
                                                setState(() {
                                                  isSerieWatchlist = true;
                                                });
                                              }
                                            }
                                          },
                                          child: Icon(
                                            isSerieWatchlist == null
                                                ? Icons.bookmark_border
                                                : isSerieWatchlist!
                                                    ? Icons.bookmark
                                                    : Icons.bookmark_border,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: isUserLoggedIn == true,
                                        child: GestureDetector(
                                          onTap: () async {
                                            if (!mounted) return;
                                            if (isSerieFavorite == null) {
                                              return;
                                            }
                                            final serieId = widget.serieId;
                                            final openbox = await Hive.openBox(
                                                'sessionBox');
                                            final String accountId =
                                                openbox.get('accountId');
                                            final String sessionData =
                                                openbox.get('sessionData');
                                            if (isSerieFavorite!) {
                                              final error =
                                                  await removeFromFavorite(
                                                      accountId,
                                                      sessionData,
                                                      serieId);
                                              if (error != null &&
                                                  context.mounted) {
                                                showErrorDialog(
                                                    'Error', error, context);
                                              } else {
                                                setState(() {
                                                  isSerieFavorite = false;
                                                });
                                              }
                                            } else {
                                              final error = await addFavorite(
                                                  accountId,
                                                  sessionData,
                                                  serieId);
                                              if (error != null &&
                                                  context.mounted) {
                                                showErrorDialog(
                                                    'Error', error, context);
                                              } else {
                                                setState(() {
                                                  isSerieFavorite = true;
                                                });
                                              }
                                            }
                                          },
                                          child: Icon(
                                            isSerieFavorite == null
                                                ? Icons.favorite_border
                                                : isSerieFavorite!
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                      // logged in and rated
                                      if (isUserLoggedIn == true &&
                                          isSerieRated != false &&
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
                                                          final serieId =
                                                              widget.serieId;
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
                                                                  serieId,
                                                                  rating);
                                                          if (error != null &&
                                                              context.mounted) {
                                                            showErrorDialog(
                                                                'Error',
                                                                error,
                                                                context);
                                                          } else {
                                                            setState(() {
                                                              isSerieRated !=
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
                                                        if (!mounted) return;
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
                                                                widget.serieId);
                                                        if (error != null &&
                                                            context.mounted) {
                                                          showErrorDialog(
                                                              'Error',
                                                              error,
                                                              context);
                                                        } else {
                                                          if (!mounted) return;
                                                          Navigator.of(context)
                                                              .pop();
                                                          setState(() {
                                                            isSerieRated =
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
                                          isSerieRated == false &&
                                          userRating == null)
                                        Container(
                                            decoration: const BoxDecoration(
                                                color: Colors.black38,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30))),
                                            child: IconButton(
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
                                                            allowHalfRating:
                                                                true,
                                                            itemCount: 10,
                                                            itemPadding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        0),
                                                            itemBuilder:
                                                                (context, _) =>
                                                                    const Icon(
                                                              Icons.star,
                                                              color:
                                                                  Colors.amber,
                                                            ),
                                                            onRatingUpdate:
                                                                (rating) async {
                                                              if (!mounted) {
                                                                return;
                                                              }
                                                              final serieId =
                                                                  widget
                                                                      .serieId;
                                                              final openbox =
                                                                  await Hive
                                                                      .openBox(
                                                                          'sessionBox');

                                                              final String
                                                                  sessionData =
                                                                  openbox.get(
                                                                      'sessionData');
                                                              final error =
                                                                  await addRating(
                                                                      sessionData,
                                                                      serieId,
                                                                      rating);
                                                              if (error !=
                                                                      null &&
                                                                  context
                                                                      .mounted) {
                                                                showErrorDialog(
                                                                    'Error',
                                                                    error,
                                                                    context);
                                                              } else {
                                                                setState(() {
                                                                  isSerieRated =
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
                                                ))),
                                      Container(
                                        margin: const EdgeInsets.all(10),
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
                                        25, 10, 25, 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                            child: SizedBox(
                                          width: 400,
                                          child: FloatingActionButton(
                                            backgroundColor: getSeriesColor(
                                                context, widget.serieId),
                                            onPressed: () => seasonsAndEpisodes(
                                                context,
                                                widget.serieId,
                                                widget.serieName,
                                                imdbId!),
                                            child: Text('Details',
                                                style: getSeriesButtonTextStyle(
                                                    widget.serieId)),
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
                                          textAlign: TextAlign.left,
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
                                              color: getSeriesBackgroundColor(
                                                  context, widget.serieId),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              children: [
                                                const Text(
                                                  'Seasons',
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
                                                    '$seasons',
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
                                              color: getSeriesBackgroundColor(
                                                  context, widget.serieId),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              children: [
                                                const Text(
                                                  'Episodes',
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
                                                    '$episodes',
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
                                              color: getSeriesBackgroundColor(
                                                  context, widget.serieId),
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
                      future: fetchCredits(widget.serieId, region),
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
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: Platform.isAndroid ||
                                                  Platform.isIOS
                                              ? 18
                                              : 30,
                                          fontWeight: FontWeight.w700),
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
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: Platform.isAndroid ||
                                                  Platform.isIOS
                                              ? 18
                                              : 30,
                                          fontWeight: FontWeight.w700),
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
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const BottomBar(),
    );
  }
}
