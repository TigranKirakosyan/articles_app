import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:flutter/material.dart';

import './state_container.dart';
import '../models/article.dart';
import '../widgets/article_item_detail.dart';
import '../storage.dart';
import '../types.dart';

class ArticleDetailScreen extends StatelessWidget {
  static const routeName = '/article-detail';


final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey<ScaffoldState>();

  Future<void> send(String subject, String body) async {
    if (Platform.isIOS) {
      final bool canSend = await FlutterMailer.canSendMail();
      if (!canSend) {
        const SnackBar snackbar =
            const SnackBar(content: Text('No Email App Available'));
        _scafoldKey.currentState.showSnackBar(snackbar);
        return;
      }
    }

    final MailOptions mailOptions = MailOptions(
      body: body,
      subject: subject,
      recipients: <String>[],
      isHTML: true,
      ccRecipients: <String>[],
      attachments: null,
    );

    String platformResponse;

    try {
      final MailerResponse response = await FlutterMailer.send(mailOptions);
      switch (response) {
        case MailerResponse.saved:
          platformResponse = 'Mail was saved to draft';
          break;
        case MailerResponse.sent:
          platformResponse = 'Mail was sent';
          break;
        case MailerResponse.cancelled:
          platformResponse = 'Mail was cancelled';
          break;
        case MailerResponse.android:
          platformResponse = 'Intent was success';
          break;
        default:
          platformResponse = 'Unknown';
          break;
      }
    } on PlatformException catch (error) {
      platformResponse = error.toString();
      print(error);

      await showDialog<void>(
          context: _scafoldKey.currentContext,
          builder: (BuildContext context) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Message',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    Text(error.message),
                  ],
                ),
                contentPadding: const EdgeInsets.all(26),
                title: Text(error.code),
              ));
    } catch (error) {
      platformResponse = error.toString();
    }
    _scafoldKey.currentState.showSnackBar(SnackBar(
      content: Text(platformResponse),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments as List<Object>;
    final selectedArticle = args[0] as Article;
    final removeArticle = args[1] as Function;
    final fromScreen = args[2] as TabScreen;

    final PreferredSizeWidget appBar = Platform.isIOS
        ? CupertinoNavigationBar(
            actionsForegroundColor: Colors.black,
            middle: Text(
              '${selectedArticle.title}',
              overflow: TextOverflow.ellipsis,
            ),
            trailing: 
            Row(
              mainAxisSize: MainAxisSize.min,
              children: 
                (!selectedArticle.bookmarked && fromScreen == TabScreen.Article) ? <Widget>[
                  bookmarkAction(context, selectedArticle, removeArticle, send),
                  showMenuActionSheet(context, selectedArticle, removeArticle, send, fromScreen),
                ] : <Widget>[
                  showMenuActionSheet(context, selectedArticle, removeArticle, send, fromScreen),
                ],
            ),
          )
        : AppBar(
            title: Text('${selectedArticle.title}'),
            actions: (!selectedArticle.bookmarked && fromScreen == TabScreen.Article) ? <Widget>[
              bookmarkAction(context, selectedArticle, removeArticle, send),
              popMenu(context, selectedArticle, removeArticle, send, fromScreen),
            ] : <Widget>[
              popMenu(context, selectedArticle, removeArticle, send, fromScreen),
            ],
    );
    return Scaffold(
      key: _scafoldKey,
      appBar: appBar,
      body: Scrollbar(
        child:SingleChildScrollView(
        child: ArticleItemDetail(
          article: Article(
          id: selectedArticle.id, 
          title: selectedArticle.title, 
          username: selectedArticle.username, 
          userImage: selectedArticle.userImage, 
          description: selectedArticle.description, 
          images: selectedArticle.images, 
          elapsedTime: selectedArticle.elapsedTime,
          bookmarked: selectedArticle.bookmarked,
          )
          )
      )
    )
    );
  }
  
}

Widget showMenuActionSheet(BuildContext context, Article article, Function removeArticle, Function sendEmail, TabScreen fromScreen) {
  return GestureDetector(
          child: Container(
                  width: 34,
                  height: 34,
                  child:Icon(CupertinoIcons.ellipsis_vertical, size: 20),
                  color: Colors.transparent,
              ),
          onTap: () {
            final action = CupertinoActionSheet(
              title: Text(
                "Article Actions",
                style: TextStyle(fontSize: 20),
              ),
              message: Text(
                "Select action ",
                style: TextStyle(fontSize: 15.0),
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                  child: Text("Email"),
  //                          isDefaultAction: true,
                  onPressed: () {
                    sendEmail(article.title, article.description);
                    Navigator.pop(context);
                  },
                ),
                CupertinoActionSheetAction(
                  child: (article.bookmarked && fromScreen == TabScreen.Bookmark) ? Text("Remove") : Text("Delete"),
  //                          isDestructiveAction: true,
                  onPressed: () {
                    if (article.bookmarked && fromScreen == TabScreen.Bookmark) {
                        List<Article> articles;
                        List<Article> bookmarkedArticles;
                        List<Article> filteredArticles;
                        List<Article> filteredBookmarkedArticles;

                        article.bookmarked = false;
                        final container = StateContainer.of(context);
                        articles = container.articleData.articles;
                        int index = articles.indexWhere((element) => element.id == article.id);
                        if (index != -1) {
                          articles[index].bookmarked = false;
                        }
                        filteredArticles = container.articleData.filteredArticles;
                        int ind = filteredArticles.indexWhere((element) => element.id == article.id);
                        if (ind != -1) {
                          filteredArticles[ind].bookmarked = false;
                        }
                        bookmarkedArticles = container.articleData.bookmarkedArticles;
                        bookmarkedArticles.removeWhere((element) => element.id == article.id);
                        filteredBookmarkedArticles = container.articleData.filteredBookmarkedArticles;
                        filteredBookmarkedArticles.removeWhere((element) => element.id == article.id);
                        container.updateArticleData(articles: articles, bookmarkedArticles: bookmarkedArticles, filteredArticles: filteredArticles, filteredBookmarkedArticles: filteredBookmarkedArticles);

                        Storage storage = Storage();
                        String json = jsonEncode(container.articleData.articles);
                        storage.writeData(json);
                     }
                     else { 
                        removeArticle(article.id);
                     }
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              ],
              cancelButton: CupertinoActionSheetAction(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            );
            showCupertinoModalPopup(
              context: context, builder: (context) => action
            );
          },
      );
}

Widget bookmarkAction(BuildContext context, Article article, Function removeArticle, Function sendEmail) {
  return GestureDetector(
          child: Container(
                  width: 34,
                  height: 34,
                  child:Icon(CupertinoIcons.bookmark, size: 20),
                  color: Colors.transparent,
              ),
          onTap: () {
                List<Article> articles;
                List<Article> bookmarkedArticles;
                List<Article> filteredArticles;
                List<Article> filteredBookmarkedArticles;

                article.bookmarked = true;
                final container = StateContainer.of(context);
                articles = container.articleData.articles;
                int index = articles.indexWhere((element) => element.id == article.id);
                if (index != -1) {
                  articles[index].bookmarked = true;
                  bookmarkedArticles = container.articleData.bookmarkedArticles;
                  bookmarkedArticles.add(article);
                }
                filteredArticles = container.articleData.filteredArticles;
                int ind = filteredArticles.indexWhere((element) => element.id == article.id);
                if (ind != -1) {
                  filteredArticles[ind].bookmarked = true;
                }
                container.updateArticleData(articles: articles, bookmarkedArticles: bookmarkedArticles, filteredArticles: filteredArticles, filteredBookmarkedArticles: filteredBookmarkedArticles);

                Storage storage = Storage();
                String json = jsonEncode(container.articleData.articles);
                storage.writeData(json);
 //               Navigator.pop(context);
          },
      );
}

Widget popMenu(BuildContext context, Article article, Function removeArticle, Function sendEmail, TabScreen fromScreen) {
    return PopupMenuButton(
      onSelected: (value) {
          if (value == 1) {
            sendEmail(article.title, article.description);
          }
          else {
            if (article.bookmarked && fromScreen == TabScreen.Bookmark) {
                List<Article> articles;
                List<Article> bookmarkedArticles;
                List<Article> filteredArticles;
                List<Article> filteredBookmarkedArticles;

                article.bookmarked = false;
                final container = StateContainer.of(context);
                articles = container.articleData.articles;
                int index = articles.indexWhere((element) => element.id == article.id);
                if (index != -1) {
                  articles[index].bookmarked = false;
                }
                filteredArticles = container.articleData.filteredArticles;
                int ind = filteredArticles.indexWhere((element) => element.id == article.id);
                if (ind != -1) {
                  filteredArticles[ind].bookmarked = false;
                }
                bookmarkedArticles = container.articleData.bookmarkedArticles;
                bookmarkedArticles.removeWhere((element) => element.id == article.id);
                filteredBookmarkedArticles = container.articleData.filteredBookmarkedArticles;
                filteredBookmarkedArticles.removeWhere((element) => element.id == article.id);
                container.updateArticleData(articles: articles, bookmarkedArticles: bookmarkedArticles, filteredArticles: filteredArticles, filteredBookmarkedArticles: filteredBookmarkedArticles);
                
                Storage storage = Storage();
                String json = jsonEncode(container.articleData.articles);
                storage.writeData(json);
            } 
            else {
                removeArticle(article.id);
            }
            Navigator.pop(context);
          }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 1,
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
                child: Icon(Icons.email),
              ),
              Text('Email')
            ],
          )
        ),
        PopupMenuItem(
            value: 2,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
                  child: Icon(Icons.delete),
                ),
                (article.bookmarked && fromScreen == TabScreen.Bookmark) ? Text("Remove") : Text("Delete"),
              ],
            )
        ),
      ]);
}
