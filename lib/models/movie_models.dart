class MovieModel {
  int id;
  String title;
  String posterPath;
  String overView;
  double popularity;

  MovieModel({required this.id, required this.title,required this.posterPath,required this.overView, required this.popularity});

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? "Unknown",
      posterPath: json['poster_path'] ?? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSyJQZkuL-PH_FVgZWWtWIYt0emdIceCZ7X6ScYwn1pxQ&s=10",
      overView: json['overview'] ?? "No overview available",
      popularity: json['popularity'] ?? 0,
    );
  }
  String get posterUrl {
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

}