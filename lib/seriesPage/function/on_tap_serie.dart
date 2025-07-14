import 'package:Mirarr/seriesPage/serie_detail_page.dart';
import 'package:flutter/material.dart';

void onTapSerie(String serieName, int serieId, BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          SerieDetailPage(serieName: serieName, serieId: serieId),
    ),
  );
}
