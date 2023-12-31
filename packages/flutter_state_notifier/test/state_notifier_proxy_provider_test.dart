import 'package:flutter/widgets.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'common.dart';

void main() {
  group('StateNotifierProxyProvider', () {
    testWidgets(
      'transitions from notifier to notifier and from state to state',
      (tester) async {
        final notifier = TestNotifier(0);
        final notifier2 = TestNotifier(1);
        final notifier3 = TestNotifier(0);

        const controller = TextConsumer<TestNotifier>();
        const value = TextConsumer<int>();

        // First build
        await tester.pumpWidget(
          StateNotifierProxyProvider0<TestNotifier, int>(
            create: (context) => notifier,
            update: (_, __) => notifier,
            child: const Column(
              textDirection: TextDirection.ltr,
              children: <Widget>[
                controller,
                value,
              ],
            ),
          ),
        );

        expect(find.text('0'), findsOneWidget);
        expect(buildCountOf(controller), 1);
        expect(buildCountOf(value), 1);

        // Only value changes
        notifier.increment();
        await tester.pump();

        expect(find.text('1'), findsOneWidget);
        expect(buildCountOf(controller), 1);
        expect(buildCountOf(value), 2);

        // Only controller changes (same state)
        await tester.pumpWidget(
          StateNotifierProxyProvider0<TestNotifier, int>(
            create: (context) => notifier2,
            update: (_, __) => notifier2,
            child: const Column(
              textDirection: TextDirection.ltr,
              children: <Widget>[
                controller,
                value,
              ],
            ),
          ),
        );

        expect(find.text('1'), findsOneWidget);
        expect(buildCountOf(controller), 2);
        expect(buildCountOf(value), 2);

        // Only value changes (second notifier)
        notifier2.increment();
        await tester.pump();

        expect(find.text('2'), findsOneWidget);
        expect(buildCountOf(controller), 2);
        expect(buildCountOf(value), 3);

        // Both controller and value change
        await tester.pumpWidget(
          StateNotifierProxyProvider0<TestNotifier, int>(
            create: (context) => notifier3,
            update: (_, __) => notifier3,
            child: const Column(
              textDirection: TextDirection.ltr,
              children: <Widget>[
                controller,
                value,
              ],
            ),
          ),
        );

        expect(find.text('0'), findsOneWidget);
        expect(buildCountOf(controller), 3);
        expect(buildCountOf(value), 4);
      },
    );

    testWidgets(
      'update returning a new notifier disposes the previously'
      ' created one',
      (tester) async {
        final dispose = DisposeMock();
        final notifier = TestNotifier(0, onDispose: dispose);
        final notifier2 = TestNotifier(1);

        const controller = TextConsumer<TestNotifier>();
        const value = TextConsumer<int>();

        await tester.pumpWidget(
          StateNotifierProxyProvider0<TestNotifier, int>(
            create: (context) => notifier,
            update: (_, __) => notifier,
            child: const Column(
              textDirection: TextDirection.ltr,
              children: <Widget>[
                controller,
                value,
              ],
            ),
          ),
        );

        await tester.pumpWidget(
          StateNotifierProxyProvider0<TestNotifier, int>(
            create: (context) => notifier2,
            update: (_, __) => notifier2,
            child: const Column(
              textDirection: TextDirection.ltr,
              children: <Widget>[
                controller,
                value,
              ],
            ),
          ),
        );

        verify(dispose()).called(1);
        verifyNoMoreInteractions(dispose);
      },
    );

    testWidgets('rejects StateNotifier with listeners', (tester) async {
      final notifier = TestNotifier(0)..addListener((state) {});

      await tester.pumpWidget(
        StateNotifierProxyProvider0<TestNotifier, int>(
          update: (_, __) => notifier,
          child: const TextConsumer<int>(),
        ),
      );

      expect(tester.takeException(), isAssertionError);
    });
  });

  final a = A();
  final b = B();
  final c = C();
  final d = D();
  final e = E();
  final f = F();

  final combinedConsumerMock = MockCombinedBuilder();
  setUp(() => when(combinedConsumerMock(any)).thenReturn(Container()));
  tearDown(() {
    clearInteractions(combinedConsumerMock);
  });

  final mockConsumer = Consumer<CombinedState>(
    builder: (context, combined, child) => combinedConsumerMock(combined),
  );

  group('StateNotifierProxyProvider variants', () {
    InheritedContext<CombinedStateNotifier?> findInheritedProvider() =>
        findInheritedContext<CombinedStateNotifier>();

    testWidgets('StateNotifierProxyProvider0', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: a),
            Provider.value(value: b),
            Provider.value(value: c),
            Provider.value(value: d),
            Provider.value(value: e),
            Provider.value(value: f),
            StateNotifierProxyProvider0<CombinedStateNotifier, CombinedState>(
              create: (_) => CombinedStateNotifier(),
              update: (context, previous) => previous!
                ..state = CombinedState(
                  context,
                  previous.state,
                  Provider.of<A>(context),
                  Provider.of<B>(context),
                  Provider.of<C>(context),
                  Provider.of<D>(context),
                  Provider.of<E>(context),
                  Provider.of<F>(context),
                ),
            )
          ],
          child: mockConsumer,
        ),
      );

      final context = findInheritedProvider();

      verify(
        combinedConsumerMock(
          CombinedState(
            context,
            const CombinedState(),
            a,
            b,
            c,
            d,
            e,
            f,
          ),
        ),
      ).called(1);
    });

    testWidgets('StateNotifierProxyProvider', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: a),
            StateNotifierProxyProvider<A, CombinedStateNotifier, CombinedState>(
              create: (_) => CombinedStateNotifier(),
              update: (context, a, previous) => previous!
                ..state = CombinedState(
                  context,
                  previous.state,
                  a,
                ),
            )
          ],
          child: mockConsumer,
        ),
      );

      final context = findInheritedProvider();

      verify(
        combinedConsumerMock(
          CombinedState(context, const CombinedState(), a),
        ),
      ).called(1);
    });

    testWidgets('StateNotifierProxyProvider2', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: a),
            Provider.value(value: b),
            StateNotifierProxyProvider2<A, B, CombinedStateNotifier,
                CombinedState>(
              create: (_) => CombinedStateNotifier(),
              update: (context, a, b, previous) => previous!
                ..state = CombinedState(
                  context,
                  previous.state,
                  a,
                  b,
                ),
            )
          ],
          child: mockConsumer,
        ),
      );

      final context = findInheritedProvider();

      verify(
        combinedConsumerMock(
          CombinedState(context, const CombinedState(), a, b),
        ),
      ).called(1);
    });

    testWidgets('StateNotifierProxyProvider3', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: a),
            Provider.value(value: b),
            Provider.value(value: c),
            StateNotifierProxyProvider3<A, B, C, CombinedStateNotifier,
                CombinedState>(
              create: (_) => CombinedStateNotifier(),
              update: (context, a, b, c, previous) => previous!
                ..state = CombinedState(
                  context,
                  previous.state,
                  a,
                  b,
                  c,
                ),
            )
          ],
          child: mockConsumer,
        ),
      );

      final context = findInheritedProvider();

      verify(
        combinedConsumerMock(
          CombinedState(context, const CombinedState(), a, b, c),
        ),
      ).called(1);
    });

    testWidgets('StateNotifierProxyProvider4', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: a),
            Provider.value(value: b),
            Provider.value(value: c),
            Provider.value(value: d),
            StateNotifierProxyProvider4<A, B, C, D, CombinedStateNotifier,
                CombinedState>(
              create: (_) => CombinedStateNotifier(),
              update: (context, a, b, c, d, previous) => previous!
                ..state = CombinedState(
                  context,
                  previous.state,
                  a,
                  b,
                  c,
                  d,
                ),
            )
          ],
          child: mockConsumer,
        ),
      );

      final context = findInheritedProvider();

      verify(
        combinedConsumerMock(
          CombinedState(context, const CombinedState(), a, b, c, d),
        ),
      ).called(1);
    });

    testWidgets('StateNotifierProxyProvider5', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: a),
            Provider.value(value: b),
            Provider.value(value: c),
            Provider.value(value: d),
            Provider.value(value: e),
            StateNotifierProxyProvider5<A, B, C, D, E, CombinedStateNotifier,
                CombinedState>(
              create: (_) => CombinedStateNotifier(),
              update: (context, a, b, c, d, e, previous) => previous!
                ..state = CombinedState(
                  context,
                  previous.state,
                  a,
                  b,
                  c,
                  d,
                  e,
                ),
            )
          ],
          child: mockConsumer,
        ),
      );

      final context = findInheritedProvider();

      verify(
        combinedConsumerMock(
          CombinedState(context, const CombinedState(), a, b, c, d, e),
        ),
      ).called(1);
    });

    testWidgets('StateNotifierProxyProvider6', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: a),
            Provider.value(value: b),
            Provider.value(value: c),
            Provider.value(value: d),
            Provider.value(value: e),
            Provider.value(value: f),
            StateNotifierProxyProvider6<A, B, C, D, E, F, CombinedStateNotifier,
                CombinedState>(
              create: (_) => CombinedStateNotifier(),
              update: (context, a, b, c, d, e, f, previous) => previous!
                ..state = CombinedState(
                  context,
                  previous.state,
                  a,
                  b,
                  c,
                  d,
                  e,
                  f,
                ),
            )
          ],
          child: mockConsumer,
        ),
      );

      final context = findInheritedProvider();

      verify(
        combinedConsumerMock(
          CombinedState(context, const CombinedState(), a, b, c, d, e, f),
        ),
      ).called(1);
    });
  });
}
