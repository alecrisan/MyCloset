import 'package:flutter/material.dart';
import 'package:mycloset_flutter_app/ItemBloc.dart';
import 'package:mycloset_flutter_app/Server.dart';

import 'ClothingItem.dart';

typedef Null ItemSelectedCallback(int value);

class ListWidget extends StatefulWidget {
  final ItemSelectedCallback onItemSelected;
  final ItemBloc bloc;
  ListWidget(
      this.bloc,
      this.onItemSelected, {Key key}
      ): super(key:key);

  @override
  _ListWidgetState createState() => _ListWidgetState();
}

class _ListWidgetState extends State<ListWidget> {
  ItemProvider db;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<List<ClothingItem>>(
            stream: widget.bloc.items,
            builder: (BuildContext context,
                AsyncSnapshot<List<ClothingItem>> snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, position) {
                    final item = snapshot.data[position];
                    final title = item.name;
                    return Dismissible(
//                  key: Key(item.title),
                        key: Key(UniqueKey().toString()),
                        onDismissed: (direction) {
                          setState(() {
                            if (!Server.isReachable) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("You are offline"),
                                    content: Text(
                                        "Please check your internet connection!"),
                                  );
                                },
                              );
                            } else {
                              ClothingItem item = snapshot.data[position];
                              snapshot.data.removeAt(position);
                              widget.bloc.delete(item);
                              Scaffold.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("You removed $title")));
                            }
                          });
                        },
                        background: Container(color: Server.isReachable? Colors.deepPurpleAccent : Colors.red),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            child: InkWell(
                              onTap: () {
                                widget.onItemSelected(position);
                              },
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: RichText(text: TextSpan(
                                          // set the default style for the children TextSpans
                                            style: Theme
                                                .of(context)
                                                .textTheme
                                                .body1
                                                .copyWith(fontSize: 18),
                                            children: [
                                              TextSpan(
                                                  text: item.name,
                                                  style: TextStyle(
                                                      fontSize: 22.0)
                                              ),
                                              TextSpan(
                                                  text: "\nDescription: " +
                                                      item.description,
                                                  style: TextStyle(
                                                      color: Server.isReachable? Colors.deepPurpleAccent : Colors.red
                                                  )
                                              ),
                                            ]
                                        )),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ));
                  },
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            })
    );
  }
}
