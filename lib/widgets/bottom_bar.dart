import 'package:mirarr/widgets/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:mirarr/moviesPage/main_page.dart';
import 'package:mirarr/seriesPage/series_page.dart';
import 'package:mirarr/widgets/login.dart';
import 'package:mirarr/widgets/profile.dart';
import 'package:hive/hive.dart';
import 'package:mirarr/widgets/rss_screen.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  BottomBarState createState() => BottomBarState();
}

int _selectedIndex = 0;

class BottomBarState extends State<BottomBar> {
  void toSeries() {
    setState(() {
      _selectedIndex = 1;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SerieSearchScreen()),
      );
    });
  }

  void toMovies() {
    setState(() {
      _selectedIndex = 0;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MovieSearchScreen()),
      );
    });
  }

  void toRSS() {
    setState(() {
      _selectedIndex = 3;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RssScreen()),
      );
    });
  }

  void toSearch() {
    setState(() {
      _selectedIndex = 2;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SearchScreen()),
      );
    });
  }

  void toAccount() async {
    final box = await Hive.openBox('sessionBox');
    final sessionData = box.get('sessionData');
    setState(() {
      _selectedIndex = 4;
      if (sessionData != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Theme.of(context).highlightColor,
      selectedIconTheme: IconThemeData(color: Theme.of(context).highlightColor),
      selectedFontSize: 16,
      unselectedItemColor: Theme.of(context).primaryColor,
      currentIndex: _selectedIndex,
      onTap: (int index) {
        if (_selectedIndex != index) {
          if (index == 0) {
            toMovies();
          } else if (index == 1) {
            toSeries();
          } else if (index == 4) {
            toAccount();
          } else if (index == 3) {
            toRSS();
          } else if (index == 2) {
            toSearch();
          }
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.movie,
          ),
          label: 'Movies',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.local_movies,
          ),
          label: 'Series',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.search,
          ),
          label: 'Search',
        ),
      ],
    );
  }
}
