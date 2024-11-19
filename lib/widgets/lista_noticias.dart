import 'package:flutter/material.dart';
import 'package:flutter_news_apps/models/news_models.dart';
import 'package:flutter_news_apps/theme/tema.dart';

class ListaNoticias extends StatelessWidget {
  
  final List<Article> noticias;
  
  const ListaNoticias(this.noticias);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: this.noticias.length,
      itemBuilder: (BuildContext context, int index) {
        return _Noticia(noticia: this.noticias[index], index: index);
      }
    );
  }
}

class _Noticia extends StatelessWidget {
  
  final Article noticia;
  final int index;

  const _Noticia({
    required this.noticia, 
    required this.index
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TarjetaTopBar(noticia, index),
        _TarjetaTitulo(noticia),
        _TarjetaImagen(noticia),
        _TarjetaBody(noticia),

        SizedBox(height: 10),
        Divider(),
      ],
    );
  }
}

class _TarjetaBody extends StatelessWidget {
  
  final Article noticia;

  const _TarjetaBody(
    this.noticia
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(noticia.description ?? ''),
    );
  }
}

class _TarjetaImagen extends StatelessWidget {

  final Article noticia;

  const _TarjetaImagen(
    this.noticia
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      child: (noticia.urlToImage != null)
           ? FadeInImage(
                placeholder: AssetImage('assets/img/load.gif'), 
                image: NetworkImage(noticia.urlToImage!)
              )
            : Image(image: AssetImage('assets/img/not_image.png'))
    );
  }
}

class _TarjetaTitulo extends StatelessWidget {
  
  final Article noticia;

  const _TarjetaTitulo(
    this.noticia
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Text('${noticia.title}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
    );
  }
}

class _TarjetaTopBar extends StatelessWidget {
  
  final Article noticia;
  final int index;

  const _TarjetaTopBar(
    this.noticia,
    this.index
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text('${index + 1}.', style: TextStyle(color: miTema.primaryColor)),
          Text('${noticia.source.name}'),
        ],
      ),
    );
  }
}