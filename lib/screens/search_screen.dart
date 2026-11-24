import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Buscar receitas', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          onChanged: (value) {
            _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 450),
              () => context.read<RecipeProvider>().search(value));
          },
          decoration: InputDecoration(
            hintText: 'Ex.: pizza, pasta, chicken...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(icon: const Icon(Icons.close),
              onPressed: () { _controller.clear(); context.read<RecipeProvider>().search(''); }),
          ),
        ),
        const SizedBox(height: 18),
        Expanded(child: provider.isSearching
          ? const Center(child: CircularProgressIndicator())
          : provider.searchError != null
            ? Center(child: Text(provider.searchError!))
            : _controller.text.trim().isEmpty
              ? Center(child: Text('Digite o nome de um prato ou ingrediente.',
                  style: TextStyle(color: Colors.grey.shade600)))
              : provider.searchResults.isEmpty
                ? const Center(child: Text('Nenhuma receita encontrada.'))
                : GridView.builder(
                    itemCount: provider.searchResults.length,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 260, mainAxisSpacing: 14,
                      crossAxisSpacing: 14, childAspectRatio: .78),
                    itemBuilder: (_, index) => RecipeCard(recipe: provider.searchResults[index]),
                  )),
      ]),
    );
  }
}
