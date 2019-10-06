import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Trip photo widget template
    Widget tripPhotos = new StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('photos').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return new Text(
                'Error in receiving trip photos: ${snapshot.error}');
          }

          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return new Text('Not connected to the Stream or null');

            case ConnectionState.waiting:
              return new Text('Awaiting for interaction');

            case ConnectionState.active:
              print("Stream has started but not finished");

              var totalPhotosCount = 0;
              List<DocumentSnapshot> tripPhotos;

              if (snapshot.hasData) {
                tripPhotos = snapshot.data.documents;
                totalPhotosCount = tripPhotos.length;

                if (totalPhotosCount > 0) {
                  return new GridView.builder(
                      itemCount: totalPhotosCount,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      primary: false,
                      gridDelegate:
                      new SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2),
                      itemBuilder: (BuildContext context, int index) {
                        return Center(
                          child: Card(
                            child: InkWell(
                              splashColor: Colors.blue.withAlpha(30),
                              onTap: () {
                                print('Tapped on thumbnail.');
                                print(
                                    'Photo doc id: ${tripPhotos[index].documentID}');
                              },
                              child: Container(
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        ClipRect(
                                          child: Align(
                                              alignment: Alignment.topCenter,
                                              heightFactor: 0.7,
                                              child: new CachedNetworkImage(
                                                placeholder: (context, url) =>
                                                new CircularProgressIndicator(),
                                                imageUrl:
                                                tripPhotos[index].data['url'],
                                              )),
                                        ),
                                      ])),
                            ),
                          ),
                        );
                      });
                }
              }

              return new Center(
                  child: Column(
                    children: <Widget>[
                      new Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                      ),
                      new Text(
                        "No trip photos found.",
                        style: Theme.of(context).textTheme.title,
                      )
                    ],
                  ));

            case ConnectionState.done:
              return new Text('Streaming is done');
          }

          return Container(
            child: new Text("No trip photos found."),
          );
        });

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: new Container(
        child: new Column(
          children: <Widget>[
            tripPhotos,
          ],
        ),
      ),
    );
  }
}
