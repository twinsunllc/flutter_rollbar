import 'package:flutter/material.dart';
import 'package:flutter_rollbar/flutter_rollbar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    Rollbar()
      ..accessToken = '<post_client_item token>'
      ..environment = 'local'
      ..person = RollbarPerson(id: '3', username: 'A Real Person');
    super.initState();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      Rollbar().addTelemetry(
        RollbarTelemetry(
          level: RollbarLogLevel.INFO,
          type: RollbarTelemetryType.LOG,
          message: 'Counter: $_counter',
        ),
      );
    });
  }

  void _publishReport() async {
    await Rollbar().publishReport(message: 'A Report');
    showDialog(
      context: context,
      builder: (BuildContext context) => Material(
        child: Container(
          padding: MediaQuery.of(context).padding,
          child: Text('Report Submitted!'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline1,
            ),
            ElevatedButton(
              onPressed: _publishReport,
              child: Text('Publish Report'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
