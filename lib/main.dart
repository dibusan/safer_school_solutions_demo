import 'package:flutter/material.dart';
import 'package:sss/util.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, dynamic> data = {};

  @override
  void initState() {
    getData().then((value) {
      setState(() {
        data = aggregateData(value);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Safer School Solutions"),
      ),
      body: Center(child: data.isEmpty
          ? const CircularProgressIndicator()
          : Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                pieChart(data['responsesByQuestion']),
                barChart(data['responsesByUser']),
              ],
            ),),
    );
  }
}
