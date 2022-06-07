import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruword/controllers/theme_controller.dart';
import 'package:wheel_chooser/wheel_chooser.dart';

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
            icon: const Icon(Icons.brightness_4),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Длина слова'),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 100,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: WheelChooser.integer(
                  onValueChanged: (val) => setState(() => wordLength = val),
                  maxValue: 12,
                  minValue: 4,
                  initValue: 5,
                  unSelectTextStyle: const TextStyle(color: Colors.grey),
                  magnification: 1.5,
                  horizontal: true,
                ),
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Играть'),
              onPressed: () => Get.toNamed('/game', arguments: wordLength),
            ),
          ],
        ),
      ),
    );
  }
}
