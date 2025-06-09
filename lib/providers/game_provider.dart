import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
// import 'package:flutter_tts/flutter_tts_web.dart' show TtsState;

enum TtsState {
  stopped,
  playing,
}

// class Word {
//   final String data;
//   bool selected;
//
//   Word({required this.data, this.selected = false});
// }

class GameProvider extends ChangeNotifier {
  String? _currentWord;
  List<String> _availableLetters = [];
  List<String> _placedLetters = [];
  List<String> _selectedLetters = [];

  final String _currentLanguage = 'es';

  final AudioPlayer _audioPlayer = AudioPlayer();

  FlutterTts flutterTts = FlutterTts();
  TtsState ttsState = TtsState.stopped;

  String? get currentWord => _currentWord;
  List<String> get availableLetters => _availableLetters;
  List<String> get placedLetters => _placedLetters;
  String get selectedLetters => _selectedLetters.join();

  void startGame(String word) {
    log('startGame() - word: "$word"');
    _currentWord = word;
    _placedLetters = [];

    int addMoreLetters = 3;
    // _availableLetters = word.word.split('')..shuffle();

    // 1. Letras de la palabra original (sin duplicados y mezcladas)
    _availableLetters = word.split('').toSet().toList()..shuffle();

    // 2. Evitar que el mezclado coincida con la palabra original
    while (_availableLetters.join().toUpperCase() == word.toUpperCase()) {
      _availableLetters = word.split('').toSet().toList()..shuffle();
    }

    // 3. Añadir 3 letras aleatorias que NO estén en la palabra
    final letrasDisponibles = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'; // Alfabeto
    final letrasNoEnPalabra = letrasDisponibles
        .split('')
        .where((letra) => !word.toUpperCase().contains(letra))
        .toList()
      ..shuffle();

    // Asegurar que tenemos suficientes letras únicas
    final letrasAdicionales = letrasNoEnPalabra.take(addMoreLetters).toList();
    _availableLetters.addAll(letrasAdicionales);
    _availableLetters.shuffle();

    log('startGame() - _availableLetters: "$_availableLetters"');
    _ttsInitialization();

    notifyListeners();
  }

  _ttsInitialization() async{
    // List<dynamic> languages = await flutterTts.getLanguages;
    // log('TTS languages: "${languages.join(',')}"');

    // bool _isLanguageAvailable = await flutterTts.isLanguageAvailable("en-US");
    bool isLanguageAvailable = await flutterTts.isLanguageAvailable(_currentLanguage);
    log('TTS _isLanguageAvailable: "$isLanguageAvailable"');

    if (isLanguageAvailable) {
      // await flutterTts.setLanguage("es-US");
      await flutterTts.setLanguage(_currentLanguage);

      // await flutterTts.setSpeechRate(1.0);
      // await flutterTts.setSpeechRate(initialSpeechRate);
      await flutterTts.setSpeechRate(0);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);
    }

    await flutterTts.isLanguageAvailable("en-US");
  }

  playWord(String? word) async {
   if (word?.isNotEmpty ?? false) {
      ttsState = TtsState.playing;
      await flutterTts.speak(word!, focus: true);
      ttsState = TtsState.stopped;
    }
  }

  void selectLetter(String letter) {
    _selectedLetters.add(letter);
    notifyListeners();
  }

  void clearSelectedLetter() {
    _selectedLetters.clear();
    notifyListeners();
  }

  Future<void> placeLetter(String letter) async {
    _placedLetters.add(letter);
    notifyListeners();
  }

  playSound({win = true}) async {
    if (win) {
      await _audioPlayer.play(AssetSource('sounds/success.mp3'));
    } else {
      await _audioPlayer.play(AssetSource('sounds/failure.mp3'));
    }
  }

  void resetCurrent() {
    if (_currentWord != null) {
      startGame(_currentWord!);
    }
  }
}