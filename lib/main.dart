import 'package:flutter/material.dart';
import 'package:puzzle_app/ui/puzzle_screen.dart';



void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puzzle game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyPuzzleScreen(title: "Puzzle game"),
    );
  }
}
