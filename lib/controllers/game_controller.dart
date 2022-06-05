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

  CheckWordState checkWord() {
    if (userWord.value.length != wordLength) {
      return CheckWordState.notFull;
    }
    if (!allWords.contains(userWord.value)) {
      return CheckWordState.notExists;
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
    return CheckWordState.ok;
  }

  List<LetterState> getLetterStates(String word) {
    assert(word.length == secretWord.length);
    List<LetterState> states = [];
    for (int i = 0; i < word.length; i++) {
      if (word[i] == secretWord[i]) {
        states.add(LetterState.allRight);
      } else if (secretWord.contains(word[i])) {
        states.add(LetterState.wrongPlace);
      } else {
        states.add(LetterState.allWrong);
      }
    }
    return states;
  }
}

enum GameState { loading, running, win, lose }

enum LetterState { allWrong, wrongPlace, allRight }

enum CheckWordState { ok, notExists, notFull }
