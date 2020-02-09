import 'package:sqflite/sqflite.dart';
import 'package:sqflite/utils/utils.dart';

final String tableItems = 'Items';
final String columnId = 'id';
final String columnName = 'name';
final String columnDescription = 'description';
final String columnImage = 'photo';
final String columnSize = 'size';
final String columnPrice = 'price';

class ClothingItem {
  int id;
  String name;
  String description;
  String photo;
  //File photo;
  String size;
  int price;

  ClothingItem(String name, String description, String photo, String size, int price, [int id]) {
    if (id != null)
      this.id = id;
    this.name = name;
    this.description = description;
    this.size = size;
    this.price = price;
    if (photo != null)
      this.photo = photo;
    else
      this.photo = 'assets/defaultPhoto.png';
      //this.photo = File('/Users/Ale/Library/Developer/CoreSimulator/Devices/8B10418E-D96C-4C25-8C3C-CA314E843F57/data/Containers/Data/Application/7F1B4321-3D25-4667-9F3D-D41255C00D79/tmp/image_picker_9EB26256-535C-4DC5-9C3B-177659100099-13081-000013B24EF55C02.jpg');
  }

  ClothingItem.withId(this.id, this.name, this.description, this.photo,
      this.size, this.price);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnName: name,
      columnDescription: description,
      columnImage: photo,
      columnSize: size,
      columnPrice: price
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  ClothingItem.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
    description = map[columnDescription];
    photo = "assets/" + map[columnImage] + ".png";
    size = map[columnSize];
    price = map[columnPrice];
  }

}


class ItemProvider {

    ItemProvider._();

    static final ItemProvider db = ItemProvider._();

    static final database = openDatabase('MyCloset.db', version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
create table if not exists $tableItems ( 
  $columnId integer primary key autoincrement, 
  $columnName text not null,
  $columnDescription text not null,
  $columnImage text not null,
  $columnSize text not null,
  $columnPrice integer not null
  )
''');
          await db.execute('''
create table if not exists ItemsCache ( 
  $columnId integer primary key autoincrement, 
  $columnName text not null,
  $columnDescription text not null,
  $columnImage text not null,
  $columnSize text not null,
  $columnPrice integer not null
  )
''');
        });


    createTables() async {
      final Database db = await database;
      await db.execute('''
create table if not exists $tableItems ( 
  $columnId integer primary key autoincrement, 
  $columnName text not null,
  $columnDescription text not null,
  $columnImage text not null,
  $columnSize text not null,
  $columnPrice integer not null
  )
''');
      await db.execute('''
create table if not exists ItemsCache ( 
  $columnId integer primary key autoincrement, 
  $columnName text not null,
  $columnDescription text not null,
  $columnImage text not null,
  $columnSize text not null,
  $columnPrice integer not null
  )
''');
    }

    Future<int> getLastId() async{
      final Database db = await database;
      return firstIntValue(await db.rawQuery('select max(id) from Items'));
    }

    Future<List<ClothingItem>> items() async {
      final Database db = await database;

      final List<Map<String, dynamic>> maps = await db.query('Items');

      return List.generate(maps.length, (i) {
        return ClothingItem.fromMap(maps[i]);
      });
    }

    Future<List<ClothingItem>> itemsCache() async {
      final Database db = await database;

      final List<Map<String, dynamic>> maps = await db.query('ItemsCache');

      return List.generate(maps.length, (i) {
        return ClothingItem.fromMap(maps[i]);
      });
    }


  Future<ClothingItem> insert(ClothingItem item) async {
  final Database db = await database;
    item.id = await db.insert(tableItems, item.toMap());
    return item;
  }

  Future<ClothingItem> insertCache(ClothingItem item) async {
      final Database db = await database;
      item.id = await db.insert('ItemsCache', item.toMap());
      return item;
    }

    create(ClothingItem item) async {
      final db = await database;
      int index = item.photo.indexOf(".");
      print("insert into ");
      var raw = await db.rawInsert(
          "INSERT INTO Items (name, description, photo, size, price) VALUES (?,?,?,?,?)",
          [item.name, item.description, item.photo.substring(7, index), item.size, item.price]);
      return raw;
    }

    createCache(ClothingItem item) async {
      final db = await database;
      int index = item.photo.indexOf(".");
      print("name cache" + item.name);
      var raw = await db.rawInsert(
          "INSERT INTO ItemsCache (name, description, photo, size, price) VALUES (?,?,?,?,?)",
          [item.name, item.description, item.photo.substring(7, index), item.size, item.price]);
      return raw;
    }


    Future<ClothingItem> getItem(int id) async {
    final Database db = await database;
    List<Map> maps = await db.query(tableItems,
        columns: [columnId, columnName, columnDescription, columnImage, columnSize, columnPrice],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return ClothingItem.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    final Database db = await database;
    return await db.delete(tableItems, where: '$columnId = ?', whereArgs: [id]);
  }
    deleteAll() async {
      final db = await database;
      return db.delete("Items");
    }
    deleteAllCache() async {
      final db = await database;
      return db.delete("ItemsCache");
    }

  Future<int> update(ClothingItem item) async {
    final Database db = await database;
    int index = item.photo.indexOf(".");
    return await db.update(tableItems, ClothingItem.withId(item.id, item.name, item.description, item.photo.substring(7, index), item.size, item.price).toMap(),
        where: '$columnId = ?', whereArgs: [item.id]);
  }

  Future close() async {
    final Database db = await database;
      db.close();
  }
}