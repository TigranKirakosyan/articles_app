
import 'package:flutter/material.dart';
import '../models/article.dart';
import 'article_info.dart';

class ArticleItemDetail extends StatelessWidget {
  final Article article;

  ArticleItemDetail({
    @required this.article,   
 });

  @override
  Widget build(BuildContext context) {
    return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: 
                    Text(
                        article.title,
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.left,
                    ),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                        padding: const EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width - 80.0,
                        child: 
                          Text(
                            article.username + ' - ' + article.elapsedTime.toString() + ' hrs ago',
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.left,
                          ),
                  ),
                  SizedBox(
                      width: 10,
                  ),
                  userAvatar(context, article.userImage, true),
                  SizedBox(
                    width: 10,
                  ),
                    ],
            ),
            SizedBox(
                height: 30,
            ),
            articleDescription(context, article.description, true),
            articleImages(context, article.images, true)
          ]
        );
  }

}
