import 'package:flutter/material.dart';
import 'package:mycloset_flutter_app/ItemBloc.dart';
import 'package:mycloset_flutter_app/Server.dart';

import 'AddWidget.dart';
import 'ClothingItem.dart';

class AddPage extends StatefulWidget {
  final ItemBloc bloc;
  AddPage(this.bloc);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final myControllerName = TextEditingController();
  final myControllerDescription = TextEditingController();
  final myControllerPhoto = TextEditingController();
  final myControllerSize = TextEditingController();
  final myControllerPrice = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  ItemProvider db;

  @override
  void dispose() {
    myControllerName.dispose();
    myControllerDescription.dispose();
    myControllerSize.dispose();
    myControllerPrice.dispose();
    myControllerPhoto.dispose();
    super.dispose();
  }

  _onSubmit(id){
    setState(() {

      if (myControllerPhoto.text.isNotEmpty)
        this.widget.bloc.add(ClothingItem.withId(id + 1, myControllerName.text,
            myControllerDescription.text, myControllerPhoto.text, myControllerSize.text, int.parse(myControllerPrice.text)));
      else
        this.widget.bloc.add(ClothingItem.withId(id + 1, myControllerName.text,
            myControllerDescription.text,'assets/defaultPhoto.png',
            myControllerSize.text, int.parse(myControllerPrice.text)));

    });
  }

  _insertIntoDb() async{
    if(myControllerPhoto.text.isNotEmpty) {
      await db.insert(ClothingItem(myControllerName.text,
          myControllerDescription.text, myControllerPhoto.text,
          myControllerSize.text, int.parse(myControllerPrice.text)));
    }
    else{
      await db.insert(ClothingItem(myControllerName.text,
          myControllerDescription.text, 'assets/defaultPhoto.png',
          myControllerSize.text, int.parse(myControllerPrice.text)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("New clothing item")),
      body: AddWidget(myControllerName, myControllerDescription,
          myControllerPhoto, myControllerSize, myControllerPrice, _formKey),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            //_insertIntoDb();
            int id = await ItemProvider.db.getLastId();
            _onSubmit(id);
          }
          Navigator.pop(context);
        },
        child: Icon(Icons.check),
        backgroundColor: Server.isReachable? Colors.deepPurpleAccent : Colors.red,
      ),
    );
  }
}
