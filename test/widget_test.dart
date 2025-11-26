// Test basique pour l'application SAH Food

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sahfood/main.dart';

void main() {
  testWidgets('Application SAH Food se lance correctement', (WidgetTester tester) async {
    // Construit notre application et déclenche un frame
    await tester.pumpWidget(const ApplicationSahFood());

    // Vérifie que l'écran splash apparaît
    expect(find.text('SAH FOOD'), findsOneWidget);
  });
}
