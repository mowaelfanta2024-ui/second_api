import 'package:dio/dio.dart';

import '../models/movie_models.dart';

class ApiService {
  final Dio dio= Dio(
    BaseOptions(
      baseUrl: 'https://api.themoviedb.org/3/',
      queryParameters: {
        'api_key' : 'b9e0c88a1941eca7b4280f25000348a9',
      },
    ),
  );

  fetchMovies() async {
      final response = await dio.get('movie/popular');
      final movies = response.data['results'];
      return movies.map((movie) => MovieModel.fromJson(movie)).toList();
  }

}