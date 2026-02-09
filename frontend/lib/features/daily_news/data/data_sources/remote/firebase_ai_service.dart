import 'package:firebase_vertexai/firebase_vertexai.dart';

class FirebaseAIService {
  final FirebaseVertexAI _vertexAI = FirebaseVertexAI.instance;

  Future<String?> summarizeArticle(String content) async {
    try {
      final model = _vertexAI.generativeModel(
        model: 'gemini-2.0-flash',
        generationConfig: GenerationConfig(temperature: 0.2),
      );

      final prompt = '''
        Act as an expert journalist. 
        Summarize the following news article in a concise paragraph of maximum 3 sentences.
        Use a neutral and professional tone.
        
        Article:
        $content
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      print('DEBUG: FIREBASE AI SERVICE ERROR -> $e');
      rethrow;
    }
  }

  Future<String?> askQuestionAboutArticle(
      String content, String question) async {
    try {
      final model = _vertexAI.generativeModel(
        model: 'gemini-2.0-flash',
        generationConfig: GenerationConfig(temperature: 0.3),
      );

      final prompt = '''
        Act as an expert journalist. 
        Answer the following question based ONLY on the provided article content.
        If the information is not in the article, state that it's not mentioned.
        Keep the answer concise (maximum 3-4 sentences or a short list).
        
        Question: $question
        
        Article:
        $content
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      print('DEBUG: FIREBASE AI SERVICE ERROR (Question) -> $e');
      rethrow;
    }
  }
}
