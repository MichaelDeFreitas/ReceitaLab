# ReceitaLab 🍃

Aplicativo Flutter de receitas integrado à API pública [DummyJSON Recipes](https://dummyjson.com/docs/recipes).

## Funcionalidades

- Catálogo de receitas com imagem, avaliação, tempo de preparo e nome.
- Tela de detalhes com ingredientes, instruções, porções e informações adicionais.
- Busca de receitas por texto.
- Filtro por tags/categorias.
- Favoritos salvos localmente no dispositivo.
- Estados de carregamento, erro e lista vazia.
- Tradução automática dos nomes, ingredientes e instruções para português, com cache local.

## Endpoints utilizados

| Método | Endpoint | Uso |
|---|---|---|
| GET | `/recipes` | Catálogo de receitas |
| GET | `/recipes/{id}` | Detalhes da receita |
| GET | `/recipes/search?q={termo}` | Busca |
| GET | `/recipes/tags` | Lista de tags |
| GET | `/recipes/tag/{tag}` | Receitas por tag |

## Tecnologias e organização

- Flutter e Dart
- Dio para requisições HTTP
- Provider para gerenciamento de estado
- SharedPreferences para persistência dos favoritos
- Google Fonts

O código está separado em `models`, `services`, `providers`, `screens`, `widgets` e `theme`.

## Como executar

1. Instale Flutter e Android Studio.
2. Abra a pasta do projeto no Android Studio.
3. No terminal, dentro da pasta do projeto, execute:

```bash
flutter pub get
flutter doctor
flutter devices
flutter run
```

É necessária conexão com a internet para consultar a API e obter traduções automáticas. Não é necessário token ou chave de API. Se o serviço de tradução estiver indisponível, o aplicativo mantém o texto original e continua funcionando.

## Publicar no GitHub

Crie um repositório vazio no GitHub, sem README, licença ou `.gitignore` inicial. Depois, no terminal do Android Studio, dentro da pasta `atividade_1_receita_lab`, execute:

```bash
git init
git add .
git commit -m "feat: implementa aplicativo ReceitaLab"
git branch -M main
git remote add origin https://github.com/SEU-USUARIO/SEU-REPOSITORIO.git
git push -u origin main
```

Substitua a URL de exemplo pela URL HTTPS do seu repositório.

### Atualizar o GitHub depois de novas alterações

```bash
git add .
git commit -m "descreva suas alterações"
git push
```

> Não envie pastas geradas como `build/`, `.dart_tool/`, nem o arquivo `android/local.properties`. O `.gitignore` do projeto já está configurado para ignorar os principais arquivos locais e temporários.

## Observação

Os favoritos são armazenados no aparelho em que o aplicativo está instalado; eles não são sincronizados entre dispositivos.
