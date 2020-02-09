import 'package:connectivity/connectivity.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mycloset_flutter_app/ItemBloc.dart';
import 'package:web_socket_channel/io.dart';

import 'ClothingItem.dart';

class Server {
  String server = "http://localhost:8080/item";
  static bool isReachable = false;
  Server();

  static checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    } else {
      return true;
    }
  }

  List<ClothingItem> parseItems(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<ClothingItem>((json) => ClothingItem.fromMap(json)).toList();
  }

  Future<List<ClothingItem>> fetchItems() async {
    final response = await http.get(server);
    if (response.statusCode == 200) {
      return parseItems(response.body);
    } else {
      throw Exception('GET failed!');
    }
  }

  create(ClothingItem item) async {
    Map<String, String> headers = {"Content-type": "application/json", "Accept": "application/json"};
    print(item.id);
    int index = item.photo.indexOf(".");
    final response = await http.post(server, headers: headers, body: json.encode({
      "id" : item.id,
      "name": item.name,
      "description" : item.description,
      "photo": item.photo.substring(7, index),
      "size": item.size,
      "price": item.price
    }));
    if(response.statusCode != 200)
      throw Exception('POST failed!');
  }

  delete(ClothingItem item) async {
    var s = server + "/" + item.id.toString();
    final response = await http.delete(s);
    if(response.statusCode != 200)
      throw Exception('DELETE failed!');
  }

  update(ClothingItem oldItem, ClothingItem item) async {
    var s = server + "/" + oldItem.id.toString();
    s.replaceAll(" ", "%20");
    int index = item.photo.indexOf(".");
    Map<String, String> headers = {"Content-type": "application/json", "Accept": "application/json"};
    final response = await http.put(s, headers: headers, body: json.encode({
      "name": item.name,
      "description": item.description,
      "photo": item.photo.substring(7, index),
      "size": item.size,
      "price": item.price
    }));
    if(response.statusCode != 200)
      throw Exception('PUT failed!');
  }
}

class WebSocketListener {
  void init() {
    var channel = IOWebSocketChannel.connect('ws://localhost:8080');
    channel.sink.add('I am connected!');
    channel.stream.listen((message) {
      ItemBloc().getItems();
    });
  }
}