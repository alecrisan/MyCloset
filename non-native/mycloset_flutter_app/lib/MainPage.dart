import 'package:flutter/material.dart';
import 'package:mycloset_flutter_app/Server.dart';
import 'package:sqflite/sqflite.dart';


import 'AddPage.dart';
import 'DetailsPage.dart';
import 'DetailsWidget.dart';
import 'ClothingItem.dart';
import 'package:mycloset_flutter_app/ItemBloc.dart';
import 'ListWidget.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var selectedValue = 0;
  var isLargeScreen = false;
  final _formKey = GlobalKey<FormState>();
  ItemProvider provider;

  final bloc = ItemBloc();
  List<ClothingItem> data = <ClothingItem>[];

  _MainPageState()
  {
    //openDb();
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
  
  void openDb() async
  {
    final Database db = await ItemProvider.database;
    if (db.isOpen)
      data = await provider.items();
    else
      print("error open");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Closet'),
          actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                bloc.synchronize().then((x) => bloc.getItems()).then((x) => build(context));
              },
            ),
          ]),
      body: OrientationBuilder(builder: (context, orientation) {
        if (MediaQuery.of(context).size.width > 600) {
          isLargeScreen = true;
        } else {
          isLargeScreen = false;
        }

        return Row(children: <Widget>[
          Expanded(
              child: StreamBuilder<List<ClothingItem>>(
                stream: bloc.items,
                builder: (BuildContext context, AsyncSnapshot<List<ClothingItem>> snapshot) {
                  if(snapshot.hasData)
                    data = snapshot.data;
                  return ListWidget(bloc, (value) {
                    if (isLargeScreen) {
                      selectedValue = value;
                      setState(() {});
                    } else {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return DetailPage(data[value], bloc, data[value].id, data[value].name, data[value].description, data[value].size, data[value].price);
                        },
                      ));
                    }
                  });},
              )),
          isLargeScreen
              ? Expanded(child: DetailsWidget(data[selectedValue], _formKey))
              : Container(),
        ]);
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return AddPage(bloc);
            },
          ));
        },
        child: Icon(Icons.add),
        backgroundColor: Server.isReachable? Colors.deepPurpleAccent : Colors.red,
      ),
    );
  }
}
