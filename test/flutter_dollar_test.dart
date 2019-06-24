import 'package:flutter/cupertino.dart';
import 'package:flutter_dollar/flutter_dollar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('contexts', () {
    group('StatefulWidget', () {
      runTest((builder, key) => Stateful(builder: builder, key: key));
    });
    group('StatelessWidget', () {
      runTest((builder, key) => Stateless(builder: builder, key: key));
    });
    group('Subtree', () {
      runTest((builder, key) => $Subtree(builder: builder, key: key));
    });
  });

  group('extensions', () {
    group('memo', () {
      test('should return previous value iff deps are shallowly equal', () {
        var runCount = 0;
        final func = $bind((Iterable deps) {
          return $memo(() => ++runCount, deps);
        }, $emptyHandler);
        expect(func([1, 2]), 1);
        expect(func([1, 2]), 1);
        expect(func([1, 2, 3]), 2);
        expect(func([1, 2]), 3);
      });
    });
  });
}

class Stateful extends StatefulWidget with $StatefulWidget {
  final Widget Function(BuildContext context) builder;

  const Stateful({Key key, this.builder}) : super(key: key);

  @override
  _StatefulState createState() => _StatefulState();
}

class _StatefulState extends State<Stateful> {
  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}

class Stateless extends StatelessWidget with $StatelessWidget {
  final Widget Function(BuildContext context) builder;

  const Stateless({Key key, this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return builder(context);
  }
}

void runTest(Widget widget(Widget builder(BuildContext context), Key key)) {
  testWidgets('should support dollar functions in build()', (tester) async {
    var buildCount = 0;
    var endCount = 0;
    $Var<int> text;
    await tester.pumpWidget(widget((context) {
      buildCount++;
      text = $var(() => 1);

      $fork(() {
        return () => endCount++;
      });
      return Text(text.value.toString(), textDirection: TextDirection.ltr);
    }, Key('')));
    expect(find.text('1'), findsOneWidget);
    text.value++;
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    text.value++;
    await tester.pump();
    expect(find.text('3'), findsOneWidget);
    expect(buildCount, 3);
    expect(endCount, 2);
    await tester.pumpWidget(Container());
    expect(endCount, 3);
  });

  testWidgets('should not interfere with inner components', (tester) async {
    $Var<bool> buildInner;
    await tester.pumpWidget(widget((context) {
      buildInner = $var(() => true);
      if (buildInner.value) {
        return widget((_) {
          final cursor = $var(() => 'inner');
          return Text(cursor.value, textDirection: TextDirection.ltr);
        }, Key('inner'));
      } else {
        return widget((_) {
          $var(() => 1);
          final cursor = $var(() => 'outer');
          return Text(cursor.value, textDirection: TextDirection.ltr);
        }, Key('outer'));
      }
    }, Key('')));
    expect(find.text('inner'), findsOneWidget);
    buildInner.value = false;
    await tester.pump();
    expect(find.text('outer'), findsOneWidget);
    buildInner.value = true;
    await tester.pump();
    expect(find.text('inner'), findsOneWidget);
  });
}
