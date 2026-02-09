abstract class RemoteArticlesEvent {
  const RemoteArticlesEvent();
}

class GetArticles extends RemoteArticlesEvent {
  const GetArticles();
}

class SearchArticles extends RemoteArticlesEvent {
  final String query;
  const SearchArticles(this.query);
}
