import 'package:flutter/material.dart';
import 'package:flutter_news_apps/models/news_models.dart';
import 'package:http/http.dart' as http;

const _URL_NEWS = 'https://newsapi.org/v2';
const _APIKEY   = 'b10391596932442a87086436bb857ebc';

class NewsServices with ChangeNotifier {

  // =======================
  // Titulares generales
  // =======================
  final List<Article> headlines = [];

  // =======================
  // Soporte por CATEGORÍAS
  // =======================
  bool isLoading = false;

  /// Categoría seleccionada (opcional, útil si luego quieres tabs con estado compartido)
  String selectedCategory = 'technology';

  /// Cache en memoria por categoría.
  /// Agrega aquí las categorías que usarás en tu app.
  final Map<String, List<Article>> categoryArticles = {
    'technology': <Article>[],
    'sports'    : <Article>[],
    // 'business'  : <Article>[],
    // 'science'   : <Article>[],
    // 'entertainment': <Article>[],
    // 'health'    : <Article>[],
  };

  /// Acceso rápido a la lista de la categoría seleccionada
  List<Article> get getArticlesCategorySelected =>
      categoryArticles[selectedCategory] ?? const <Article>[];

  NewsServices() {
    getTopHeadlines();
    // Precarga opcional de la categoría por defecto
    // getArticlesByCategory(selectedCategory);
  }

  // =======================
  // Top Headlines (general)
  // =======================
  Future<void> getTopHeadlines() async {
    final url = Uri.parse('$_URL_NEWS/top-headlines?country=us&apiKey=$_APIKEY');

    try {
      final resp = await http.get(url);

      if (resp.statusCode == 200) {
        final parsed = reqResListadoFromJson(resp.body);
        headlines.addAll(parsed.articles);
        notifyListeners();
      } else {
        debugPrint('Error al cargar headlines: ${resp.statusCode}');
      }
    } catch (e) {
      debugPrint('Excepción en getTopHeadlines: $e');
    }
  }

  // ==================================
  // Headlines por CATEGORÍA (requerido)
  // ==================================
  Future<void> getArticlesByCategory(String category) async {
    final key = category.toLowerCase().trim();

    // Si no existía la clave en el mapa, la creamos
    categoryArticles.putIfAbsent(key, () => <Article>[]);

    // Si ya tenemos datos en cache, no volvemos a pedir (puedes quitar esto si quieres refrescar siempre)
    if (categoryArticles[key]!.isNotEmpty) return;

    isLoading = true;
    notifyListeners();

    final url = Uri.parse(
      '$_URL_NEWS/top-headlines?country=us&category=$key&apiKey=$_APIKEY',
    );

    try {
      final resp = await http.get(url);

      if (resp.statusCode == 200) {
        final parsed = reqResListadoFromJson(resp.body);
        categoryArticles[key] = parsed.articles;
      } else {
        debugPrint('Error al cargar categoría "$key": ${resp.statusCode}');
        categoryArticles[key] = <Article>[];
      }
    } catch (e) {
      debugPrint('Excepción en getArticlesByCategory("$key"): $e');
      categoryArticles[key] = <Article>[];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Alias por compatibilidad con otras pantallas que llamen `fetchByCategory`.
  Future<void> fetchByCategory(String category) => getArticlesByCategory(category);

  /// (Opcional) Cambiar la categoría seleccionada y cargar si es necesario
  set setSelectedCategory(String category) {
    selectedCategory = category.toLowerCase().trim();
    getArticlesByCategory(selectedCategory);
    notifyListeners();
  }
}
