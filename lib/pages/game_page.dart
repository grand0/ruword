import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruword/controllers/game_controller.dart';
import 'package:ruword/controllers/theme_controller.dart';

class GamePage extends StatelessWidget {
  static const double _keyboardHeight = 180.0;
  static const List<String> _keyboardLayout = [
    "й ц у к е н г ш щ з х ъ",
    "empty ф ы в а п р о л д ж э backspace",
    "empty empty я ч с м и т ь б ю empty done",
  ];

  final GameController gameController;

  GamePage({Key? key})
      : gameController =
            Get.put(GameController(wordLength: Get.arguments as int? ?? 5)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ruword'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Get.find<ThemeController>().switchTheme(),
            icon: const Icon(Icons.brightness_4),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() => gameController.isReady.value
                ? _buildGameWidget()
                : const Center(child: CircularProgressIndicator())),
          ),
          _buildKeyboard(),
        ],
      ),
    );
  }

  Widget _buildGameWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildWordRow(gameController.secretWord),
        _buildWordRow(gameController.userWord.value),
      ],
    );
  }

  Widget _buildKeyboard() {
    return Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: _keyboardLayout
            .map(
              (row) => Row(
                children: row.split(' ').map(
                  (letter) {
                    Widget? child;
                    if (letter == 'backspace') {
                      child = const Icon(Icons.backspace_outlined);
                    } else if (letter == 'done') {
                      child = const Icon(Icons.check);
                    } else if (letter == 'empty') {
                      child = null;
                    } else {
                      child = Text(
                        letter,
                        style: const TextStyle(fontSize: 18),
                      );
                    }
                    return _buildKeyboardButton(
                      child: child,
                      onPressed: letter != 'empty'
                          ? () {
                              String word = gameController.userWord.value;
                              if (letter == 'backspace') {
                                if (word.isNotEmpty) {
                                  word = word.substring(0, word.length - 1);
                                }
                              } else if (letter == 'done') {
                                if (word.length == gameController.wordLength) {
                                  gameController.checkWord();
                                }
                              } else if (word.length <
                                  gameController.wordLength) {
                                word += letter;
                              }
                              gameController.userWord.value = word;
                            }
                          : null,
                    );
                  },
                ).toList(),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildKeyboardButton({
    Widget? child,
    void Function()? onPressed,
    void Function()? onLongPress,
  }) {
    int flex = 1;
    if (child is Text) {
      flex = 2;
    } else if (child is Icon) {
      flex = 3;
    }
    return Expanded(
      flex: flex,
      child: SizedBox(
        height: _keyboardHeight / _keyboardLayout.length,
        child: InkResponse(
          splashFactory: InkSparkle.splashFactory,
          radius: 16,
          onTap: onPressed,
          onLongPress: onLongPress,
          child: Center(child: child),
        ),
      ),
    );
  }

  Widget _buildWordRow(String text) {
    final squareSize =
        Get.mediaQuery.size.width / gameController.wordLength * 0.75;
    text.padRight(gameController.wordLength);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          text.characters.map((e) => _buildWordSquare(e, squareSize)).toList(),
    );
  }

  Widget _buildWordSquare(String letter, double size) {
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(fontSize: size/2),
        ),
      ),
    );
  }
}
