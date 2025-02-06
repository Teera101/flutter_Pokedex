import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pokemon_detail.dart';
import 'package:google_fonts/google_fonts.dart';

class PokemonListScreen extends StatefulWidget {
  @override
  _PokemonListScreenState createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  List<dynamic> pokemonList = [];
  String nextUrl = "https://pokeapi.co/api/v2/pokemon?limit=30";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchPokemon();
  }

  Future<void> fetchPokemon() async {
    if (isLoading || nextUrl.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(nextUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          pokemonList.addAll(data['results']);
          nextUrl = data['next'] ?? "";
        });
      } else {
        throw Exception("Failed to load Pokémon data");
      }
    } catch (e) {
      print("Error fetching Pokémon list: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<String>> fetchPokemonTypes(int pokemonId) async {
    final response = await http.get(Uri.parse("https://pokeapi.co/api/v2/pokemon/$pokemonId"));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<String>.from(data['types'].map((t) => t['type']['name']));
    }
    return [];
  }

  int getPokemonId(String url) {
    List<String> parts = url.split('/');
    return int.parse(parts[parts.length - 2]);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pokédex", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 223, 109, 20),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 58, 125, 68), const Color.fromARGB(255, 157, 192, 139)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
            crossAxisSpacing: 12, 
            mainAxisSpacing: 12, 
            childAspectRatio: 0.85, 
          ),
          itemCount: pokemonList.length + 1,
          itemBuilder: (context, index) {
            if (index == pokemonList.length) {
              return nextUrl.isEmpty
                  ? SizedBox.shrink()
                  : Center(child: CircularProgressIndicator());
            }

            var pokemon = pokemonList[index];
            int pokemonId = getPokemonId(pokemon['url']);

            return FutureBuilder<List<String>>(
              future: fetchPokemonTypes(pokemonId),
              builder: (context, snapshot) {
                List<String> types = snapshot.data ?? [];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PokemonDetailScreen(pokemonId: pokemonId),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 6,
                    shadowColor: Colors.black26,
                    color: const Color.fromARGB(255, 248, 245, 233).withOpacity(0.95),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokemonId.png",
                          width: 120,
                          height: 120,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: 80),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "#$pokemonId",
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                        Text(
                          pokemon['name'].toUpperCase(),
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: types.map((type) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                color: getTypeColor(type),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                type.toUpperCase(),
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchPokemon,
        child: isLoading ? CircularProgressIndicator(color: Colors.white) : Icon(Icons.add),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}