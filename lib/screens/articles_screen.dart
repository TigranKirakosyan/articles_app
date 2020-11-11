import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import './state_container.dart';
import '../widgets/article_item.dart';
import '../models/article.dart';
import '../storage.dart';
import '../types.dart';

class ArticlesScreen extends StatefulWidget {
  final List<Article> articles;

  ArticlesScreen({Key key, this.articles}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ArticlesScreenState(/*articles: this.articles*/);
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  List<Article> displayedArticles = [];
  var _loadedInitData = false;

@override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!_loadedInitData) {
      _loadedInitData = true;
    }
    super.didChangeDependencies();
  }

  void deleteArticle(int articleId) {
    final container = StateContainer.of(context);
    container.articleData.articles.removeWhere((article) => article.id == articleId);
    container.articleData.bookmarkedArticles.removeWhere((article) => article.id == articleId);
    container.articleData.filteredArticles.removeWhere((article) => article.id == articleId);
    container.articleData.filteredBookmarkedArticles.removeWhere((article) => article.id == articleId);
     setState(() {
     });

    Storage storage = Storage();
    String json = jsonEncode(container.articleData.articles);
    storage.writeData(json);
  }

Future<void> _refreshData() async {
  final response = await http.get('https://jsonkeeper.com/b/3FE1');

  if (response.statusCode == 200) {
    if(response == null) {
      return [];
    }
    final data = json.decode(response.body.toString());
    if (data == null) {
      return null;
    }
    List<Article> articles = data['articles'].map<Article>( (entry) { 
          print(entry);
          return Article.fromJson(entry);
    }).toList();

    setState(() {
      final container = StateContainer.of(context);
      container.articleData.articles = articles;
      container.articleData.bookmarkedArticles = articles.where((element) => element.bookmarked == true).toList();
      container.articleData.filteredArticles = container.articleData.articles;
      container.articleData.filteredBookmarkedArticles = container.articleData.bookmarkedArticles;
    }); 

  } else {
    throw Exception('Failed to load articled');
  }
}


  // Future<void> _refreshData() async {
  //   setState(() {
  //     final container = StateContainer.of(context);
  //     container.articleData.articles = widget.articles;
  //     container.articleData.filteredArticles = widget.articles;
  //   }); 
  // }

  @override
  Widget build(BuildContext context) {
    final container = StateContainer.of(context);
    displayedArticles.clear();
    displayedArticles.addAll(container.articleData.filteredArticles);

    displayedArticles.sort((item1,item2) {
      return item1.elapsedTime.compareTo(item2.elapsedTime);
    });

    return Platform.isIOS ? _buildWidgetListDataIOS() : _buildWidgetListDataAndroid();
  }

Widget _buildWidgetListDataIOS() {
    return CustomScrollView(
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: _refreshData,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                var article = displayedArticles[index];
                return _buildWidgetItemListData(article, deleteArticle);
              },
              childCount: displayedArticles.length
            ),
          ),
        ],
      );
  }

  Widget _buildWidgetListDataAndroid() {
    return RefreshIndicator(
      child: (displayedArticles.length > 0) ? 
      ListView.builder(
      itemCount: displayedArticles.length,
      itemBuilder: (BuildContext context, int index) {
        var article = displayedArticles[index];
        return _buildWidgetItemListData(article, deleteArticle);
      })
      : ListView(
        children: [
            Container(
              child: Center(
                child: Text("No articles are available"),
              )
            )
      ]),
      onRefresh: _refreshData,
    );
  }

  Widget _buildWidgetItemListData(Article article, Function deleteArticle) {
    return ArticleItem(
          article: article,
          deleteItem: deleteArticle,
          fromScreen: TabScreen.Article,
    );
  }
  
}
