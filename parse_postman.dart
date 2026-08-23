import 'dart:convert';
import 'dart:io';

void main() async {
  final file = File('lib/constants/El Arbol.postman_collection.json');
  final jsonString = await file.readAsString();
  final data = jsonDecode(jsonString);

  final fullAuth = (data['item'] as List).firstWhere((e) => e['name'] == 'Full Authentication');
  final auth = (fullAuth['item'] as List).firstWhere((e) => e['name'] == 'Authentication');
  final userAuth = (auth['item'] as List).firstWhere((e) => e['name'] == 'User Authentication');
  final profileMgmt = (userAuth['item'] as List).firstWhere((e) => e['name'] == 'Profile Management');

  void printEndpoints(List items, String prefix) {
    for (var item in items) {
      if (item.containsKey('request')) {
        final request = item['request'];
        final method = request['method'];
        final url = request['url']['raw'] ?? request['url'];
        print('$prefix- ${item['name']}: $method $url');
      } else if (item.containsKey('item')) {
        print('$prefix[Folder] ${item['name']}');
        printEndpoints(item['item'], prefix + '  ');
      }
    }
  }

  printEndpoints(profileMgmt['item'], '');
}
