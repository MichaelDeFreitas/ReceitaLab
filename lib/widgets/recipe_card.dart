import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../screens/details_screen.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => DetailsScreen(recipeId: recipe.id))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              AspectRatio(
                aspectRatio: 1.55,
                child: Image.network(recipe.image, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFE8EEE8),
                    child: const Icon(Icons.restaurant, size: 44, color: Color(0xFF71927C)),
                  ),
                  loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : Container(color: const Color(0xFFE8EEE8),
                        child: const Center(child: CircularProgressIndicator())),
                ),
              ),
              Positioned(
                top: 9, right: 9,
                child: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: .95),
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => provider.toggleFavorite(recipe.id),
                    icon: Icon(provider.isFavorite(recipe.id)
                      ? Icons.favorite : Icons.favorite_border,
                      color: provider.isFavorite(recipe.id) ? Colors.redAccent : Colors.black87),
                  ),
                ),
              ),
            ]),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(recipe.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFE5A52D), size: 17),
                  Text(' ${recipe.rating.toStringAsFixed(1)}'),
                  const SizedBox(width: 12),
                  const Icon(Icons.schedule, size: 16, color: Colors.black54),
                  Text(' ${recipe.totalTime} min', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
