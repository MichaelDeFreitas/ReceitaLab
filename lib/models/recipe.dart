class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.instructions,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.difficulty,
    required this.cuisine,
    required this.image,
    required this.rating,
    required this.reviewCount,
    required this.tags,
    required this.caloriesPerServing,
  });

  final int id;
  final String name;
  final List<String> ingredients;
  final List<String> instructions;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final String difficulty;
  final String cuisine;
  final String image;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final int caloriesPerServing;

  int get totalTime => prepTimeMinutes + cookTimeMinutes;

  Recipe copyWith({
    String? name,
    List<String>? ingredients,
    List<String>? instructions,
    String? cuisine,
    String? difficulty,
    List<String>? tags,
  }) => Recipe(
    id: id,
    name: name ?? this.name,
    ingredients: ingredients ?? this.ingredients,
    instructions: instructions ?? this.instructions,
    prepTimeMinutes: prepTimeMinutes,
    cookTimeMinutes: cookTimeMinutes,
    servings: servings,
    difficulty: difficulty ?? this.difficulty,
    cuisine: cuisine ?? this.cuisine,
    image: image,
    rating: rating,
    reviewCount: reviewCount,
    tags: tags ?? this.tags,
    caloriesPerServing: caloriesPerServing,
  );

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json['id'] as int? ?? 0,
    name: json['name'] as String? ?? 'Receita sem nome',
    ingredients: List<String>.from(json['ingredients'] ?? const []),
    instructions: List<String>.from(json['instructions'] ?? const []),
    prepTimeMinutes: json['prepTimeMinutes'] as int? ?? 0,
    cookTimeMinutes: json['cookTimeMinutes'] as int? ?? 0,
    servings: json['servings'] as int? ?? 1,
    difficulty: json['difficulty'] as String? ?? 'Não informada',
    cuisine: json['cuisine'] as String? ?? 'Variada',
    image: json['image'] as String? ?? '',
    rating: (json['rating'] as num?)?.toDouble() ?? 0,
    reviewCount: json['reviewCount'] as int? ?? 0,
    tags: List<String>.from(json['tags'] ?? const []),
    caloriesPerServing: json['caloriesPerServing'] as int? ?? 0,
  );
}
