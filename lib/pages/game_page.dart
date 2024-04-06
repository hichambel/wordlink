import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:confetti/confetti.dart';

class ShakeAnimationWidget extends StatefulWidget {
  final Widget child;

  const ShakeAnimationWidget({Key? key, required this.child}) : super(key: key);

  @override
  _ShakeAnimationWidgetState createState() => _ShakeAnimationWidgetState();
}

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
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }
  }


class _ShakeAnimationWidgetState extends State<ShakeAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    setState(() {
      _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void shake() {
    _controller
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_controller.value * 10, 0),
          child: widget.child,
        );
      },
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({Key? key});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with SingleTickerProviderStateMixin {
  late Timer _timer;
  int _start = 120;
  final TextEditingController _textEditingController = TextEditingController();
  List<String> enteredWords = [];
  List<String> dictionary = [];
  List<String> answers = [];
  bool isInvalidAnswer = false;
  String language = "";
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    resetGameState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args != null && args is String) {
        setState(() {
          language = args.toUpperCase();
        });
      }
      
      loadDictionary().then((_) {
        loadRandomWords();
      });
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_start == 0) {
        timer.cancel();
        Navigator.pushNamed(context, '/gameover', arguments: {'win': true, 'language': language});
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _timer.cancel();
    _textEditingController.dispose();
    super.dispose();
  }

  void resetGameState() {
    setState(() {
      _start = 120;
      enteredWords.clear();
      answers.clear();
      isInvalidAnswer = false;
    });
  }

  Future<void> loadDictionary() async {
    String path = language == "FRANCAIS" ? 'util/francais.txt' : 'util/english.txt';
    print(language);
    final String data = await rootBundle.loadString(path);
    setState(() {
      dictionary = const LineSplitter().convert(data);
    });
  }
  
  void loadRandomWords() {
    final Random random = Random();
    String word1 = '';
    String word2 = '';

    List<String> shuffledDictionary = List.from(dictionary)..shuffle(random);

    for (String word in shuffledDictionary) {
      word1 = word;
      word2 = findSecondWord(word1, shuffledDictionary);

      if (word2.isNotEmpty) break;
    }

    setState(() {
      _word1 = word1;
      _word2 = word2;
    });

    answers.removeAt(0); 
    answers.removeLast(); 

    print(answers);
  }

  String findSecondWord(String word, List<String> dictionary) {
    final Random random = Random();
    
    int minLength = word.length + 3;
    int maxLength = word.length + 5; 

    List<String> shuffledDictionary = List.from(dictionary)..shuffle(random);

    for (String candidate in shuffledDictionary) {
      if (candidate.length >= minLength && candidate.length <= maxLength &&
          isWordIncluded(word, candidate)) {
        if (canTransform(word, candidate, dictionary)) {
          return candidate;
        }
      }
    }

    return '';
  }

  bool isWordIncluded(String word1, String word2) {
    Map<String, int> charCount = {};

    for (int i = 0; i < word2.length; i++) {
      String char = word2[i];
      charCount[char] = (charCount[char] ?? 0) + 1;
    }

    for (int i = 0; i < word1.length; i++) {
      String char = word1[i];
      if ((charCount[char] ?? 0) == 0) {
        return false;
      }

      charCount[char] = charCount[char]! - 1;
    }

    return true;
  }

  bool canTransform(String start, String target, List<String> dictionary) {
  if (start == target) return false;

  if (start[0] != target[0] || start[start.length - 1] != target[target.length - 1]) {
    return false;
  }

  Map<String, List<String>> parentMap = {};
  Queue<String> queue = Queue<String>();
  Set<String> visited = Set<String>();

  queue.add(start);
  visited.add(start);

  while (queue.isNotEmpty) {
    String current = queue.removeFirst();

    if (current == target) {
      List<String> path = [current];
      String? parent = parentMap[current]?.first;
      while (parent != null) {
        path.insert(0, parent);
        parent = parentMap[parent]?.first;
      }

      bool isValidPath = true;
      String prevWord = start;
      for (String word in path) {
        if (!isWordIncluded(prevWord, word)) {
          isValidPath = false;
          break;
        }
        prevWord = word;
      }

      if (isValidPath) {
        answers = List.from(path);
        return true;
      }
    }

    for (String word in dictionary) {
      if (word.length == current.length + 1 && isOneCharacterDifferent(current, word) && !visited.contains(word)) {
        if (word[0] == target[0] && word[word.length - 1] == target[target.length - 1]) {
          queue.add(word);
          visited.add(word);
          parentMap[word] = [current, start];
        }
      }
    }
  }

  return false;
}



  bool isOneCharacterDifferent(String word1, String word2) {
    int differences = 0;
    for (int i = 0; i < word1.length; i++) {
      if (word1[i] != word2[i]) differences++;
    }
    return differences == 1;
  }

  String _word1 = '';
  String _word2 = '';

  void showInvalidAnswerAnimation() {
    setState(() {
      isInvalidAnswer = true;
    });

    Future.delayed(Duration(milliseconds: 1000), () {
      setState(() {
        isInvalidAnswer = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    int remainingWords = answers.length - enteredWords.length;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          if (answers.isNotEmpty && answers.length == enteredWords.length)
              ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                maxBlastForce: 20,
                minBlastForce: 8,
                emissionFrequency: 0.05,
                numberOfParticles: 100,
                gravity: 0.3,
                child: const SizedBox.shrink(),
              ),
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/homepage');
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back, color: Colors.black),
                        const SizedBox(width: 8),
                        Text(
                          language == "FRANCAIS" ? 'RETOUR' : 'BACK',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 160),
            Text(
              language == "FRANCAIS" ? '$_start secondes restantes' : '$_start seconds left',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < _word1.length; i++)
                  CharacterCard(character: _word1[i]),
              ],
            ),
            const Icon(
                Icons.arrow_downward,
                size: 40,
                color: Colors.black,
              ),
            Column(
              children: enteredWords.map((enteredWord) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < enteredWord.length; i++)
                          CharacterCard(character: enteredWord[i]),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_downward,
                      size: 40,
                      color: Colors.black,
                    ),
                  ],
                );
              }).toList(),
            ),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < _word2.length; i++)
                    CharacterCard(character: _word2[i]),
                ],
              ),
            ),

            SizedBox(height: 50),

            Container(
              width: 300,
              child: Column(
                children: [
                  ShakeAnimationWidget(
                    child: TextField(
                      controller: _textEditingController,
                      decoration: InputDecoration(
                        hintText: language == "FRANCAIS" ? 'Entrez un mot' : 'Enter a word',
                        fillColor: isInvalidAnswer ? Color.fromARGB(255, 248, 156, 149).withOpacity(0.2) : Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isInvalidAnswer ? Colors.red : Colors.black,
                          ),
                        ),
                      ),
                      onChanged: (String value) {
                        setState(() {
                          isInvalidAnswer = false;
                        });
                      },
                      onSubmitted: (String value) {
                        setState(() {
                          if (answers.contains(value)) {
                            enteredWords.add(value);
                          } else {
                            showInvalidAnswerAnimation();
                          }
                          if (answers.isNotEmpty && answers.length == enteredWords.length) {
                            _confettiController.play();
                              Future.delayed(const Duration(seconds: 2), () {
                                Navigator.pushNamed(context, '/gameover', arguments: {'win': true, 'language': language});
                              });
                          }
                          _textEditingController.clear();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    language == "FRANCAIS" ? '$remainingWords mots restants' : '$remainingWords words remaining',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}