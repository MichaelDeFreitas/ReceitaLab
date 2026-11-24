import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:atividade_1_receita_lab/main.dart';
import 'package:atividade_1_receita_lab/providers/recipe_provider.dart';

void main() {
  testWidgets('ReceitaLab inicia', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => RecipeProvider(),
        child: const RecipeLabApp(),
      ),
    );
    expect(find.text('RECEITALAB'), findsOneWidget);
  });
}
