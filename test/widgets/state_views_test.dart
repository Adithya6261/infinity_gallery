import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinity_gallery/widgets/state_views.dart';

void main() {
  testWidgets('ErrorView shows the message and calls onRetry when tapped', (tester) async {
    var retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: ErrorView(
          message: 'Could not reach the server',
          onRetry: () => retried = true,
        ),
      ),
    );

    expect(find.text('Could not reach the server'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });

  testWidgets('ErrorView hides the retry button when onRetry is null', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ErrorView(message: 'Something went wrong')),
    );

    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('EmptyView renders its message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: EmptyView(message: 'No images found')),
    );

    expect(find.text('No images found'), findsOneWidget);
  });
}
