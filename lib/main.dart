import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import './screens/main_screen.dart';
import './screens/state_container.dart';
import './storage.dart';
import './models/article.dart';
import './screens/article_detail_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(StateContainer(child: MyApp())));
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
       statusBarColor: Colors.transparent,
       statusBarIconBrightness: Brightness.light,
       statusBarBrightness: Brightness.dark
    ));
    return MaterialApp(
      title: 'Articles Demo',
      theme: ThemeData(
//        primarySwatch: Colors.cyan,
        primaryColor: Colors.grey[100],
        accentColor: Colors.black,
        canvasColor: Color.fromRGBO(250, 250, 250, 1),
        textTheme: GoogleFonts.notoSansTextTheme(
            Theme.of(context).textTheme,
        ),
        splashColor: Colors.grey[200],
      ),
      initialRoute: '/',
      routes: {
        '/': (ctx) => MyHomePage(title: 'Articles Demo'),
        ArticleDetailScreen.routeName: (ctx) => ArticleDetailScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (ctx) => MyHomePage(title: 'Articles Demo'),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Article>> futureArticle;
  List<Article> articles;
  var _loadedInitData = false;
//  bool _allowWriteFile = false;
  Storage storage = Storage();
  String articleData;

  @override
  void initState() {
    super.initState();

//   _requestWritePermission();
    futureArticle = getArticles();
  }

  // _requestWritePermission() async {
  //     PermissionStatus permissionStatus = await SimplePermissions._requestPermission(Permission.WriteExternalStorage);
  
  //     if (permissionStatus == PermissionStatus.authorized) {
  //       setState(() {
  //         _allowWriteFile = true;
  //       });
  //     }
  //   }

Future<List<Article>> getArticles() async {
  final response = await http.get('https://jsonkeeper.com/b/3FE1');

  if (response.statusCode == 200) {
    return parseJson(response.body.toString());
  } else {
    throw Exception('Failed to load articled');
  }
}

List<Article> parseJson(String response) {
    if(response == null) {
      return [];
    }
    final data = json.decode(response.toString());
    if (data == null) {
      return null;
    }
    return data['articles'].map<Article>( (entry) { 
          print(entry);
          return Article.fromJson(entry);
    }).toList();
}

Future<String> getArticlesFromFile() async {
  var result = await storage.readData();
  return result;
}

// Future<Map<String, dynamic>> parseJsonFromAssets(String assetsPath) async {
//     print('--- Parse json from: $assetsPath');
//     return rootBundle.loadString(assetsPath)
//         .then((jsonStr) => jsonDecode(jsonStr));
//   }

  @override
  Widget build(BuildContext context) {
    // Fixme Will be better to use single FutureBuilder on top of the tree
      var futureBuilder =  FutureBuilder<List<Article>>(
                        future: futureArticle,
//                        future: DefaultAssetBundle.of(context).loadString('assets/Articles.json'),
                        builder: (context, snapshot) {
                            // List<Article> articleData = parseJson(snapshot.data.toString());
                            // if (articleData == null) {
                            //     return Center(child: CircularProgressIndicator());
                            // }
                            // return articleData.isNotEmpty
                            //       ? ArticlesScreen(articles: articleData)
                            //       : Center(child: CircularProgressIndicator());
                            if (snapshot.hasData) {
                              articles = snapshot.data;

                              if (!_loadedInitData) {
                                final container = StateContainer.of(context);
                                container.articleData.articles = articles;
                                container.articleData.bookmarkedArticles = articles.where((element) => element.bookmarked == true).toList();
                                container.articleData.filteredArticles = container.articleData.articles;
                                container.articleData.filteredBookmarkedArticles = container.articleData.bookmarkedArticles;
                                _loadedInitData = true;
                              }
                              return articles.isNotEmpty
                                  ? MainScreen(articles)
                                  : Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                                return Text("${snapshot.error}");
                            }
                            return CircularProgressIndicator();

                        }
      );

      var futureArticlesFromFile = FutureBuilder<String>(
        future: getArticlesFromFile(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
              String result = snapshot.data;
              // Fixme parse the json inside getArticlesFromFile() method
              final data = json.decode(result);
              articles = data.map<Article>( (entry) { 
                  print(entry);
                  return Article.fromJson(entry);
              }).toList();              
              if (!_loadedInitData) {
                final container = StateContainer.of(context);
                container.articleData.articles = articles;
                container.articleData.bookmarkedArticles = articles.where((element) => element.bookmarked == true).toList();
                container.articleData.filteredArticles = container.articleData.articles;
                container.articleData.filteredBookmarkedArticles = container.articleData.bookmarkedArticles;
                _loadedInitData = true;
              }
              
              return MainScreen(articles);
          } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
          }
          return CircularProgressIndicator();
        }
      );    
      
      var futureFileExist = FutureBuilder<bool>(
        future: storage.fileExist(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
              bool isFileExist = snapshot.data;

              if (isFileExist) {             
                return futureArticlesFromFile;
              }
              else {
                return futureBuilder;
              }
          } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
          }
          return CircularProgressIndicator();
        }
      );          

    return Scaffold(
      body: Container(
            child: Center(
              child: futureFileExist,
                    )
            ),
    );
  }
}

