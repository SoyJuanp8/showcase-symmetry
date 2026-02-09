import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import '../../models/article.dart';
import '../../models/comment.dart';

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

  Stream<ArticleModel?> getArticleStream(String articleId) {
    return _firestore.collection('articles').doc(articleId).snapshots().map(
        (snapshot) => snapshot.exists
            ? ArticleModel.fromFirestore(snapshot.data()!, snapshot.id)
            : null);
  }

  Future<void> toggleLike(ArticleEntity article, String userId) async {
    final articleId = article.socialId;
    final docRef = _firestore.collection('articles').doc(articleId);

    // Use transaction or simple get/set. Let's use get/set for simplicity
    // but optimized to create if not exists.
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      final model = ArticleModel.fromEntity(article);
      await docRef.set({
        ...model.toFirestore(),
        'likes': [userId],
        'comments': [],
      });
    } else {
      List<dynamic> likes = snapshot.data()?['likes'] ?? [];
      if (likes.contains(userId)) {
        await docRef.update({
          'likes': FieldValue.arrayRemove([userId])
        });
      } else {
        await docRef.update({
          'likes': FieldValue.arrayUnion([userId])
        });
      }
    }
  }

  Future<void> addComment(ArticleEntity article, CommentModel comment) async {
    final articleId = article.socialId;
    final docRef = _firestore.collection('articles').doc(articleId);

    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      final model = ArticleModel.fromEntity(article);
      await docRef.set({
        ...model.toFirestore(),
        'likes': [],
        'comments': [comment.toJson()],
      });
    } else {
      await docRef.update({
        'comments': FieldValue.arrayUnion([comment.toJson()])
      });
    }
  }
}
