import 'dart:io';
import 'dart:ui';

import 'package:mirarr/moviesPage/UI/custom_movie_widget.dart';
import 'package:mirarr/moviesPage/functions/on_tap_movie.dart';
import 'package:mirarr/moviesPage/functions/on_tap_movie_desktop.dart';
import 'package:flutter/material.dart';

class ListGridViewMovies extends StatefulWidget {
  final List movieList;

  const ListGridViewMovies({Key? key, required this.movieList})
      : super(key: key);

  @override
  ListGridViewMoviesState createState() => ListGridViewMoviesState();
}

class ListGridViewMoviesState extends State<ListGridViewMovies> {
  @override
  Widget build(BuildContext context) {
    int crossAxisCount = Platform.isAndroid || Platform.isIOS ? 2 : 4;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Movie List'),
      ),
      body: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
          },
        ),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.7,
          ),
          itemCount: widget.movieList.length,
          itemBuilder: (context, index) {
            final movie = widget.movieList[index];
            return GestureDetector(
              onTap: () => Platform.isAndroid || Platform.isIOS
                  ? onTapMovie(movie.title, movie.id, context)
                  : onTapMovieDesktop(movie.title, movie.id, context),
              child: CustomMovieWidget(movie: movie),
            );
          },
        ),
      ),
    );
  }
}
