import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pokemon/pokemon.dart';
import 'package:pokemon/pokemondetail.dart';
import 'package:shimmer/shimmer.dart';

void main() => runApp(MaterialApp(
      title: "Pokemon",
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    ));

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  var url =
      "https://raw.githubusercontent.com/Biuni/PokemonGO-Pokedex/master/pokedex.json";
  PokeHub pokeHub;
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _animation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  var bool = true;
  getMessage()=>bool?"doğru":"yanlış";


  fetchData() async {
    var res = await http.get(url);
    var decodedJson = jsonDecode(res.body);
    print(res.body);
    pokeHub = PokeHub.fromJson(decodedJson);
    setState(() {
      _controller.forward();
    });
  }

  pokeGrid() => GridView.count(
        crossAxisCount: 2,
        children: pokeHub.pokemon
            .map((poke) => Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PokeDetail(poke)));
                    },
                    child: FadeTransition(
                      opacity: _animation,
                      child: Hero(
                        tag: poke.img,
                        child: Card(
                          elevation: 3.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                height: 100,
                                width: 100,
                                child: CachedNetworkImage(
                                  imageUrl: poke.img,),
                              ),
                              Text(
                                poke.name,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ))
            .toList(),
      );

  shimmerGrid() => GridView.count(
        crossAxisCount: 2,
        children: List.generate(10, (index) {
          return Card(
            elevation: 3.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FadeTransition(
                  opacity: _animation,
                  child: Shimmer.fromColors(
                    period: Duration(seconds: 1),
                    baseColor: Colors.grey[700],
                    highlightColor: Colors.grey[100],
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                Shimmer.fromColors(
                  period: Duration(seconds: 1),
                  baseColor: Colors.grey[700],
                  highlightColor: Colors.grey[100],
                  child: Container(
                    height: 30,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )
              ],
            ),
          );
        }),
      );

  @override
  Widget build(BuildContext context) {
    _controller.forward();
    return Scaffold(
      appBar: AppBar(
        title: Text("Pokemon"),
        backgroundColor: Colors.cyan,
      ),
      body: pokeHub == null
          ? FadeTransition(opacity: _animation, child: shimmerGrid())
          : FadeTransition(opacity: _animation, child: pokeGrid()),
      drawer: Drawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.forward();
            pokeHub = null;
            fetchData();
          });
        },
        backgroundColor: Colors.cyan,
        child: Icon(Icons.refresh),
      ),
    );
  }
}
