import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key, required this.recipeId});
  final int recipeId;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late Future<Recipe?> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<RecipeProvider>().loadRecipe(widget.recipeId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();
    return Scaffold(
      body: FutureBuilder<Recipe?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final recipe = snapshot.data;
          if (recipe == null) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Não foi possível carregar os detalhes da receita.'),
                const SizedBox(height: 12),
                FilledButton(onPressed: () => setState(() {
                  _future = context.read<RecipeProvider>().loadRecipe(widget.recipeId);
                }), child: const Text('Tentar novamente')),
              ]),
            ));
          }
          return CustomScrollView(slivers: [
            SliverAppBar(
              expandedHeight: 280, pinned: true,
              actions: [
                IconButton(
                  onPressed: () => provider.toggleFavorite(recipe.id),
                  icon: Icon(provider.isFavorite(recipe.id) ? Icons.favorite : Icons.favorite_border,
                    color: provider.isFavorite(recipe.id) ? Colors.red : Colors.white),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(recipe.image, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.green.shade100)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.name, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  Wrap(spacing: 14, runSpacing: 8, children: [
                    _Info(icon: Icons.star, text: recipe.rating.toStringAsFixed(1)),
                    _Info(icon: Icons.schedule, text: '${recipe.totalTime} min'),
                    _Info(icon: Icons.people_alt_outlined, text: '${recipe.servings} porções'),
                    _Info(icon: Icons.local_fire_department_outlined, text: '${recipe.caloriesPerServing} kcal'),
                  ]),
                  const SizedBox(height: 14),
                  Text('${recipe.cuisine} • ${recipe.difficulty}',
                    style: TextStyle(color: Colors.grey.shade700)),
                  const SizedBox(height: 26),
                  const Text('Ingredientes', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  ...recipe.ingredients.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Icon(Icons.check_circle, color: Color(0xFF39765B), size: 19),
                      const SizedBox(width: 9),
                      Expanded(child: Text(item)),
                    ]),
                  )),
                  const SizedBox(height: 24),
                  const Text('Modo de preparo', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  ...recipe.instructions.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      CircleAvatar(radius: 14, backgroundColor: const Color(0xFFE2EEE5),
                        child: Text('${entry.key + 1}', style: const TextStyle(
                          color: Color(0xFF39765B), fontWeight: FontWeight.bold))),
                      const SizedBox(width: 10),
                      Expanded(child: Text(entry.value, style: const TextStyle(height: 1.45))),
                    ]),
                  )),
                ],
              )),
            ),
          ]);
        },
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 17, color: const Color(0xFF39765B)),
    const SizedBox(width: 4),
    Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
  ]);
}
