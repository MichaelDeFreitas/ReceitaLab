import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();
    final favorites = provider.favoriteRecipes;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Minhas favoritas', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text('Receitas salvas neste dispositivo.', style: TextStyle(color: Colors.grey.shade700)),
        const SizedBox(height: 18),
        Expanded(child: favorites.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.favorite_border, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 10),
              const Text('Você ainda não salvou receitas.'),
              const SizedBox(height: 4),
              Text('Toque no coração de uma receita para guardá-la.',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
            ]))
          : GridView.builder(
              itemCount: favorites.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260, mainAxisSpacing: 14,
                crossAxisSpacing: 14, childAspectRatio: .78),
              itemBuilder: (_, index) => RecipeCard(recipe: favorites[index]),
            )),
      ]),
    );
  }
}
