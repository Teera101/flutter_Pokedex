
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class PokemonDetailScreen extends StatefulWidget {
  final int pokemonId;

  PokemonDetailScreen({required this.pokemonId});

  @override
  _PokemonDetailScreenState createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  String? pokemonName;
  String? imageUrl;
  List<String> types = [];
  List<Map<String, dynamic>> stats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPokemonDetail();
  }

  Color getStatColor(String stat) {
    switch (stat) {
      case "hp": return Colors.redAccent;
      case "attack": return Colors.orange;
      case "defense": return Colors.deepOrange;
      case "special-attack": return Colors.amber;
      case "special-defense": return Colors.yellow;
      case "speed": return Colors.deepOrangeAccent;
      default: return Colors.grey;
    }
  }

  Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case "fire": return Colors.redAccent;
      case "water": return Colors.blueAccent;
      case "grass": return Colors.green;
      case "electric": return Colors.yellow[700]!;
      case "ice": return Colors.cyanAccent;
      case "fighting": return Colors.orange;
      case "poison": return Colors.purple;
      case "ground": return Colors.brown;
      case "flying": return Colors.indigo;
      case "psychic": return Colors.pinkAccent;
      case "bug": return Colors.lightGreen;
      case "rock": return Colors.grey;
      case "ghost": return Colors.deepPurpleAccent;
      case "dragon": return Colors.deepPurple;
      case "dark": return Colors.black87;
      case "steel": return Colors.blueGrey;
      case "fairy": return Colors.pink;
      default: return Colors.grey;
    }
  }

  int getMinStat(int baseStat) => (baseStat * 2 + 5);
  int getMaxStat(int baseStat) => (baseStat * 2 + 110);

  Future<void> fetchPokemonDetail() async {
    try {
      final response = await http.get(Uri.parse("https://pokeapi.co/api/v2/pokemon/${widget.pokemonId}"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          pokemonName = data['name'].toString().toUpperCase();
          types = List<String>.from(data['types'].map((t) => t['type']['name']));
          stats = List<Map<String, dynamic>>.from(
            data['stats'].map((s) => {
                  "name": s['stat']['name'],
                  "value": s['base_stat'],
                  "min": getMinStat(s['base_stat']),
                  "max": getMaxStat(s['base_stat']),
                }),
          );
          imageUrl = data['sprites']['other']['official-artwork']['front_default'];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load Pokémon data");
      }
    } catch (e) {
      print("Error fetching Pokémon details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pokémon Details", style: GoogleFonts.poppins()),
        backgroundColor: const Color.fromARGB(255, 233, 109, 20),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 58, 125, 68), const Color.fromARGB(255, 157, 192, 139)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: isLoading
              ? CircularProgressIndicator()
              : imageUrl == null
                  ? Text("Failed to load Pokémon data", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          pokemonName ?? "Unknown Pokémon",
                          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 20),
                        Image.network(imageUrl!, width: 200, height: 200),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: types.map((type) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                              decoration: BoxDecoration(
                                color: getTypeColor(type),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                type.toUpperCase(),
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Base Stats",
                          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        Column(
                          children: stats.map((s) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 90,
                                    child: Text(
                                      s['name'].toUpperCase(),
                                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 30,
                                    child: Text(
                                      "${s['value']}",
                                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  SizedBox(
                                    width: 150,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value: s['value'] / 150,
                                        backgroundColor: Colors.grey[700],
                                        color: getStatColor(s['name']),
                                        minHeight: 10,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      "${s['min']}  ${s['max']}",
                                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
