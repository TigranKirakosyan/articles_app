import '../models/article.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class ArticleData {
  List<Article> articles;
  List<Article> bookmarkedArticles;
  List<Article> filteredArticles;
  List<Article> filteredBookmarkedArticles;

  ArticleData({this.articles, this.bookmarkedArticles, this.filteredArticles, this.filteredBookmarkedArticles});
}

class StateContainer extends StatefulWidget {
  final Widget child;
  final ArticleData articleData;

  StateContainer({
    @required this.child,
    this.articleData,
  });

  static StateContainerState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_InheritedStateContainer>().data;
  }

  @override
  StateContainerState createState() => new StateContainerState();
}

class StateContainerState extends State<StateContainer> {
  ArticleData articleData = ArticleData(articles: [], bookmarkedArticles: [], filteredArticles: [], filteredBookmarkedArticles: []);

  void updateArticleData({articles, bookmarkedArticles, filteredArticles, filteredBookmarkedArticles}) {

    if (articleData == null) {
      articleData = ArticleData(articles: articles, bookmarkedArticles: bookmarkedArticles, filteredArticles: filteredArticles, filteredBookmarkedArticles: filteredBookmarkedArticles);
      setState(() {
        articleData = articleData;
      });
    } else {
      setState(() {
        articleData.articles = articles ?? articleData.articles;
        articleData.bookmarkedArticles = bookmarkedArticles ?? articleData.bookmarkedArticles;
        articleData.filteredArticles = filteredArticles ?? articleData.filteredArticles;
        articleData.filteredBookmarkedArticles = filteredBookmarkedArticles ?? articleData.filteredBookmarkedArticles;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }
}

// Fixme it is possible to store data inside the InheritedWidget, why to use additional
// wrapper widget
class _InheritedStateContainer extends InheritedWidget {
  final StateContainerState data;

  _InheritedStateContainer({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}
