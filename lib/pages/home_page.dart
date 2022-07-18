import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:ruword/controllers/theme_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int wordLength = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ruword'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Get.find<ThemeController>().switchTheme(),
            icon: const Icon(Icons.brightness_4_outlined),
            tooltip: 'Сменить тему',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Длина слова'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_left),
                  onPressed: () => setState(() {
                    final newValue = wordLength - 1;
                    wordLength = newValue.clamp(4, 12);
                  }),
                ),
                ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    },
                  ),
                  child: NumberPicker(
                    value: wordLength,
                    minValue: 4,
                    maxValue: 12,
                    itemHeight: 100,
                    itemWidth: 50,
                    itemCount: 5,
                    axis: Axis.horizontal,
                    onChanged: (value) => setState(() => wordLength = value),
                    selectedTextStyle: context.textTheme.headline3
                        ?.copyWith(color: context.theme.colorScheme.primary),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_right),
                  onPressed: () => setState(() {
                    final newValue = wordLength + 1;
                    wordLength = newValue.clamp(4, 12);
                  }),
                ),
              ],
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow_outlined),
              label: const Text('Играть'),
              onPressed: () => Get.toNamed('/game', arguments: wordLength),
            ),
          ],
        ),
      ),
    );
  }
}
