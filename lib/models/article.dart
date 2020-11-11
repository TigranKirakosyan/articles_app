
class Article {
  final int id;
  final String title;
  final String username;
  final String userImage;
  final String description;
  final List<String> images;
  final int elapsedTime;
  bool bookmarked;

  Article({
    this.id,
    this.title,
    this.username,
    this.userImage,
    this.description,
    this.images,
    this.elapsedTime,
    this.bookmarked
    });

    factory Article.fromJson(Map<String, dynamic> json) {
        return new Article(
          id: json['id'],
          title: json['title'],
          username: json['userName'],
          userImage: json['userImage'],
          description: json['description'],
          images: json['images'].cast<String>(),
          elapsedTime: json['elapsedTimeInHour'],
          bookmarked: json['bookmarked'],
        );
    }

    Map toJson() => {
        'id': id,
        'title': title,
        'userName': username,
        'userImage': userImage,
        'description': description,
        'images': images,
        'elapsedTimeInHour': elapsedTime,
        'bookmarked': bookmarked,
      };

}
