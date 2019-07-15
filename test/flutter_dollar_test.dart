import 'package:flutter/cupertino.dart';
import 'package:flutter_dollar/flutter_dollar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('contexts', () {
    group('StatefulWidget', () {
      testWidgets('should support dollar functions in build()', (tester) async {
        var buildCount = 0;
        var endCount = 0;
        $Var<int> text;
        await tester.pumpWidget(Stateful(builder: (context) {
          buildCount++;
          text = $var(() => 1);

          $fork(() {
            return () => endCount++;
          });
          return Text(text.value.toString(), textDirection: TextDirection.ltr);
        }));
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
        await tester.pumpWidget(Stateful(builder: (context) {
          buildInner = $var(() => true);
          if (buildInner.value) {
            return Stateful(
              builder: (_) {
                final cursor = $var(() => 'inner');
                return Text(cursor.value, textDirection: TextDirection.ltr);
              },
              key: Key('inner'),
            );
          } else {
            return Stateful(
              builder: (_) {
                $var(() => 1);
                final cursor = $var(() => 'outer');
                return Text(cursor.value, textDirection: TextDirection.ltr);
              },
              key: Key('outer'),
            );
          }
        }));
        expect(find.text('inner'), findsOneWidget);
        buildInner.value = false;
        await tester.pump();
        expect(find.text('outer'), findsOneWidget);
        buildInner.value = true;
        await tester.pump();
        expect(find.text('inner'), findsOneWidget);
      });
    });
  });
}

class Stateful extends StatefulWidget {
  final Widget Function(BuildContext context) builder;

  const Stateful({Key key, this.builder}) : super(key: key);

  @override
  _StatefulState createState() => _StatefulState();
}

class _StatefulState extends State<Stateful> with $State {
  @override
  Widget $build(BuildContext context) {
    return widget.builder(context);
  }
}
