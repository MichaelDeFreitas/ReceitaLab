import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeService _service = RecipeService();
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
      recipes = await _service.getRecipes();
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
      final recipe = await _service.getRecipe(id);
      _knownRecipes[id] = recipe;
      return recipe;
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
      searchResults = await _service.searchRecipes(query.trim());
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
      recipes = tag == null ? await _service.getRecipes() : await _service.getRecipesByTag(tag);
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
