import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String appLanguage = "FRANCAIS";
  String gameLanguage = "FRANCAIS";

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildTitleWidget(),
                const SizedBox(height: 100),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromARGB(255, 111, 206, 142),
                    ),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, 
                        side: BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/gamepage', arguments: gameLanguage);
                  },
                  child: Text(
                    gameLanguage == "FRANCAIS" ? "DÉMARRER" : "START GAME",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 100),
                buildLanguageDropdown(
                  gameLanguage == "FRANCAIS" ? "Langue" : "Language",
                  ["FRANCAIS", "ENGLISH"],
                  (value) {
                    setState(() {
                      gameLanguage = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTitleWidget() {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var char in "Word".split(''))
                buildCharacterCard(char),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var char in "Link".split(''))
                buildCharacterCard(char),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget buildCharacterCard(String character) {
    return Container(
      width: 70,
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 111, 206, 142),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
      ),
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
    );
  }

  Widget buildLanguageDropdown(
      String title, List<String> options, void Function(String?) onChanged) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
        DropdownButton<String>(
          dropdownColor: Color.fromARGB(255, 189, 240, 202),
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
          value: gameLanguage,
        ),
      ],
    );
  }
}
