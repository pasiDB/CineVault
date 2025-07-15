import 'package:mirarr/moviesPage/movie_detail_page_desktop.dart';
import 'package:flutter/material.dart';

void onTapMovieDesktop(String movieTitle, int movieId, BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          MovieDetailPageDesktop(movieTitle: movieTitle, movieId: movieId),
    ),
  );
}
