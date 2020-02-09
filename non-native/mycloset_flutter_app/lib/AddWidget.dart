import 'package:flutter/material.dart';
import 'image_picker.dart';
import 'dart:io';

class AddWidget extends StatefulWidget {
  var myControllerName = TextEditingController();
  var myControllerDescription = TextEditingController();
  var myControllerPhoto = TextEditingController();
  var myControllerSize = TextEditingController();
  var myControllerPrice = TextEditingController();
  var _formKey = GlobalKey<FormState>();

  AddWidget(this.myControllerName, this.myControllerDescription,
      this.myControllerPhoto, this.myControllerSize, this.myControllerPrice, this._formKey);

  @override
  _AddWidgetState createState() => _AddWidgetState();
}

class _AddWidgetState extends State<AddWidget> {
  Future<File> imageFile;
  bool visible = true;

  pickImageFromGallery(ImageSource source) {
    setState(() {
      imageFile = ImagePicker.pickImage(source: source);
    });
  }

  Widget showImage() {
    return FutureBuilder<File>(
      future: imageFile,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          visible = false;
          widget.myControllerPhoto.text = snapshot.data.path;
          print(snapshot.data);
          print(snapshot.data.path);
          return Image.file(snapshot.data, width: 1100, height: 500);
        } else if (snapshot.error != null) {
          return const Text(
            'Error Picking Image',
            textAlign: TextAlign.center,
          );
        } else {
          return const Text(
            '',
            textAlign: TextAlign.center,
          );
        }
      },
    );
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
                      controller: widget.myControllerName,
                      decoration:
                      InputDecoration(labelText: 'Enter item name'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Name cannot be empty!';
                        }
                        return null;
                      }),
                  TextFormField(
                      controller: widget.myControllerDescription,
                      decoration:
                      InputDecoration(labelText: 'Enter item description'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Description cannot be empty!';
                        }
                        return null;
                      }),
                  TextFormField(
                      controller: widget.myControllerSize,
                      decoration:
                      InputDecoration(labelText: 'Enter item size'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Size cannot be empty!';
                        }
                        return null;
                      }),
                  TextFormField(
                      controller: widget.myControllerPrice,
                      decoration:
                      InputDecoration(labelText: 'Enter item price'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Price cannot be empty!';
                        }
                        return null;
                      }),
                ])),
            showImage(),
            GestureDetector(
              onTap: () {
                pickImageFromGallery(ImageSource.gallery);
              },
              child: Visibility(
                child:
                //Image.file(File('/Users/Ale/Library/Developer/CoreSimulator/Devices/8B10418E-D96C-4C25-8C3C-CA314E843F57/data/Containers/Data/Application/109314FC-4964-4EC4-9C81-70B7921BD84E/tmp/image_picker_9EAE8F24-E4B0-4404-B7FD-11E1919EF0AA-20868-0000177CE552A7D3.jpg'),
                Image.asset('assets/defaultPhoto.png',
                    width: 1100, height: 500),
                visible: visible,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
