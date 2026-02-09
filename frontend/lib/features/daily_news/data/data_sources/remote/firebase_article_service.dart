import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/article.dart';

class FirebaseArticleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ArticleModel>> getArticles() async {
    try {
      final snapshot = await _firestore
          .collection('articles')
          .orderBy('publishedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ArticleModel.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> publishArticle(ArticleModel article) async {
    try {
      await _firestore.collection('articles').add(article.toFirestore());
    } catch (e) {
      rethrow;
    }
  }
}
