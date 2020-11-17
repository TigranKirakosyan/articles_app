import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget articleImages(
    BuildContext context, List<String> images, bool expandedMode) {
  return !expandedMode
      ? Container(
          padding: EdgeInsets.only(
            left: 10,
            top: 0,
            right: 10,
            bottom: 10,
          ),
          height: images.isNotEmpty ? 80 : 0,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Container(
                  child: Card(
                    child: ClipRRect(
                      child: Image.network(
                        images[index].toString(),
                        height: 80,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              }),
        )
      :
      // fixme replace the Container with Padding
      Container(
          padding: EdgeInsets.all(10.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: images.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemBuilder: (BuildContext context, int index) {
              return Image.network(
                images[index],
                fit: BoxFit.cover,
              );
            },
          ));
}

Widget articleDescription(
    BuildContext context, String description, bool expandedMode) {
  // Fixme better to use Padding
  return expandedMode
      ? Container(
          padding: const EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          child: SelectableText(description,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 15,
              )),
        )
      :
      // Fixme better to use Padding
      Container(
          padding: EdgeInsets.only(
            left: 10,
            top: 0,
            right: 10,
            bottom: 10,
          ),
          child: Text(
            description,
            textAlign: TextAlign.left,
            style: GoogleFonts.notoSans(
                fontStyle: FontStyle.normal, fontSize: 16, color: Colors.black),
            overflow: TextOverflow.ellipsis,
          ),
        );
}

Widget userAvatar(BuildContext context, String imageUrl, bool expandedMode) {
  // Fixme show place holder while the image is loading
  return expandedMode
      // Fixme redundant Container
      ? Container(
          child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  'assets/images/avatar.png',
                  width: 40.0,
                  height: 40.0,
                  fit: BoxFit.cover,
                ),
        ))
      // Fixme redundant Container, or will be better to use the Align
      : Container(
          alignment: Alignment.topCenter,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/images/avatar.png',
                    width: 40.0,
                    height: 40.0,
                    fit: BoxFit.cover,
                  ),
          ));
}
