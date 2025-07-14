import 'package:Mirarr/seriesPage/serie_detail_page_desktop.dart';
import 'package:flutter/material.dart';

void onTapSerieDesktop(String serieName, int serieId, BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          SerieDetailPageDesktop(serieName: serieName, serieId: serieId),
    ),
  );
}
