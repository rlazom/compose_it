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

    GameProvider provider = Provider.of<GameProvider>(context, listen: false);
    provider.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.startGame(widget.word);
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // void _checkWin() {
  //   final gameProvider = Provider.of<GameProvider>(context);
  //   bool win = gameProvider.placedLetters.join() == widget.word;
  //
  //   if (win) {
  //     _confettiController.play();
  //   }
  //
  //   gameProvider.playSound(win: win);
  // }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);

    // if (gameProvider.placedLetters.join() == widget.word) {
    // if (gameProvider.placedLetters.join().length == widget.word.length) {
    //   _checkWin();
    // }

    bool? checkWin = gameProvider.checkWin();
    print('build() - checkWin: "$checkWin"');

    if (checkWin != null) {
      if (checkWin) {
        _confettiController.play();
      }
      gameProvider.playSound(win: checkWin);
    }

    return Stack(
      children: [
        Scaffold(
          // appBar: AppBar(title: Text('Forma: ${widget.word.word}')),
          appBar: AppBar(
            actions: [
              IconButton(
                  tooltip: 'Escuchar palabra completa',
                  onPressed: () =>
                      gameProvider.playWord(gameProvider.currentWord),
                  icon: Icon(Icons.play_arrow)),
              IconButton(
                  tooltip: 'Reiniciar',
                  onPressed: gameProvider.placedLetters.isEmpty
                      ? null
                      : gameProvider.resetCurrent,
                  icon: Icon(Icons.refresh)),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: OrientationBuilder(builder: (context, orientation) {
              if (orientation == Orientation.portrait) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Letras disponibles
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: gameProvider.availableLetters.map((letter) {
                          return Draggable<String>(
                            data: letter,
                            feedback: LetterBox(letter, isDragging: true),
                            childWhenDragging: LetterBox(' '),
                            child: LetterBox(letter),
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
                                  ? LetterBox(
                                      placedLetter,
                                      isWin: checkWin,
                                    )
                                  : LetterBox(' ');
                            }).toList(),
                          ),
                        ),
                        // onAccept: (letter) => gameProvider.placeLetter(letter),
                        onAcceptWithDetails: (letter) =>
                            gameProvider.placeLetter(letter.data),
                      ),

                      const SizedBox(height: 20),

                      // Imagen referencia
                      if (widget.emoji?.isNotEmpty ?? false)
                        Center(
                          child: Text(
                            widget.emoji!,
                            style: TextStyle(fontSize: 128),
                          ),
                        ),
                    ],
                  ),
                );
              } else {
                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Letras disponibles
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: gameProvider.availableLetters
                                .map((letter) {
                              return Draggable<String>(
                                data: letter,
                                feedback: LetterBox(letter,
                                    isDragging: true),
                                childWhenDragging: LetterBox(' '),
                                child: LetterBox(letter),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 16),

                          DragTarget<String>(
                            builder: (context, _, __) => Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey),
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children:
                                    (gameProvider.currentWord ?? '')
                                        .split('')
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                  final index = entry.key;
                                  final placedLetter = index <
                                          gameProvider
                                              .placedLetters.length
                                      ? gameProvider
                                          .placedLetters[index]
                                      : null;

                                  return placedLetter != null
                                      ? LetterBox(
                                          placedLetter,
                                          isWin: checkWin,
                                        )
                                      : LetterBox(' ');
                                }).toList(),
                              ),
                            ),
                            // onAccept: (letter) => gameProvider.placeLetter(letter),
                            onAcceptWithDetails: (letter) =>
                                gameProvider
                                    .placeLetter(letter.data),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      flex: 2,
                      child: FittedBox(
                        child: Text(
                          widget.emoji!,
                        ),
                      ),
                    ),
                    // if (widget.emoji?.isNotEmpty ?? false)
                    //   Expanded(
                    //     flex: 1,
                    //     child: Text(
                    //       widget.emoji!,
                    //       style: TextStyle(fontSize: 128),
                    //     ),
                    //   ),
                  ],
                );
              }
            }),
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
