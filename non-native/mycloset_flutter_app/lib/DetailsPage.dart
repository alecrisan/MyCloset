import 'package:flutter/material.dart';
import 'package:mycloset_flutter_app/ItemBloc.dart';
import 'package:mycloset_flutter_app/Server.dart';

import 'DetailsWidget.dart';
import 'ClothingItem.dart';

class DetailPage extends StatefulWidget {
  final ClothingItem data;
  final ItemBloc bloc;
  final int id;
  final String name;
  final String description;
  final String size;
  final int price;

  DetailPage(this.data, this.bloc, this.id, this.name, this.description, this.size, this.price);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final _formKey = GlobalKey<FormState>();

  ItemProvider db;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.data.name)),
      body: DetailsWidget(widget.data, _formKey),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_formKey.currentState.validate()) {
//            Navigator.pop(context);
//            this.widget.data.name =
//                DetailsWidget(widget.data, _formKey).data.name;
//            await db.update(widget.data);
            if(Server.isReachable) {
              widget.bloc.update(ClothingItem.withId(this.widget.id, this.widget.name, this.widget.description, "",this.widget.size, this.widget.price), this.widget.data);
              this.widget.data.name = DetailsWidget(widget.data, _formKey).data.name;
              Navigator.pop(context);
            }
            else {
              this.widget.data.name = this.widget.name;
              this.widget.data.description = this.widget.description;
              this.widget.data.size = this.widget.size;
              this.widget.data.price = this.widget.price;

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("You are offline"),
                    content: Text("Please check your internet connection!"),
                  );
                },
              );
            }
          }
        },
        child: Icon(Icons.check),
        backgroundColor: Server.isReachable? Colors.deepPurpleAccent : Colors.red,
      ),
    );
  }
}