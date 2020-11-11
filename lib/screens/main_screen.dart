import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../models/article.dart';
import '../screens/state_container.dart';

import './articles_screen.dart';
import './bookmarks_screen.dart';

class MainScreen extends StatefulWidget {  
  final List<Article> articles;

  MainScreen(this.articles);
  
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Map<String, Object>> _pages;
  int _selectedPageIndex = 0;
  ArticlesScreen articleScreen;
  BookmarksScreen bookmarksScreen;

  Icon _searchIcon = Icon(Icons.search);
  final TextEditingController _filter = TextEditingController();
  String _searchText = "";
  List<Article> filteredArticles = [];
  List<Article> filteredBookmarkedArticles = [];
  Widget _appBarTitle = Text( 'Search Example' );
  Widget _appIOSBarTitle = Text( 'Search Example' );
  List<Article> originalArticles = [];

  _MainScreenState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
      final container = StateContainer.of(context);
      List<Article> filteredData = _filterArticleList();
      if (_selectedPageIndex == 0) {
        container.updateArticleData(articles: container.articleData.articles, bookmarkedArticles: container.articleData.bookmarkedArticles, filteredArticles: filteredData, filteredBookmarkedArticles: container.articleData.filteredBookmarkedArticles);
      }
      else {
        container.updateArticleData(articles: container.articleData.articles, bookmarkedArticles: container.articleData.bookmarkedArticles, filteredArticles: container.articleData.filteredArticles, filteredBookmarkedArticles: filteredData);
      }

    });
  }

  @override
  void initState() {
    originalArticles.addAll(widget.articles);
    _pages = [
      {
        'page': ArticlesScreen(articles: originalArticles),
        'title': 'Articles',
      },
      {
        'page': BookmarksScreen(articles: originalArticles.where((element) => element.bookmarked == true).toList()),
        'title': 'Bookmarks',
      },
    ];
    super.initState();

  }

  void _selectPage(int index) {
    setState(() {
      if (_selectedPageIndex != index) {
        _selectedPageIndex = index;
        _searchIcon = Icon(Icons.search);
        _filter.clear();
        _searchText = "";

        final container = StateContainer.of(context);
        List<Article> filteredData = _filterArticleList();
        if (_selectedPageIndex == 0) {
          container.updateArticleData(articles: container.articleData.articles, bookmarkedArticles: container.articleData.bookmarkedArticles, filteredArticles: filteredData, filteredBookmarkedArticles: container.articleData.filteredBookmarkedArticles);
        }
        else {
          container.updateArticleData(articles: container.articleData.articles, bookmarkedArticles: container.articleData.bookmarkedArticles, filteredArticles: container.articleData.filteredArticles, filteredBookmarkedArticles: filteredData);
        }
      }
      else {
        _selectedPageIndex = index;
      }
    });
  
  }

  List<Article> _filterArticleList() {
    final container = StateContainer.of(context);
    List<Article> articles = container.articleData.articles;
    List<Article> bookmarkedArticles = container.articleData.bookmarkedArticles;  

    if (_searchText.isNotEmpty) {
      List<Article> tempList = [];
      if (_selectedPageIndex == 0) {

        for (int i = 0; i < articles.length; i++) {
          if (articles[i].title.toLowerCase().contains(_searchText.toLowerCase()) || 
            articles[i].username.toLowerCase().contains(_searchText.toLowerCase())) {
            tempList.add(articles[i]);
          }
        }
        filteredArticles = tempList;
        return filteredArticles;
      }
      else {
          for (int i = 0; i < bookmarkedArticles.length; i++) {
            if (bookmarkedArticles[i].title.toLowerCase().contains(_searchText.toLowerCase()) || 
              bookmarkedArticles[i].username.toLowerCase().contains(_searchText.toLowerCase())) {
              tempList.add(bookmarkedArticles[i]);
            }
          }
          filteredBookmarkedArticles = tempList;
          return filteredBookmarkedArticles;
      }
    }

    if (_selectedPageIndex == 0) {
          filteredArticles = articles;
          return filteredArticles;
      }
      else {
          filteredBookmarkedArticles = bookmarkedArticles;
          return filteredBookmarkedArticles;
      }
  }

  void _searchPressed() {
    setState(() {
      if (_searchIcon.icon == Icons.search) {
        _searchIcon = Icon(Icons.close);
        _appBarTitle = TextField(
          autofocus: true,
          controller: _filter,
          decoration: InputDecoration(
  //          prefixIcon: Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            hintText: 'Search...',
            contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(20),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
        _appIOSBarTitle = Theme(
        data: Theme.of(context).copyWith(
          primaryColor: Colors.grey,
        ),
        child: Material(
          child: TextField(
          autofocus: true,
          controller: _filter,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            hintText: 'Search...',
            contentPadding: const EdgeInsets.only(left: 14.0, bottom: 4.0, top: 4.0),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(20),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),) 
        );
      } else {
        _searchIcon = Icon(Icons.search);
        _appBarTitle = Text( 'Search' );
        _appIOSBarTitle = Text( 'Search' );
        _filter.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final PreferredSizeWidget appBar = Platform.isIOS
        ? CupertinoNavigationBar(
          padding: EdgeInsetsDirectional.only(start: 4, top: 4, end: 4, bottom: 4),
            middle: (_searchIcon.icon == Icons.search) ? Text(_pages[_selectedPageIndex]['title']) : _appIOSBarTitle,
            trailing: Material(
              child: IconButton(
                icon: _searchIcon,
                onPressed: _searchPressed,
            ),) ,
          )
        : AppBar(
            title: (_searchIcon.icon == Icons.search) ? Text(_pages[_selectedPageIndex]['title']) : _appBarTitle,
//            brightness: Brightness.light,
            actions: [
              IconButton(
                icon: _searchIcon,
                onPressed: _searchPressed,
              ),
            ],
          );

    return Scaffold(
      appBar: appBar,
      body: _pages[_selectedPageIndex]['page'], 
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        backgroundColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Theme.of(context).accentColor,
        currentIndex: _selectedPageIndex,
        items: [
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.category),
            label: 'Articles',
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.bookmark),
            label: 'Bookmarks',
          ),
        ],
      ),
    );
  }

}