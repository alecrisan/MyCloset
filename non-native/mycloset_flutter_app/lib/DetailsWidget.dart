import 'package:flutter/material.dart';

import 'ClothingItem.dart';

class DetailsWidget extends StatefulWidget {
  final ClothingItem data;
  var _formKey = GlobalKey<FormState>();

  DetailsWidget(this.data, this._formKey);

  @override
  _DetailsWidgetState createState() => _DetailsWidgetState();
}

class _DetailsWidgetState extends State<DetailsWidget> {
  TextEditingController myControllerName;
  TextEditingController myControllerDescription;
  TextEditingController myControllerSize;
  TextEditingController myControllerPrice;

  ItemProvider db;

  @override
  void initState() {
    super.initState();
    myControllerName = TextEditingController(text: widget.data.name);
    myControllerDescription =
        TextEditingController(text: widget.data.description);
    myControllerSize =
        TextEditingController(text: widget.data.size);
    myControllerPrice =
        TextEditingController(text: widget.data.price.toString());
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Form(
                key: widget._formKey,
                child: Column(children: <Widget>[
                  TextFormField(
                    controller: myControllerName,
                    decoration: InputDecoration(
                        labelText: "Name", hintText: "Edit Item Name"),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Name cannot be empty!';
                      }
                      this.widget.data.name = myControllerName.text;
                      return null;
                    },
                  ),
                  TextFormField(
                      controller: myControllerDescription,
                      decoration: InputDecoration(
                          labelText: "Description",
                          hintText: "Edit Item Description"),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Description cannot be empty!';
                        }
                        this.widget.data.description =
                            myControllerDescription.text;
                        return null;
                      }),
                  TextFormField(
                      controller: myControllerSize,
                      decoration: InputDecoration(
                          labelText: "Size",
                          hintText: "Edit Item Size"),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Size cannot be empty!';
                        }
                        this.widget.data.size =
                            myControllerSize.text;
                        return null;
                      }),
                  TextFormField(
                      controller: myControllerPrice,
                      decoration: InputDecoration(
                          labelText: "Price",
                          hintText: "Edit Item Price"),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Price cannot be empty!';
                        }
                        this.widget.data.price =
                            int.parse(myControllerPrice.text);
                        return null;
                      }),

                ])),
            Container(
                width: 800, height: 400, child: Image.asset(this.widget.data.photo)),
          ],
        ),
      ),
    );
  }
}
