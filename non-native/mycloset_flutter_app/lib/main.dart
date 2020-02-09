import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:mycloset_flutter_app/ItemBloc.dart';
import 'package:mycloset_flutter_app/MainPage.dart';
import 'package:mycloset_flutter_app/Server.dart';

//void main() => runApp(MyApp());
//
//class MyApp extends StatelessWidget {
//  // This widget is the root of your application.
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      title: 'My Closet',
//      theme: ThemeData(
//        // This is the theme of your application.
//        //
//        // Try running your application with "flutter run". You'll see the
//        // application has a blue toolbar. Then, without quitting the app, try
//        // changing the primarySwatch below to Colors.green and then invoke
//        // "hot reload" (press "r" in the console where you ran "flutter run",
//        // or simply save your changes to "hot reload" in a Flutter IDE).
//        // Notice that the counter didn't reset back to zero; the application
//        // is not restarted.
//        primarySwatch: Colors.deepPurple,
//      ),
//      home: MainPage(),
//      debugShowCheckedModeBanner: false,
//    );
//  }
//}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  initState() {
    super.initState();
    ItemBloc().synchronize().then((x) => ItemBloc().addCache()).then((x) =>
        ItemBloc().getItems());
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on Exception catch (e) {
      print(e.toString());
    }
    if (!mounted) {
      return;
    }
    _updateConnectionStatus(result);
  }

  @override
  Widget build(BuildContext context) {
    if (Server.isReachable)
      return MaterialApp(
        title: 'My Closet',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: MainPage(),
        debugShowCheckedModeBanner: false,
      );
    else {
      return MaterialApp(
        title: 'My Closet',
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: MainPage(),
        debugShowCheckedModeBanner: false,
      );
    }
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        setState(() {
          _connectionStatus = '$result';
        });
        break;
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        setState(() => _connectionStatus = result.toString());
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
    if (_connectionStatus == "ConnectivityResult.none")
      Server.isReachable = false;
    else {
      Server.isReachable = true;
      ItemBloc().addCache().then((x) => ItemBloc().getItems());
    }
  }
}
