import 'package:flutter/material.dart';
import 'package:flutter_news_apps/services/new_services.dart';
import 'package:flutter_news_apps/widgets/lista_noticias.dart';
import 'package:provider/provider.dart';

class Tab1Page extends StatefulWidget {
  const Tab1Page({super.key});

  @override
  State<Tab1Page> createState() => _Tab1PageState();
}

class _Tab1PageState extends State<Tab1Page> with AutomaticKeepAliveClientMixin{
  @override
  Widget build(BuildContext context) {

    final headlines = Provider.of<NewsServices>(context).headlines;

    return Scaffold(
      body: (headlines.length == 0) 
          ? Center(child: CircularProgressIndicator(),)
          : ListaNoticias(headlines)
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}