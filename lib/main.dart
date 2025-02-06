import 'package:flutter/material.dart';
import 'screens/pokemon_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'Pokémon Dex',
      theme: ThemeData(
        primarySwatch: Colors.red,
        textTheme: Theme.of(context).textTheme.apply(
          fontFamily: 'Poppins', 
        ),
      ),
      home: PokemonListScreen(),
    );
  }
}
