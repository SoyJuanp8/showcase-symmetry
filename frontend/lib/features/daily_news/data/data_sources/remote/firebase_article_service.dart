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
          .map((doc) => ArticleModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ArticleModel>> getArticlesByUserId(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('articles')
          .where('userId', isEqualTo: userId)
          .get();

      final articles = snapshot.docs
          .map((doc) => ArticleModel.fromFirestore(doc.data(), doc.id))
          .toList();

      // Sort client-side to avoid composite index requirement
      articles.sort((a, b) {
        final dateA = a.publishedAt ?? '';
        final dateB = b.publishedAt ?? '';
        return dateB.compareTo(dateA); // Descending order
      });

      return articles;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ArticleModel>> searchArticles(String query) async {
    try {
      // Client-side filtering because Firestore doesn't support full-text search locally
      final allArticles = await getArticles();
      return allArticles.where((article) {
        final title = article.title?.toLowerCase() ?? '';
        final description = article.description?.toLowerCase() ?? '';
        final q = query.toLowerCase();
        return title.contains(q) || description.contains(q);
      }).toList();
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

  Future<void> editArticle(ArticleModel article) async {
    try {
      if (article.firebaseId != null) {
        await _firestore
            .collection('articles')
            .doc(article.firebaseId)
            .update(article.toFirestore());
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteArticle(String firebaseId) async {
    try {
      await _firestore.collection('articles').doc(firebaseId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
