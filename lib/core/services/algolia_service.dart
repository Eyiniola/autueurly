import 'package:algoliasearch/algoliasearch_lite.dart';

class AlgoliaService {
  final SearchClient _client;
  // Iniializing client with application ID and API key
  AlgoliaService() : _client = SearchClient(appId: 'C382RFA65M', apiKey: '32304e5339c5f8a42039c569420883c9');

  Future<List<String>> searchUsers(String query) async {
    final index = _client.initIndex('users');

    final response = await index.search(query);

    if (response.hits.isNotEmpty) {
      final userIds = response.hits.map((hit) => hit.objectID).toList();
      return userIds;
    }
    return [];
  }
}

extension on SearchClient {
  initIndex(String s) {}
}