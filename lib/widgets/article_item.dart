import 'package:articles_app/widgets/article_info.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../types.dart';
import '../models/article.dart';
import '../screens/article_detail_screen.dart';

class ArticleItem extends StatelessWidget {

  final Article article;
  final Function deleteItem;
  final TabScreen fromScreen;

  ArticleItem({
    @required this.article,
    @required this.deleteItem,      
    @required this.fromScreen,      
});

  void selectArticle(BuildContext context) {
    Navigator.pushNamed(
      context,
      ArticleDetailScreen.routeName,
      arguments: [article, deleteItem, fromScreen],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.only(
          left: 0,
          top: 5,
          right: 0,
          bottom: 5,
        ),
        elevation: 4,
        child: InkWell(
            onTap: () => selectArticle(context),
            highlightColor: Colors.transparent,
            child: Slidable(
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              actions: <Widget>[
                  IconSlideAction(
                    caption: 'Delete',
                    color: Colors.blueGrey,
                    icon: Icons.delete,
                    onTap: () {
                      deleteItem(article.id);
                    }
                  ),
              ],
              child:Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width - 80.0,
                              child: 
                                Text(
                                  article.username + ' - ' + article.elapsedTime.toString() + ' hrs ago',
                                  style: GoogleFonts.notoSans(fontStyle: FontStyle.normal, fontSize: 15, color: Colors.black),
                                ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(
                                left: 10,
                              ),
                              width: MediaQuery.of(context).size.width - 80.0,
                              child: 
                                Text(
                                  article.title,
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        //                          style: GoogleFonts.notoSans(fontStyle: FontStyle.normal, fontWeight: FontWeight.w700, fontSize: 20, color: Colors.black),
                                ),
                            ), 
                          ],
                        ),
                        SizedBox(
                            width: 10,
                        ),
                        userAvatar(context, article.userImage, false),
                        SizedBox(
                          width: 10,
                        ),
                    ],
                    ),
                    SizedBox(
                        height: 20,
                    ),
                    articleDescription(context, article.description, false),
                    articleImages(context, article.images, false),
                ]
              )
        )
      )
    );
  }

}
