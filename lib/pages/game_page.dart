import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ruword/controllers/game_controller.dart';
import 'package:ruword/controllers/theme_controller.dart';
import 'package:ruword/theme.dart' as theme;

class GamePage extends StatelessWidget {
  static const double _widthLimit = 600.0;

  static const double _keyboardHeight = 180.0;
  static const List<String> _keyboardLayout = [
    "й ц у к е н г ш щ з х ъ",
    "empty ф ы в а п р о л д ж э backspace",
    "empty empty я ч с м и т ь б ю empty done",
  ];
  static const String _acceptedCharacters = "абвгдежзийклмнопрстуфхцчшщъыьэюя";

  final GameController gameController;
  Flushbar? bottomFlushbar;

  GamePage({Key? key})
      : gameController = Get.put(
            GameController(wordLength: Get.arguments as int? ?? 5),
            tag: DateTime.now().millisecondsSinceEpoch.toString()),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ruword'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showGiveUpDialog(context),
            icon: const Icon(Icons.flag_outlined),
            tooltip: 'Сдаться',
          ),
        ],
      ),
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event.character != null && event is! KeyUpEvent) {
            _typeLetter(event.character!);
          } else if (event.logicalKey == LogicalKeyboardKey.backspace &&
              event is! KeyUpEvent) {
            _removeLetter();
          } else if (event.logicalKey == LogicalKeyboardKey.enter &&
              event is KeyDownEvent) {
            _checkWord(context);
          }
          return KeyEventResult.handled;
        },
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width > _widthLimit
                ? _widthLimit
                : null,
            child: Column(
              children: [
                Expanded(child: gameController.obx((state) {
                  switch (state) {
                    case GameState.loading:
                      return const Center(child: CircularProgressIndicator());
                    case GameState.running:
                      return Obx(() => _buildGameWidget(context));
                    case GameState.win:
                      _showGameOverFlushbar(context, true);
                      return _buildGameWidget(context);
                    case GameState.lose:
                      _showGameOverFlushbar(context, false);
                      return _buildGameWidget(context);
                    case null:
                      return Container();
                  }
                })),
                Obx(() => _buildKeyboard(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGiveUpDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: const Text('Сдаться?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () {
                    gameController.giveUp();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Сдаться'),
                ),
              ],
            ));
  }

  void _showGameOverFlushbar(BuildContext context, bool win) {
    Color color = win ? Colors.yellow : Colors.blueGrey;
    Icon icon = Icon(
      win ? Icons.emoji_events_outlined : Icons.close,
      color: color,
    );
    String title = win ? 'Вы выиграли!' : 'Вы проиграли!';
    bottomFlushbar?.dismiss();
    bottomFlushbar = Flushbar(
      icon: icon,
      leftBarIndicatorColor: color,
      title: title,
      messageText: RichText(
        text: TextSpan(
          children: [
            const TextSpan(text: 'Загаданное слово: '),
            TextSpan(
              text: gameController.secretWord,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (win) ...[
              const TextSpan(text: '\n'),
              const TextSpan(text: 'Попыток: '),
              TextSpan(
                text: '${gameController.currentAttempt.value + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ]
          ],
        ),
      ),
      mainButton: TextButton(
        child: const Text('Сыграть ещё'),
        onPressed: () {
          bottomFlushbar?.dismiss();
          WidgetsBinding.instance.addPostFrameCallback((_) =>
              Get.offAndToNamed('/game', arguments: gameController.wordLength));
        },
      ),
      duration: null,
      isDismissible: false,
      animationDuration: const Duration(milliseconds: 500),
    );
    WidgetsBinding.instance
        .addPostFrameCallback((_) => bottomFlushbar?.show(context));
  }

  Widget _buildGameWidget(BuildContext context) {
    final isLightTheme = Get.find<ThemeController>().isLightTheme.value;
    final userAttempts = gameController.userAttempts.toList();
    List<Widget> rows = [];
    for (int i = 0; i < gameController.totalAttempts; i++) {
      if (i < userAttempts.length) {
        final List<LetterState> states = gameController.userAttempts[i].states;
        final List<Color> colors = states.map((state) {
          switch (state) {
            case LetterState.allRight:
              return isLightTheme
                  ? theme.greenLight.withAlpha(127)
                  : theme.greenDark.withAlpha(127);
            case LetterState.wrongPlace:
              return isLightTheme
                  ? theme.yellowLight.withAlpha(127)
                  : theme.yellowDark.withAlpha(127);
            case LetterState.allWrong:
              return isLightTheme
                  ? theme.redLight.withAlpha(127)
                  : theme.redDark.withAlpha(127);
          }
        }).toList();
        rows.add(_buildWordRow(context, userAttempts[i].word,
            colors: colors,
            animateOpacity: i == gameController.currentAttempt.value));
      } else if (i == gameController.currentAttempt.value) {
        rows.add(_buildWordRow(context, gameController.userWord.value,
            animateOpacity: true));
      } else {
        rows.add(_buildWordRow(context, ''));
      }
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: rows,
        ),
      ),
    );
  }

  Widget _buildKeyboard(BuildContext context) {
    return Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: _keyboardLayout
            .map(
              (row) => Row(
                children: row.split(' ').map(
                  (letter) {
                    Color? color;
                    final isLightTheme =
                        Get.find<ThemeController>().isLightTheme.value;
                    if (letter.length == 1) {
                      switch (gameController.getLetterState(letter)) {
                        case LetterState.allRight:
                          color = isLightTheme
                              ? theme.greenLight.withAlpha(127)
                              : theme.greenDark.withAlpha(127);
                          break;
                        case LetterState.wrongPlace:
                          color = isLightTheme
                              ? theme.yellowLight.withAlpha(127)
                              : theme.yellowDark.withAlpha(127);
                          break;
                        case LetterState.allWrong:
                          color = isLightTheme
                              ? theme.redLight.withAlpha(127)
                              : theme.redDark.withAlpha(127);
                          break;
                        case null:
                          color = null;
                          break;
                      }
                    }
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
                      backgroundColor: color,
                      onPressed: letter != 'empty'
                          ? () {
                              if (gameController.state != GameState.running) {
                                return;
                              }
                              if (letter == 'backspace') {
                                _removeLetter();
                              } else if (letter == 'done') {
                                _checkWord(context);
                              } else {
                                _typeLetter(letter);
                              }
                            }
                          : null,
                      onLongPress: letter == 'backspace'
                          ? () {
                              gameController.userWord.value = '';
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
    Color? backgroundColor,
  }) {
    int flex = 1;
    if (child is Text) {
      flex = 2;
    } else if (child is Icon) {
      flex = 3;
    }
    return Expanded(
      flex: flex,
      child: Container(
        height: _keyboardHeight / _keyboardLayout.length,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
        ),
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

  Widget _buildWordRow(BuildContext context, String text,
      {List<Color>? colors, bool animateOpacity = false}) {
    if (colors != null) {
      assert(colors.length == gameController.wordLength);
    }
    final width = MediaQuery.of(context).size.width > _widthLimit
        ? _widthLimit
        : MediaQuery.of(context).size.width;
    final cellSize = width / gameController.wordLength * 0.75;
    text = text.padRight(gameController.wordLength);
    List<Widget> squares = [];
    for (int i = 0; i < gameController.wordLength; i++) {
      squares.add(_buildLetterCell(text[i], cellSize, colors?[i]));
    }
    return animateOpacity
        ? _ContainerWithAnimatedBorderOpacity(
            borderColor: Colors.grey,
            borderRadius: BorderRadius.circular(cellSize),
            margin: const EdgeInsets.symmetric(vertical: 4),
            from: 0.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: squares,
            ),
          )
        : Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.25)),
              borderRadius: BorderRadius.circular(cellSize),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: squares,
            ),
          );
  }

  Widget _buildLetterCell(String letter, double size, [Color? color]) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
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

  void _removeLetter() {
    String word = gameController.userWord.value;
    if (word.isNotEmpty) {
      word = word.substring(0, word.length - 1);
      gameController.userWord.value = word;
    }
  }

  void _checkWord(BuildContext context) {
    final state = gameController.checkWord();
    switch (state) {
      case CheckWordState.ok:
        break;
      case CheckWordState.notExists:
        Flushbar(
          message: 'Такого слова нет в словаре!',
          flushbarPosition: FlushbarPosition.TOP,
          duration: const Duration(seconds: 2),
          animationDuration: const Duration(milliseconds: 500),
          leftBarIndicatorColor: Colors.red,
          icon: const Icon(
            Icons.error_outline,
            color: Colors.red,
          ),
        ).show(context);
        break;
      case CheckWordState.notFull:
        Flushbar(
          message: 'Введите слово полностью!',
          flushbarPosition: FlushbarPosition.TOP,
          duration: const Duration(seconds: 2),
          animationDuration: const Duration(milliseconds: 500),
          leftBarIndicatorColor: Colors.red,
          icon: const Icon(
            Icons.error_outline,
            color: Colors.red,
          ),
        ).show(context);
        break;
    }
  }

  void _typeLetter(String letter) {
    assert(letter.length == 1);
    if (_acceptedCharacters.contains(letter)) {
      String word = gameController.userWord.value;
      if (word.length < gameController.wordLength) {
        word += letter;
        gameController.userWord.value = word;
      }
    }
  }
}

class _ContainerWithAnimatedBorderOpacity extends StatefulWidget {
  final bool animate;
  final Color? color;
  final BorderRadiusGeometry? borderRadius;
  final Color? borderColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Widget? child;
  final double from;
  final double to;

  const _ContainerWithAnimatedBorderOpacity({
    Key? key,
    this.animate = true,
    this.color,
    this.borderRadius,
    this.borderColor,
    this.padding,
    this.margin,
    this.child,
    this.from = 0.0,
    this.to = 1.0,
  }) : super(key: key);

  @override
  State<_ContainerWithAnimatedBorderOpacity> createState() =>
      _ContainerWithAnimatedBorderOpacityState();
}

class _ContainerWithAnimatedBorderOpacityState
    extends State<_ContainerWithAnimatedBorderOpacity>
    with TickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _controller = AnimationController(
          vsync: this, duration: const Duration(seconds: 1));
      _controller?.addListener(() {
        setState(() {});
      });
      _controller?.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller?.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller?.forward();
        }
      });
      _controller?.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor = widget.borderColor ?? Colors.grey;
    if (_controller != null) {
      double value = Tween(begin: widget.from, end: widget.to).evaluate(
          CurvedAnimation(parent: _controller!, curve: Curves.easeInOutQuad));
      borderColor = borderColor.withOpacity(value);
    } else {
      borderColor = borderColor.withOpacity(widget.from);
    }
    return Container(
      padding: widget.padding,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: widget.color,
        border: Border.all(color: borderColor),
        borderRadius: widget.borderRadius,
      ),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
