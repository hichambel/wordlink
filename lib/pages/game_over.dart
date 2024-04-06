import 'package:flutter/material.dart';

class CharacterCard extends StatelessWidget {
  final String character;
  final double cardHeight = 70.0;
  final double cardWidth = 70;

  const CharacterCard({required this.character});

    @override
  Widget build(BuildContext context) {
      return Container(
        width: cardWidth,
        height: cardHeight,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), 
            side: BorderSide(color: Colors.black, width: 2.0), 
          ),
          color: Color.fromARGB(255, 111, 206, 142),
          child: Center(
            child: Text(
              character.toUpperCase(),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 40, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }
  }

class GameOver extends StatefulWidget {
  const GameOver({Key? key});

  @override
  _GameOverState createState() => _GameOverState();
}

class _GameOverState extends State<GameOver> {
  bool win = false;
  String language = "ENGLISH"; 

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      win = args['win'] ?? false;
      language = args['language'] ?? "ENGLISH";
    }

    String resultText = win ? (language == "FRANCAIS" ? "GAGNÉ" : "WON") : (language == "FRANCAIS" ? "PERDU" : "LOST");

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: resultText
                        .split("")
                        .map((char) => Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: CharacterCard(character: char),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 100),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 111, 206, 142)),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(color: Colors.black, width: 2.0),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/gamepage', arguments: language);
                    },
                    child: Text(
                      win ? (language == "FRANCAIS" ? "REJOUER" : "PLAY AGAIN") : (language == "FRANCAIS" ? "RÉESSAYER" : "TRY AGAIN"),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 111, 206, 142)),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(color: Colors.black, width: 2.0),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/homepage');
                    },
                    child: Text(
                      win ? (language == "FRANCAIS" ? "RETOUR AU MENU" : "BACK TO MENU") : (language == "FRANCAIS" ? "RETOUR AU MENU" : "BACK TO MENU"),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}