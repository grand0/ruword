import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruword/controllers/game_controller.dart';
import 'package:ruword/controllers/theme_controller.dart';

class GamePage extends StatelessWidget {
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
        Text(gameController.secretWord),
        Text(gameController.userWord.value),
      ],
    );
  }

  Widget _buildKeyboard() {
    const List<String> lettersLayout = [
      "й ц у к е н г ш щ з х ъ",
      "ф ы в а п р о л д ж э backspace",
      "я ч с м и т ь б ю done",
    ];
    return Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: lettersLayout
            .map(
              (row) => Row(
                children: row.split(' ').map(
                  (letter) {
                    Widget child;
                    if (letter == 'backspace') {
                      child = const Icon(Icons.backspace_outlined);
                    } else if (letter == 'done') {
                      child = const Icon(Icons.check);
                    } else {
                      child = Text(
                        letter,
                        style: const TextStyle(fontSize: 18),
                      );
                    }
                    return _buildKeyboardButton(
                      child: child,
                      onPressed: () {
                        String word = gameController.userWord.value;
                        if (letter == 'backspace') {
                          if (word.isNotEmpty) {
                            word = word.substring(0, word.length - 1);
                          }
                        } else if (letter == 'done') {
                          if (word.length == gameController.wordLength) {
                            gameController.checkWord();
                          }
                        } else if (word.length < gameController.wordLength) {
                          word += letter;
                        }
                        gameController.userWord.value = word;
                      },
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
    required Widget child,
    required void Function() onPressed,
    void Function()? onLongPress,
  }) =>
      Expanded(
        flex: child is Text ? 2 : 3,
        child: SizedBox(
          height: 64,
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