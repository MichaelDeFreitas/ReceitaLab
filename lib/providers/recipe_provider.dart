import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../services/translation_service.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeService _service = RecipeService();
  final TranslationService _translator = TranslationService();
  List<Recipe> recipes = [];
  List<Recipe> searchResults = [];
  List<String> tags = [];
  final Set<int> favoriteIds = {};
  final Map<int, Recipe> _knownRecipes = {};
  bool isLoading = false;
  bool isSearching = false;
  String? errorMessage;
  String? searchError;
  String? selectedTag;

  Future<void> initialize() async {
    await loadFavorites();
    await loadRecipes();
    await loadTags();
  }

  Future<void> loadRecipes() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final fetched = await _service.getRecipes();
      recipes = await _translateRecipeNames(fetched);
      _remember(recipes);
    } catch (_) {
      errorMessage = 'Não foi possível carregar as receitas. Verifique sua conexão e tente novamente.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Recipe?> loadRecipe(int id) async {
    try {
      final fetched = await _service.getRecipe(id);
      final translated = await _translateRecipeDetails(fetched);
      _knownRecipes[id] = translated;
      return translated;
    } catch (_) {
      return null;
    }
  }

  Future<void> loadTags() async {
    try {
      tags = await _service.getTags();
      notifyListeners();
    } catch (_) {
      // As categorias são complementares; o catálogo continua disponível.
    }
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      searchResults = [];
      searchError = null;
      isSearching = false;
      notifyListeners();
      return;
    }
    isSearching = true;
    searchError = null;
    notifyListeners();
    try {
      final englishQuery = await _translator.toEnglish(query.trim());
      final fetched = await _service.searchRecipes(englishQuery);
      searchResults = await _translateRecipeNames(fetched);
      _remember(searchResults);
    } catch (_) {
      searchError = 'Erro ao pesquisar. Tente novamente.';
      searchResults = [];
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  Future<void> filterByTag(String? tag) async {
    selectedTag = tag;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final fetched = tag == null ? await _service.getRecipes() : await _service.getRecipesByTag(tag);
      recipes = await _translateRecipeNames(fetched);
      _remember(recipes);
    } catch (_) {
      errorMessage = 'Não foi possível carregar essa categoria.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool isFavorite(int id) => favoriteIds.contains(id);

  Future<void> toggleFavorite(int id) async {
    if (!favoriteIds.add(id)) favoriteIds.remove(id);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_recipe_ids', favoriteIds.map((e) => e.toString()).toList());
  }

  List<Recipe> get favoriteRecipes =>
      _knownRecipes.values.where((recipe) => favoriteIds.contains(recipe.id)).toList();

  Future<List<Recipe>> _translateRecipeNames(List<Recipe> items) async {
    final names = await _translator.toPortugueseList(items.map((item) => item.name).toList());
    return List.generate(items.length, (index) => items[index].copyWith(name: names[index]));
  }

  Future<Recipe> _translateRecipeDetails(Recipe recipe) async {
    final allTexts = <String>[
      recipe.name,
      recipe.cuisine,
      ...recipe.ingredients,
      ...recipe.instructions,
    ];
    final translated = await _translator.toPortugueseList(allTexts);
    var cursor = 0;
    final name = translated[cursor++];
    final cuisine = translated[cursor++];
    final ingredients = translated.sublist(cursor, cursor + recipe.ingredients.length);
    cursor += recipe.ingredients.length;
    final instructions = translated.sublist(cursor);
    final difficulty = switch (recipe.difficulty.toLowerCase()) {
      'easy' => 'Fácil',
      'medium' => 'Médio',
      'hard' => 'Difícil',
      _ => recipe.difficulty,
    };
    return recipe.copyWith(
      name: name,
      cuisine: cuisine,
      ingredients: ingredients,
      instructions: instructions,
      difficulty: difficulty,
    );
  }

  void _remember(List<Recipe> items) {
    for (final recipe in items) {
      _knownRecipes[recipe.id] = recipe;
    }
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    favoriteIds
      ..clear()
      ..addAll((prefs.getStringList('favorite_recipe_ids') ?? [])
          .map((value) => int.tryParse(value))
          .whereType<int>());
    notifyListeners();
    for (final id in favoriteIds.toList()) {
      if (!_knownRecipes.containsKey(id)) {
        final recipe = await loadRecipe(id);
        if (recipe != null) notifyListeners();
      }
    }
  }
}
