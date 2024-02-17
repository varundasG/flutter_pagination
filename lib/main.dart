import 'package:flutter/material.dart';
import 'package:assesment_app/widgets/discovery_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Demo App",
      home: DiscoveryPage(),
    );
  }
}
