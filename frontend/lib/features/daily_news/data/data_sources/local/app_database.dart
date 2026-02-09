import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/article_dao.dart';
import '../../models/article.dart';
import 'converters/source_type_converter.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'dart:async';
part 'app_database.g.dart';

@TypeConverters([SourceTypeConverter])
@Database(version: 2, entities: [ArticleModel])
abstract class AppDatabase extends FloorDatabase {
  ArticleDao get articleDAO;
}

final migration1to2 = Migration(1, 2, (database) async {
  await database.execute('ALTER TABLE article ADD COLUMN savedAt TEXT');
});
