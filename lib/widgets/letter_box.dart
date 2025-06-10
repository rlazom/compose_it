import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';

class LetterBox extends StatelessWidget {
  final String letter;
  final bool isDragging;
  final bool isSelected;
  final bool? isWin;

  const LetterBox(
    this.letter, {
    this.isDragging = false,
    this.isSelected = false,
    this.isWin,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // final gameProvider = Provider.of<GameProvider>(context);
    // bool isFail = gameProvider.win == false;

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isWin != null
            ? isWin == true
              ? Colors.green
              : Colors.red
            : isDragging
        // color: isDragging
              ? Colors.amber
              : letter == ' '
                ? Colors.grey.withValues(alpha: 0.25)
                : Colors.blueAccent,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          if (!isDragging && letter != ' ')
            BoxShadow(
              // color: Colors.black.withOpacity(0.1),
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: letter == ' ' ? Colors.transparent : Colors.white,
          ),
        ),
      ),
    );
  }
}
