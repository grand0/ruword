import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruword/controllers/game_controller.dart';
import 'package:ruword/controllers/theme_controller.dart';
import 'package:ruword/theme.dart' as theme;

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
          Expanded(child: gameController.obx((state) {
            switch (state) {
              case GameState.loading:
                return const Center(child: CircularProgressIndicator());
              case GameState.running:
                return Obx(() => _buildGameWidget());
              case GameState.win:
                return const Center(child: Text('You win!'));
              case GameState.lose:
                return const Center(child: Text('You lose!'));
              case null:
                return Container();
            }
          })),
          _buildKeyboard(),
        ],
      ),
    );
  }

  Widget _buildGameWidget() {
    final isLightTheme = Get.find<ThemeController>().isLightTheme.value;
    final userAttempts = gameController.userAttempts.toList();
    List<Widget> rows = [];
    for (int i = 0; i < gameController.totalAttempts; i++) {
      if (i < userAttempts.length) {
        final List<LetterState> states =
            gameController.getLetterStates(userAttempts[i]);
        final List<Color> colors = states.map((state) {
          switch (state) {
            case LetterState.allRight:
              return isLightTheme ? theme.greenLight : theme.greenDark;
            case LetterState.wrongPlace:
              return isLightTheme ? theme.yellowLight : theme.yellowDark;
            case LetterState.allWrong:
              return isLightTheme ? theme.redLight : theme.redDark;
          }
        }).toList();
        rows.add(_buildWordRow(userAttempts[i], colors: colors));
      } else if (i == userAttempts.length) {
        rows.add(_buildWordRow(gameController.userWord.value));
      } else {
        rows.add(_buildWordRow(''));
      }
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: rows,
      ),
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
                                  gameController.userWord.value = word;
                                }
                              } else if (letter == 'done') {
                                if (word.length == gameController.wordLength) {
                                  gameController.checkWord();
                                }
                              } else if (word.length <
                                  gameController.wordLength) {
                                word += letter;
                                gameController.userWord.value = word;
                              }
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

  Widget _buildWordRow(String text, {List<Color>? colors}) {
    if (colors != null) {
      assert(colors.length == gameController.wordLength);
    }
    final squareSize =
        Get.mediaQuery.size.width / gameController.wordLength * 0.75;
    text = text.padRight(gameController.wordLength);
    List<Widget> squares = [];
    for (int i = 0; i < gameController.wordLength; i++) {
      squares.add(_buildWordSquare(text[i], squareSize, colors?[i]));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: squares,
    );
  }

  Widget _buildWordSquare(String letter, double size, [Color? color]) {
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        color: color,
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(fontSize: size / 2),
        ),
      ),
    );
  }
}
