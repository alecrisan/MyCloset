import 'dart:async';
import 'package:mycloset_flutter_app/ClothingItem.dart';

import 'Server.dart';

class ItemBloc {
  final itemsController = StreamController<List<ClothingItem>>.broadcast();
  final Server server = new Server();

  get items => itemsController.stream;

  dispose() {
    itemsController.close();
  }

  getItems() async {
    List<ClothingItem> list = await ItemProvider.db.items();
    print("database: "+ list.length.toString());
    if(Server.isReachable) {
      print("GET online");
      List<ClothingItem> list = await server.fetchItems();
      itemsController.sink.add(list);
    }
    else {
      print("GET offline");
      //itemsController.sink.add(await ItemProvider.db.items());
    }
  }

  ItemBloc() {
    getItems();
  }

  delete(ClothingItem item) {
    server.delete(item).then((x) => getItems()).then((x) => ItemProvider.db.delete(item.id));
  }

  add(ClothingItem item) async{
    print("add " + Server.isReachable.toString());
    if(Server.isReachable) {
      server.create(item).then((x) async => await ItemProvider.db.create(item)).then((x) async => await getItems());
    }
    else {
      ItemProvider.db.create(item).then((x) async => await ItemProvider.db.createCache(item)).then((x) async => await getItems());
      getItems();
    }
  }

  update(ClothingItem oldItem, ClothingItem newItem) {
    server.update(oldItem, newItem).then((x) => getItems()).then((x) => ItemProvider.db.update(ClothingItem.withId(oldItem.id, newItem.name,
    newItem.description, newItem.photo, newItem.size, newItem.price)));
  }

  addCache() async {
    print("add to cache:" + Server.isReachable.toString());
    if(Server.isReachable) {
      await synchronize();
      List<ClothingItem> dbItems = await ItemProvider.db.itemsCache();
      print("cache: " + dbItems.length.toString());
      List<ClothingItem> serverItems = await server.fetchItems();
      print("server: " + serverItems.length.toString());
      for(ClothingItem i in dbItems) {
        print(i.name);
        server.create(i).then((x) async => await ItemProvider.db.create(i));
      }
      ItemProvider.db.deleteAllCache();
    }
  }

  synchronize() async {
    if(Server.isReachable) {
      List<ClothingItem> serverItems = await server.fetchItems();
      print("Sync server: " + serverItems.length.toString());
      await ItemProvider.db.deleteAll();
      for(ClothingItem i in serverItems)
        await ItemProvider.db.create(i);
    }
  }
}