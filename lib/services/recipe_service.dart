import 'package:dio/dio.dart';
import '../models/recipe.dart';

class RecipeService {
  RecipeService()
      : _dio = Dio(BaseOptions(
          baseUrl: 'https://dummyjson.com',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ));

  final Dio _dio;

  Future<List<Recipe>> getRecipes({int limit = 30, int skip = 0}) async {
    final response = await _dio.get('/recipes', queryParameters: {
      'limit': limit,
      'skip': skip,
    });
    final items = response.data['recipes'] as List<dynamic>;
    return items.map((item) => Recipe.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Recipe> getRecipe(int id) async {
    final response = await _dio.get('/recipes/$id');
    return Recipe.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    final response = await _dio.get('/recipes/search', queryParameters: {'q': query});
    final items = response.data['recipes'] as List<dynamic>;
    return items.map((item) => Recipe.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<String>> getTags() async {
    final response = await _dio.get('/recipes/tags');
    return List<String>.from(response.data as List);
  }

  Future<List<Recipe>> getRecipesByTag(String tag) async {
    final response = await _dio.get('/recipes/tag/${Uri.encodeComponent(tag)}');
    final items = response.data['recipes'] as List<dynamic>;
    return items.map((item) => Recipe.fromJson(item as Map<String, dynamic>)).toList();
  }
}
