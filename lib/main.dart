import 'package:flutter/material.dart';
import 'package:flutter_news_apps/services/new_services.dart';
import 'package:flutter_news_apps/theme/tema.dart';
import 'package:flutter_news_apps/home_bottom_nav.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NewsServices()),
      ],
      child: MaterialApp(
        title: 'Flutter News App',
        theme: miTema,
        debugShowCheckedModeBanner: false,
        home: const HomeWithBottomNav(), // ⬅️ bottom nav
      ),
    );
  }
}
