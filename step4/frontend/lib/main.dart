import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

void main() => runApp(const RecommenderDemo());

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileScreenLayout;
  final Widget webScreenLayout;

  const ResponsiveLayout({
    Key? key,
    required this.mobileScreenLayout,
    required this.webScreenLayout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Retornar diseño para web
      return webScreenLayout;
    } else {
      // Retornar diseño para móvil
      return mobileScreenLayout;
    }
  }
}

class RecommenderDemo extends StatefulWidget {
  const RecommenderDemo({Key? key}) : super(key: key);

  @override
  _RecommenderDemoState createState() => _RecommenderDemoState();
}

class _RecommenderDemoState extends State<RecommenderDemo> {
  late List<String> _movieList;
  final TextEditingController _userIDController = TextEditingController();
  late String _server;
  late Future<List<String>> _futureRecommendations;

  @override
  void initState() {
    super.initState();
    _futureRecommendations = recommend();
  }

  Future<List<String>> recommend() async {
    if (!kIsWeb && Platform.isAndroid) {
      // For Android emulator
      _server = '10.0.2.2';
    } else {
      // For iOS emulator, desktop and web platforms
      _server = '127.0.0.1';
    }

    final response = await http.post(
      Uri.parse('http://' + _server + ':5000/recommend'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'user_id': _userIDController.text,
      }),
    );

// Manejando errores

    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body)['movies']);
    } else {
      throw Exception('Error de respuesta');
    }
  }

  @override
  Widget build(BuildContext context) {
    const title = 'Flutter Movie Recommendation Demo';

    return MaterialApp(
      title: title,
      theme: ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(title),
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _userIDController,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          hintText: 'Introduzca el ID de Usuario',
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _futureRecommendations = recommend();
                          });
                        },
                        child: const Text('Recomiendame Peliculas'),
                      ),
                    ),
                  ],
                ),
                FutureBuilder<List<String>>(
                  future: _futureRecommendations,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      _movieList = snapshot.data!;
                      return Expanded(
                        child: ListView.builder(
                          itemCount: _movieList.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(_movieList[index]),
                            );
                          },
                        ),
                      );
                    } else {
                      return const Text('No data');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
