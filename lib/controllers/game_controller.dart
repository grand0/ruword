import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class GameController extends GetxController with StateMixin<GameState> {
  final int wordLength;
  final int totalAttempts;
  late final String secretWord;
  var userWord = ''.obs;
  var userAttempts = <String>[].obs;
  var currentAttempt = 0.obs;

  GameController({required this.wordLength}) : totalAttempts = wordLength + 1;

  @override
  void onInit() {
    change(GameState.loading, status: RxStatus.success());
    super.onInit();
    _getRandomWord().then((word) {
      secretWord = word;
      change(GameState.running, status: RxStatus.success());
      if (kDebugMode) {
        print(secretWord);
      }
    });
  }

  Future<String> _getRandomWord() async {
    final contents =
        await rootBundle.loadString('assets/words/words_$wordLength.txt');
    final words = contents.split('\r\n');
    words.removeWhere((element) => (element == ''));
    return words[Random().nextInt(words.length)];
  }

  void checkWord() {
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
