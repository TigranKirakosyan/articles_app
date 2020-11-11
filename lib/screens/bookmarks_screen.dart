import 'package:flutter/cupertino.dart';

import '../models/article.dart';
import '../screens/state_container.dart';
import '../widgets/article_item.dart';
import '../types.dart';

class BookmarksScreen extends StatefulWidget {  
  final List<Article> articles;

  BookmarksScreen({Key key, this.articles}) : super(key: key);
  
  @override
  _BookmarksScreenState createState() => _BookmarksScreenState();

}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final List<Article> bookmarkedArticles = [];

@override
  void initState() {
    super.initState();
//    bookmarkedArticles.addAll(widget.articles);
  }

  void deleteArticle(int articleId) {
    final container = StateContainer.of(context);
    container.articleData.articles.removeWhere((article) => article.id == articleId);
    container.articleData.bookmarkedArticles.removeWhere((article) => article.id == articleId);
    container.articleData.filteredArticles.removeWhere((article) => article.id == articleId);
    container.articleData.filteredBookmarkedArticles.removeWhere((article) => article.id == articleId);
     setState(() {
     }); 
  }

  @override
  Widget build(BuildContext context) {
    final container = StateContainer.of(context);
    bookmarkedArticles.clear();
    bookmarkedArticles.addAll(container.articleData.filteredBookmarkedArticles);

    bookmarkedArticles.sort((item1,item2) {
      return item1.elapsedTime.compareTo(item2.elapsedTime);
    });
    return (bookmarkedArticles.length > 0) ? ListView.builder(
      itemCount: bookmarkedArticles.length,
      itemBuilder: (BuildContext context, int index) {
        var article = bookmarkedArticles[index];
        return _buildWidgetItemListData(article, deleteArticle);
      })
      : ListView(
        children: [
            Container(
              child: Center(
                child: Text("No articles are available"),
              )
            )
      ]);
  }

    Widget _buildWidgetItemListData(Article article, Function deleteArticle) {
    return ArticleItem(
          article: article,
          deleteItem: deleteArticle,
          fromScreen: TabScreen.Bookmark,
    );
  }

}

