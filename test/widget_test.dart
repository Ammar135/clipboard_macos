import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clipboard_project/main.dart';

void main() {
  test('MyApp is a MaterialApp shell', () {
    const app = MyApp();
    expect(app, isA<StatelessWidget>());
  });
}
