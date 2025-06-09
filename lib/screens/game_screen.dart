import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../providers/game_provider.dart';
import '../widgets/letter_box.dart';

class GameScreen extends StatefulWidget {
  final String word;
  final String? emoji;

  const GameScreen({super.key, required this.word, this.emoji});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GameProvider>(context, listen: false).startGame(widget.word);
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _checkWin() {
    final gameProvider = Provider.of<GameProvider>(context);
    bool win = gameProvider.placedLetters.join() == widget.word;

    if (win) {
      _confettiController.play();
    }

    gameProvider.playSound(win: win);
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);

    // if (gameProvider.placedLetters.join() == widget.word) {
    if (gameProvider.placedLetters.join().length == widget.word.length) {
      _checkWin();
    }

    return Stack(
      children: [
        Scaffold(
          // appBar: AppBar(title: Text('Forma: ${widget.word.word}')),
          appBar: AppBar(),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                OutlinedButton(
                  onPressed: () => gameProvider.playWord(gameProvider.currentWord),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Escuchar palabra completa'),
                      Icon(Icons.volume_down_sharp),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: gameProvider.selectedLetters.isEmpty
                            ? null
                            : () {
                                gameProvider.playWord(gameProvider.selectedLetters);
                              },
                        child: Row(
                          children: [
                            Text('Escuchar ${gameProvider.selectedLetters.isEmpty ? '' : '"${gameProvider.selectedLetters}"'}'),
                            Icon(gameProvider.selectedLetters.isEmpty ? Icons.volume_off : Icons.volume_up),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 16,),
                    OutlinedButton(
                      onPressed: gameProvider.selectedLetters.isEmpty
                          ? null
                          : gameProvider.clearSelectedLetter,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.clear),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                /// Letras disponibles
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: gameProvider.availableLetters.map((letter) {
                    return Draggable<String>(
                      data: letter,
                      feedback: LetterBox(letter, isDragging: true),
                      childWhenDragging: LetterBox(' '),
                      child: InkWell(
                        onTap: () => gameProvider.selectLetter(letter),
                        child: LetterBox(letter),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 40),

                DragTarget<String>(
                  builder: (context, _, __) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (gameProvider.currentWord ?? '')
                          .split('')
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final placedLetter =
                            index < gameProvider.placedLetters.length
                                ? gameProvider.placedLetters[index]
                                : null;

                        return placedLetter != null
                            ? LetterBox(placedLetter)
                            : LetterBox(' ');
                      }).toList(),

                      // children: gameProvider.currentWord!.word.split('').asMap().map(
                      //       (MapEntry<dynamic, dynamic> map) => LetterBox(gameProvider.placedLetters[map.key ?? '']),

                      // children: gameProvider.placedLetters.map(
                      //       (letter) => LetterBox(letter),
                      // ).toList(),
                    ),
                  ),
                  // onAccept: (letter) => gameProvider.placeLetter(letter),
                  onAcceptWithDetails: (letter) =>
                      gameProvider.placeLetter(letter.data),
                ),

                const SizedBox(height: 20),

                // Imagen referencia
                // Image.asset(widget.word.imagePath, height: 120),
                if (widget.emoji?.isNotEmpty ?? false)
                  Text(
                    widget.emoji!,
                    style: TextStyle(fontSize: 128),
                  ),

                // Botón reinicio
                if (gameProvider.placedLetters.isNotEmpty)
                  OutlinedButton(
                    onPressed: gameProvider.resetCurrent,
                    child: const Text('Reiniciar'),
                  ),
              ],
            ),
          ),
        ),

        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
            ],
          ),
        ),
      ],
    );
  }
}
