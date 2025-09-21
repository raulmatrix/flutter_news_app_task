import 'package:flutter/material.dart';
import 'pages/news_category_page.dart';

class HomeWithTabs extends StatelessWidget {
  const HomeWithTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // dos categorías nuevas
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter News App'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.science_outlined), text: 'Tecnología'),
              Tab(icon: Icon(Icons.sports_soccer_outlined), text: 'Deportes'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            NewsCategoryPage(title: 'Tecnología', categoryKey: 'technology'),
            NewsCategoryPage(title: 'Deportes', categoryKey: 'sports'),
          ],
        ),
      ),
    );
  }
}
