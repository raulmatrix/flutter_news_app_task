
import 'package:flutter/material.dart';
import 'package:flutter_news_apps/models/news_models.dart';
import 'package:http/http.dart' as http;

final _URL_NEWS = 'https://newsapi.org/v2';
final _APIKEY = 'b10391596932442a87086436bb857ebc';

class NewsServices with ChangeNotifier{

  List<Article> headlines = [];

  NewsServices() {
    getTopHeadlines();
  }
  
  Future<void> getTopHeadlines() async {
    final url = Uri.parse('$_URL_NEWS/top-headlines?country=us&apiKey=$_APIKEY');
    try {
      final resp = await http.get(url);

      if (resp.statusCode == 200) {
        final newResponse = reqResListadoFromJson(resp.body);
        headlines.addAll(newResponse.articles);
        notifyListeners();
      } else {
        debugPrint('Error al cargar las noticias ${resp.statusCode}');
      }

    } catch (e) {
      debugPrint('Excepcion al cargar las noticias $e');
    }
  }
}