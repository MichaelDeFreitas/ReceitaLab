import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import 'favorites_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [_CatalogTab(), SearchScreen(), FavoritesScreen()];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _tab, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Buscar'),
          NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Favoritos'),
        ],
      ),
    );
  }
}

class _CatalogTab extends StatelessWidget {
  const _CatalogTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();
    return CustomScrollView(slivers: [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
        sliver: SliverToBoxAdapter(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('RECEITALAB', style: TextStyle(letterSpacing: 2.2,
              fontWeight: FontWeight.w900, color: Color(0xFF39765B))),
            const SizedBox(height: 8),
            const Text('O que vamos cozinhar hoje?',
              style: TextStyle(fontSize: 27, height: 1.15, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('Encontre inspiração para sua próxima refeição.',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
            const SizedBox(height: 20),
            if (provider.tags.isNotEmpty) SizedBox(
              height: 42,
              child: ListView(scrollDirection: Axis.horizontal, children: [
                Padding(padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(label: const Text('Todas'),
                    selected: provider.selectedTag == null,
                    onSelected: (_) => provider.filterByTag(null))),
                ...provider.tags.take(12).map((tag) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(label: Text(tag),
                    selected: provider.selectedTag == tag,
                    onSelected: (_) => provider.filterByTag(tag)),
                )),
              ]),
            ),
            const SizedBox(height: 10),
            const Text('Receitas para você', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ],
        )),
      ),
      if (provider.isLoading)
        const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
      else if (provider.errorMessage != null)
        SliverFillRemaining(child: _ErrorView(message: provider.errorMessage!,
          onRetry: provider.loadRecipes))
      else if (provider.recipes.isEmpty)
        const SliverFillRemaining(child: Center(child: Text('Nenhuma receita encontrada.')))
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) => RecipeCard(recipe: provider.recipes[index]),
              childCount: provider.recipes.length,
            ),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260, mainAxisSpacing: 14, crossAxisSpacing: 14,
              childAspectRatio: .78,
            ),
          ),
        ),
    ]);
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(24),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.wifi_off, size: 42),
      const SizedBox(height: 12),
      Text(message, textAlign: TextAlign.center),
      const SizedBox(height: 12),
      FilledButton(onPressed: onRetry, child: const Text('Tentar novamente')),
    ]),
  ));
}
