import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class GameController extends GetxController {
  final int wordLength;
  late final String secretWord;
  var userWord = ''.obs;
  var isReady = false.obs;

  GameController({required this.wordLength});

  @override
  void onInit() {
    super.onInit();
    _getRandomWord().then((word) {
      secretWord = word;
      isReady.value = true;
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
    if (kDebugMode) {
      print(secretWord == userWord.value);
    }
  }
}
