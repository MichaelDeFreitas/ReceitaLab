import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tradução automática inglês <-> português usando o endpoint público do Google.
/// O cache local evita repetir traduções já realizadas.
class TranslationService {
  TranslationService()
      : _dio = Dio(BaseOptions(
          baseUrl: 'https://translate.googleapis.com',
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ));

  final Dio _dio;
  final Map<String, String> _memoryCache = {};

  Future<String> toPortuguese(String text) => _translate(text, 'en', 'pt');
  Future<String> toEnglish(String text) => _translate(text, 'pt', 'en');

  Future<String> _translate(String text, String source, String target) async {
    final original = text.trim();
    if (original.isEmpty) return text;
    final cacheKey = 'recipe_translation_${source}_${target}_${base64Url.encode(utf8.encode(original))}';
    if (_memoryCache.containsKey(cacheKey)) return _memoryCache[cacheKey]!;

    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(cacheKey);
      if (saved != null && saved.isNotEmpty) {
        _memoryCache[cacheKey] = saved;
        return saved;
      }

      final response = await _dio.get('/translate_a/single', queryParameters: {
        'client': 'gtx',
        'sl': source,
        'tl': target,
        'dt': 't',
        'q': original,
      });
      final data = response.data;
      if (data is List && data.isNotEmpty && data[0] is List) {
        final translated = (data[0] as List)
            .whereType<List>()
            .map((part) => part.isNotEmpty ? part[0]?.toString() ?? '' : '')
            .join()
            .trim();
        if (translated.isNotEmpty) {
          _memoryCache[cacheKey] = translated;
          await prefs.setString(cacheKey, translated);
          return translated;
        }
      }
    } catch (_) {
      // A tela continua funcionando com o texto original se a tradução falhar.
    }
    return original;
  }

  Future<List<String>> toPortugueseList(List<String> texts) async {
    final results = <String>[];
    // Limita as requisições simultâneas para não sobrecarregar o serviço gratuito.
    for (var i = 0; i < texts.length; i += 4) {
      final end = (i + 4 < texts.length) ? i + 4 : texts.length;
      results.addAll(await Future.wait(texts.sublist(i, end).map(toPortuguese)));
    }
    return results;
  }
}
