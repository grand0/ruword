import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class GameController extends GetxController with StateMixin<GameState> {
  final int wordLength;
  final int totalAttempts;
  late final List<String> allWords;
  late final String secretWord;
  var userWord = ''.obs;
  var userAttempts = <String>[].obs;
  var currentAttempt = 0.obs;

  GameController({required this.wordLength}) : totalAttempts = wordLength + 1;

  @override
  void onInit() {
    change(GameState.loading, status: RxStatus.success());
    super.onInit();
    _loadAllWords().whenComplete(() {
      secretWord = _getRandomWord();
      change(GameState.running);
      if (kDebugMode) {
        print(secretWord);
      }
    });
  }

  Future<void> _loadAllWords() async {
    final contents =
        await rootBundle.loadString('assets/words/words_$wordLength.txt');
    allWords = contents.split('\r\n');
    allWords.removeWhere((element) => (element == ''));
  }

  String _getRandomWord() {
    return allWords[Random().nextInt(allWords.length)];
  }

  void checkWord() {
    if (!allWords.contains(userWord.value)) {
      if (kDebugMode) {
        print('no such word');
      }
      return;
    }

    userAttempts.add(userWord.value);
    if (userWord.value == secretWord) {
      change(GameState.win);
    } else {
      currentAttempt++;
      if (currentAttempt.value == totalAttempts) {
        change(GameState.lose);
      }
    }
    userWord.value = '';
  }
}

enum GameState { loading, running, win, lose }
