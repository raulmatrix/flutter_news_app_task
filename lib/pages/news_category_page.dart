import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_news_apps/services/new_services.dart';

class NewsCategoryPage extends StatefulWidget {
  final String title;       // visible: "Tecnología", "Deportes"
  final String categoryKey; // clave para la API: "technology", "sports", etc.

  const NewsCategoryPage({
    super.key,
    required this.title,
    required this.categoryKey,
  });

  @override
  State<NewsCategoryPage> createState() => _NewsCategoryPageState();
}

class _NewsCategoryPageState extends State<NewsCategoryPage> {
  bool _firstLoadDone = false;
  bool _localLoading = false;
  String? _localError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Primer load cuando el Provider ya está disponible
    if (!_firstLoadDone) {
      _firstLoadDone = true;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _localLoading = true;
      _localError = null;
    });

    final svc = context.read<NewsServices>();

    try {
      // 1) Intento directo (patrón típico): getArticlesByCategory(category)
      try {
        // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
        await (svc as dynamic).getArticlesByCategory(widget.categoryKey);
      } catch (_) {
        // 2) Alternativa típica: set selectedCategory (si el servicio la usa)
        try {
          (svc as dynamic).selectedCategory = widget.categoryKey;
          await Future.delayed(const Duration(milliseconds: 200));
        } catch (_) {
          // 3) Otra variante común del mismo patrón
          try {
            // algunos lo nombran fetchByCategory
            await (svc as dynamic).fetchByCategory(widget.categoryKey);
          } catch (__) {
            // si ninguna firma existe, lanzamos para mostrar error
            throw Exception(
              'No encontré método en NewsServices para cargar por categoría.\n'
                  'Añade getArticlesByCategory(String) o fetchByCategory(String) o usa selectedCategory.',
            );
          }
        }
      }
    } catch (e) {
      _localError = e.toString();
    } finally {
      if (mounted) {
        setState(() => _localLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<NewsServices>();
    // Mapa típico: Map<String, List<Article>>
    List<dynamic> list = const [];

    try {
      final map = (svc as dynamic).categoryArticles as Map?;
      if (map != null && map[widget.categoryKey] is List) {
        list = map[widget.categoryKey] as List;
      } else {
        // También soporta el patrón de categoría seleccionada
        try {
          final selected = (svc as dynamic).selectedCategory as String?;
          if (selected == widget.categoryKey) {
            final selectedList =
            (svc as dynamic).getArticlesCategorySelected as List?;
            if (selectedList != null) list = selectedList;
          }
        } catch (_) {}
      }
    } catch (_) {
      // si no existe categoryArticles, seguimos con lista vacía
    }

    final isLoadingGlobal = _tryBool(() => (svc as dynamic).isLoading) ?? false;
    final isLoading = _localLoading || isLoadingGlobal;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Builder(
        builder: (context) {
          if (isLoading && list.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_localError != null) {
            return _ErrorView(
              message:
              'Error al cargar ${widget.title}.\n\n$_localError\n\n'
                  'Sugerencia: implementa en NewsServices:\n'
                  '- Future<void> getArticlesByCategory(String category)\n'
                  'o\n'
                  '- set selectedCategory(String) { ...getArticlesByCategory(category); }\n'
                  'o\n'
                  '- Future<void> fetchByCategory(String category)',
              onRetry: _load,
            );
          }
          if (list.isEmpty) {
            return _EmptyView(
              message:
              'No hay resultados en ${widget.title}. (categoría: ${widget.categoryKey})',
              onRetry: _load,
            );
          }

          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final a = list[i] as dynamic;

              // Campos comunes del modelo Article del proyecto base
              final title = _asString(() => a.title) ??
                  _asString(() => a.name) ??
                  'Sin título';
              final desc = _asString(() => a.description) ??
                  _asString(() => a.summary);
              final img = _asString(() => a.urlToImage) ??
                  _asString(() => a.image) ??
                  _asString(() => a.thumbnail);

              return ListTile(
                leading: img == null
                    ? const Icon(Icons.article_outlined)
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    img,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
                title:
                Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: desc != null ? Text(desc) : null,
                onTap: () {
                  // Si tienes detalle, navega aquí.
                },
              );
            },
          );
        },
      ),
    );
  }

  static bool? _tryBool(bool Function() f) {
    try {
      final v = f();
      if (v is bool) return v;
      return null;
    } catch (_) {
      return null;
    }
  }

  static String? _asString(String? Function() f) {
    try {
      final v = f();
      if (v == null) return null;
      return v.toString();
    } catch (_) {
      return null;
    }
  }
}

class _EmptyView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _EmptyView({required this.message, required this.onRetry, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 42),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 42),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
