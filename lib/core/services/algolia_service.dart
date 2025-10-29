import 'package:algoliasearch/algoliasearch_lite.dart';

class AlgoliaService {
  final SearchClient _client;

  // Initializing client with application ID and API key
  AlgoliaService()
    : _client = SearchClient(
        appId: 'C382RFA65M',
        apiKey: '32304e5339c5f8a42039c569420883c9',
      );

  Future<List<String>> searchUsers(String query) async {
    final response = await _client.searchIndex(
      request: SearchForHits(
        indexName: 'users', // Your Algolia index
        query: query,
      ),
    );

    if (response.hits.isNotEmpty) {
      return response.hits.map((hit) => hit.objectID).toList();
    }
    return [];
  }

  Future<List<String>> searchProjects(String query) async {
    final response = await _client.searchIndex(
      request: SearchForHits(indexName: 'projects', query: query),
    );

    if (response.hits.isNotEmpty) {
      return response.hits.map((hit) => hit.objectID).toList();
    }
    return [];
  }
}
