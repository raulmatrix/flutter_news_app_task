import 'package:flutter/material.dart';
import 'package:flutter_news_apps/pages/news_category_page.dart';

class HomeWithBottomNav extends StatefulWidget {
  const HomeWithBottomNav({super.key});

  @override
  State<HomeWithBottomNav> createState() => _HomeWithBottomNavState();
}

class _HomeWithBottomNavState extends State<HomeWithBottomNav> {
  int _index = 0;

  // Cambia/añade categorías aquí si deseas
  final _pages = const <Widget>[
    NewsCategoryPage(title: 'Tecnología', categoryKey: 'technology'),
    NewsCategoryPage(title: 'Deportes', categoryKey: 'sports'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.science_outlined),
            label: 'Tecnología',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_soccer_outlined),
            label: 'Deportes',
          ),
        ],
      ),
    );
  }
}
