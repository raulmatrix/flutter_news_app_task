import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_news_apps/services/new_services.dart';

class CategoryArticle {
  final String title;
  final String? description;
  final String? imageUrl;
  final DateTime? publishedAt;

  CategoryArticle({
    required this.title,
    this.description,
    this.imageUrl,
    this.publishedAt,
  });
}

class CategoryRepositoryAdapter {
  /// Carga noticias por categoría utilizando el NewsServices del proyecto.
  /// Soporta varias firmas comunes sin que tengas que cambiar tu servicio.
  static Future<List<CategoryArticle>> fetchByCategory(
      BuildContext context,
      String categoryKey,
      ) async {
    final svc = context.read<NewsServices>() as dynamic;

    // 1) Intento directo: método tipo getTopHeadlinesByCategory(category)
    try {
      final result = await svc.getTopHeadlinesByCategory(categoryKey);
      final list = _tryAsList(result) ?? <dynamic>[];
      return _mapArticles(list);
    } catch (_) {
      // sigue intentando
    }

    // 2) Intento: fetchByCategory(category) que llena un mapa interno
    try {
      await svc.fetchByCategory(categoryKey);
      final list = _extractFromCommonStores(svc, categoryKey);
      if (list != null) return _mapArticles(list);
    } catch (_) {
      // sigue intentando
    }

    // 3) Intento: getArticlesByCategory(category) que devuelve la lista
    try {
      final result = await svc.getArticlesByCategory(categoryKey);
      final list = _tryAsList(result) ?? <dynamic>[];
      return _mapArticles(list);
    } catch (_) {
      // sigue intentando
    }

    // 4) Lectura directa de un Map<String, List> categoryArticles
    try {
      final map = svc.categoryArticles as Map?;
      if (map != null && map[categoryKey] is List) {
        return _mapArticles(map[categoryKey] as List);
      }
    } catch (_) {
      // sigue intentando
    }

    // 5) Lectura directa de un Map<String, List> articlesByCategory
    try {
      final map = svc.articlesByCategory as Map?;
      if (map != null && map[categoryKey] is List) {
        return _mapArticles(map[categoryKey] as List);
      }
    } catch (_) {
      // nada
    }

    // Fallback para no romper la UI si nada coincide.
    if (kDebugMode) {
      debugPrint('⚠️ CategoryRepositoryAdapter: no se pudo enlazar a NewsServices; mostrando demo.');
    }
    await Future.delayed(const Duration(milliseconds: 400));
    return <CategoryArticle>[
      CategoryArticle(
        title: 'Demo $categoryKey: integra tu NewsServices',
        description: 'Edita NewsServices o agrega un método por categoría.',
        imageUrl: null,
        publishedAt: DateTime.now(),
      ),
    ];
  }

  static List<CategoryArticle> _mapArticles(List list) {
    return list.map<CategoryArticle>((item) {
      final d = item as dynamic;
      // Campos típicos en modelos de noticia
      final title = _asString(d.title) ?? _asString(d.name) ?? 'Sin título';
      final desc  = _asString(d.description) ?? _asString(d.summary);
      final img   = _asString(d.urlToImage) ?? _asString(d.image) ?? _asString(d.thumbnail);
      final date  = _asDate(d.publishedAt) ?? _asDate(d.date);

      return CategoryArticle(
        title: title,
        description: desc,
        imageUrl: img,
        publishedAt: date,
      );
    }).toList();
  }

  static List<dynamic>? _tryAsList(dynamic v) {
    if (v is List) return v;
    // Algunos servicios devuelven envoltorios tipo { articles: [...] }
    try {
      final map = v as Map;
      final a = map['articles'];
      if (a is List) return a;
    } catch (_) {}
    return null;
  }

  static List<dynamic>? _extractFromCommonStores(dynamic svc, String key) {
    try {
      final map = svc.categoryArticles as Map?;
      if (map != null && map[key] is List) return map[key] as List;
    } catch (_) {}
    try {
      final map = svc.articlesByCategory as Map?;
      if (map != null && map[key] is List) return map[key] as List;
    } catch (_) {}
    return null;
  }

  static String? _asString(dynamic v) => v == null ? null : v.toString();

  static DateTime? _asDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      return null;
    }
  }
}
